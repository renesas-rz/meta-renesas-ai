/* Copyright 2017 The TensorFlow Authors. All Rights Reserved.

This file was originally developed by the Tensorflow Authors
before being altered to provide parameter support, ArmNN TfLite
Delegate support, ArmNN Logging support benchmarking output and
refactoring the codebase to allow for the new features.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

/* Standard libraries */
#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <unordered_set>
#include <vector>
#include <numeric>
#include <fcntl.h>
#include <getopt.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

/* ArmNN */
#include <armnn/ArmNN.hpp>
#include <armnn/Utils.hpp>
#include "../delegate/include/armnn_delegate.hpp"
#include "../delegate/include/DelegateOptions.hpp"

/* TfLite */
#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/optional_debug_tools.h"
#include "tensorflow/lite/string_util.h"
#include "tensorflow/lite/profiling/profiler.h"
#include "tensorflow/lite/examples/label_image/bitmap_helpers.h"
#include "tensorflow/lite/examples/label_image/get_top_n.h"
#include "tensorflow/lite/kernels/internal/optimized/cpu_check.h"
#ifdef DUNFELL_XNNPACK
#include "tensorflow/lite/delegates/xnnpack/xnnpack_delegate.h"
#endif

#define LOG(x) std::cerr

enum DelegateType {none, ArmnnTfLite, XNNPack};

namespace tflite {
namespace label_image {

static double timedifference_msec(struct timeval t0, struct timeval t1)
{
	return (double)((t1.tv_sec - t0.tv_sec) * 1000.0f + (t1.tv_usec - t0.tv_usec) / 1000.0f);
}

void CaculateAvergeDeviation(std::vector<double>& time_vec)
{
	double sum = std::accumulate(time_vec.begin(), time_vec.end(), 0.0);
	double mean = sum / time_vec.size();

	std::vector<double> diff(time_vec.size());
	std::transform(time_vec.begin(), time_vec.end(), diff.begin(),
		       std::bind2nd(std::minus<double>(), mean));
	double sq_sum = std::inner_product(diff.begin(), diff.end(), diff.begin(), 0.0);
	double stdev = std::sqrt(sq_sum / time_vec.size());

	std::cout << "Total Time Takes "   << sum   << " ms" << std::endl;
	std::cout << "Average Time Takes " << mean  << " ms" << std::endl;
	std::cout << "Standard Deviation " << stdev << std::endl;
}

/* Takes a file name, and loads a list of labels from it, one per line, and  *
 * returns a vector of the strings. It pads with empty strings so the length *
 * of the result is a multiple of 16, because our model expects that.	     */
TfLiteStatus ReadLabelsFile(const string& file_name,
			    std::vector<string>* result,
			    size_t* found_label_count)
{
	string line;
	const int padding = 16;
	std::ifstream file(file_name);

	if (!file) {
		LOG(FATAL) << "Labels file " << file_name << " not found\n";
		return kTfLiteError;
	}

	result->clear();
	while (std::getline(file, line))
		result->push_back(line);

	*found_label_count = result->size();

	while (result->size() % padding)
		result->emplace_back();

	return kTfLiteOk;
}

int readInputs(std::unique_ptr<Interpreter> &interpreter, Settings* settings)
{
	/* get input dimension from the input tensor metadata, *
	 * assuming there is only one input		      */
	int input = interpreter->inputs()[0];
	TfLiteIntArray* dims = interpreter->tensor(input)->dims;
	int wanted_height = dims->data[1];
	int wanted_width = dims->data[2];
	int wanted_channels = dims->data[3];
	int image_width = 224;
	int image_height = 224;
	int image_channels = 3;

	std::vector<uint8_t> in = read_bmp(settings->input_bmp_name, &image_width,
					   &image_height, &image_channels, settings);

	switch (interpreter->tensor(input)->type) {
		case kTfLiteFloat32:
			settings->input_type = kTfLiteFloat32;
			resize<float>(interpreter->typed_tensor<float>(input), in.data(),
			image_height, image_width, image_channels, wanted_height,
			wanted_width, wanted_channels, settings);
		break;

		case kTfLiteUInt8:
			settings->input_type = kTfLiteUInt8;
			resize<uint8_t>(interpreter->typed_tensor<uint8_t>(input), in.data(),
			image_height, image_width, image_channels, wanted_height,
			wanted_width, wanted_channels, settings);
		break;

		default:
			LOG(FATAL) << "cannot handle input type "
				   << interpreter->tensor(input)->type;
			exit(-1);
	}
	return 0;
}

int readOutputs(std::unique_ptr<Interpreter> &interpreter, Settings* settings,
		std::vector<string> labels)
{
	int output = interpreter->outputs()[0];
	const int output_size = 1000;
	const size_t num_results = 5;
	const float threshold = 0.001f;
	std::vector<std::pair<float, int>> top_results;
	int input = interpreter->inputs()[0];

	switch (interpreter->tensor(output)->type) {
		case kTfLiteFloat32:
			get_top_n<float>(interpreter->typed_output_tensor<float>(0),
				output_size, num_results, threshold, &top_results,
				kTfLiteFloat32);
	break;

		case kTfLiteUInt8:
			get_top_n<uint8_t>(interpreter->typed_output_tensor<uint8_t>(0),
				output_size, num_results, threshold, &top_results,
				kTfLiteUInt8);
	break;

	default:
		LOG(FATAL) << "cannot handle output type "
			   << interpreter->tensor(input)->type << "\n";
		exit(-1);
	}

	for (const auto& result : top_results) {
		const float confidence = result.first;
		const int index = result.second;

		LOG(INFO) << confidence << ": " << index << " " << labels[index] << "\n";
	}
}

void printInterpretatorData(std::unique_ptr<Interpreter> & interpreter, Settings* settings)
{
	LOG(INFO) << "tensors size: " 	<< interpreter->tensors_size() 	<< "\n";
	LOG(INFO) << "nodes size: " 	<< interpreter->nodes_size() 	<< "\n";
	LOG(INFO) << "inputs: " 	<< interpreter->inputs().size() << "\n";
	LOG(INFO) << "input(0) name: "	<< interpreter->GetInputName(0) << "\n";

	for (int i = 0; i < interpreter->tensors_size(); i++) {
		if (interpreter->tensor(i)->name)
			LOG(INFO) << i << ": " << interpreter->tensor(i)->name << ", "
			<< interpreter->tensor(i)->bytes << ", "
			<< interpreter->tensor(i)->type << ", "
			<< interpreter->tensor(i)->params.scale << ", "
			<< interpreter->tensor(i)->params.zero_point << "\n";
	}
}

void RunInference(Settings* settings, DelegateType selectedDelegate,
		  std::vector<armnn::BackendId> backend)
{
	ops::builtin::BuiltinOpResolver resolver;
	std::unique_ptr<FlatBufferModel> model;
	std::unique_ptr<tflite::Interpreter> interpreter;
	std::vector<double> time_vector;
	struct timeval start_time, stop_time;
	size_t label_count;
	std::vector<string> labels;

#ifdef DUNFELL_XNNPACK
	TfLiteDelegate* xnnpack_delegate;
#endif

	/* Setup the model */
	if (!settings->model_name.c_str()) {
		LOG(ERROR) << "no model file name\n";
		exit(-1);
	}
	model = FlatBufferModel::BuildFromFile(settings->model_name.c_str());

	if (!model) {
		LOG(FATAL) << "\nFailed to mmap model " << settings->model_name << "\n";
		exit(-1);
	}
	model->error_reporter();

	/* Setup the TfLite Interpreter  */
	InterpreterBuilder(*model, resolver)(&interpreter);

	if (!interpreter) {
		LOG(FATAL) << "Failed to construct interpreter\n";
		exit(-1);
	}

	/* Setup the delegate */
	if(selectedDelegate == ArmnnTfLite) {
		armnnDelegate::DelegateOptions delegateOptions(backend);
		std::unique_ptr<TfLiteDelegate, decltype(&armnnDelegate::TfLiteArmnnDelegateDelete)>
			armnnTfLiteDelegate(armnnDelegate::TfLiteArmnnDelegateCreate(delegateOptions),
			armnnDelegate::TfLiteArmnnDelegateDelete);

		/* Instruct the Interpreter to use the armnnDelegate */
		if (interpreter->ModifyGraphWithDelegate(std::move(armnnTfLiteDelegate)) != kTfLiteOk) {
			LOG(WARNING) << "Delegate could not be used to modify the graph\n";
			exit(-1);
		}
	}
#ifdef DUNFELL_XNNPACK
	else if(selectedDelegate == XNNPack) {
		TfLiteXNNPackDelegateOptions xnnpack_options = TfLiteXNNPackDelegateOptionsDefault();
		xnnpack_options.num_threads = settings->number_of_threads;
		xnnpack_delegate = TfLiteXNNPackDelegateCreate(&xnnpack_options);

		if (interpreter->ModifyGraphWithDelegate(xnnpack_delegate) != kTfLiteOk) {
			LOG(ERROR) << "Could not modifiy Graph with XNNPack Delegate\n";
		}
	}
#endif

	if (settings->verbose)
		printInterpretatorData(interpreter, settings);

	if (settings->number_of_threads != -1)
		interpreter->SetNumThreads(settings->number_of_threads);

	/* Do not trace execution with the TfLite profiler */
	interpreter->SetProfiler(NULL);

	const std::vector<int> inputs = interpreter->inputs();
	const std::vector<int> outputs = interpreter->outputs();

	if (settings->verbose) {
		LOG(INFO) << "number of inputs: " << inputs.size() << "\n";
		LOG(INFO) << "number of outputs: " << outputs.size() << "\n";
	}

	if (interpreter->AllocateTensors() != kTfLiteOk) {
		LOG(FATAL) << "Failed to allocate tensors!";
		exit(-1);
	}

	if (settings->verbose)
		PrintInterpreterState(interpreter.get());

	readInputs(interpreter, settings);

	/* Invoke once without taking metrics to ready the model buffers */
	if (interpreter->Invoke() != kTfLiteOk) {
		LOG(FATAL) << "Failed to invoke tflite!\n";
		exit(-1);
	}

	/* Invoke the interpretator and output the relevant results *
	 * by recording the time before and after Invocation	    */
	for (int i = 0; i < settings->loop_count; i++) {
		gettimeofday(&start_time, nullptr);

		if (interpreter->Invoke() != kTfLiteOk)
			LOG(FATAL) << "Failed to invoke tflite on interation:"
				   << i+1 << "\n";

		gettimeofday(&stop_time, nullptr);

		/* Calculate the time taken to invoke the interpreter */
		double diff = timedifference_msec(start_time, stop_time);
		time_vector.push_back(diff);
	}

	CaculateAvergeDeviation(time_vector);

	if (ReadLabelsFile(settings->labels_file_name, &labels, &label_count) != kTfLiteOk) {
		LOG(FATAL) << "could not read labels file:" << settings->labels_file_name << "\n";
		exit(-1);
	}

	readOutputs(interpreter, settings, labels);

#ifdef DUNFELL_XNNPACK
	if(selectedDelegate == XNNPack) {
		interpreter.reset();
		TfLiteXNNPackDelegateDelete(xnnpack_delegate);
	}
#endif
}

void display_usage()
{
	LOG(INFO) << "armnnDelegateBenchmark\n"
	<< "--accelerated, -a: [0|1], use Android NNAPI or not\n"
	<< "--count, -c: loop interpreter->Invoke() for certain times\n"
	<< "--compute, -r: [CpuAcc|CpuRef|GpuAcc]\n"
	<< "--delegate, -d:[none|tflite|xnnpack] delegate selection\n"
	<< "--input_mean, -b: input mean\n"
	<< "--input_std, -s: input standard deviation\n"
	<< "--image, -i: image_name.bmp\n"
	<< "--labels, -l: labels for the model\n"
	<< "--tflite_model, -m: model_name.tflite\n"
	<< "--profiling, -p: [0|1], profiling or not\n"
	<< "--threads, -t: number of threads\n"
	<< "--verbose, -v: [0|1] print more information\n"
	<< "--armnn-log-level, -n: [trace|debug|info|warning|error] print more armnn specific information\n"
	<< "\n";
}

int Main(int argc, char** argv)
{
	Settings settings;
	armnn::LogSeverity armnnLogLevel = armnn::LogSeverity::Warning;
	DelegateType selectedDelegate = ArmnnTfLite;
	std::vector<armnn::BackendId> backend = {armnn::Compute::CpuAcc};

	while (1) {
		int arguement;
		int option_index = 0;

		static struct option long_options[] = {
			{"accelerated", required_argument, nullptr, 'a'},
			{"count", required_argument, nullptr, 'c'},
			{"compute", required_argument, nullptr, 'r'},
			{"verbose", required_argument, nullptr, 'v'},
			{"image", required_argument, nullptr, 'i'},
			{"labels", required_argument, nullptr, 'l'},
			{"tflite_model", required_argument, nullptr, 'm'},
			{"profiling", required_argument, nullptr, 'p'},
			{"threads", required_argument, nullptr, 't'},
			{"input_mean", required_argument, nullptr, 'b'},
			{"input_std", required_argument, nullptr, 's'},
			{"delegate", required_argument, nullptr, 'd'},
			{"armnn-log-level", required_argument, nullptr, 'n'},
			{nullptr, 0, nullptr, 0}
		};

		arguement = getopt_long(argc, argv, "a:b:c:d:f:i:l:m:n:p:r:s:t:v:",
					long_options, &option_index);

		/* Detect the end of the options. */
		if (arguement == -1) break;

		switch (arguement) {
		case 'a':
			settings.accel = strtol(optarg, nullptr, 10);
		break;
		case 'b':
			settings.input_mean = strtod(optarg, nullptr);
		break;
		case 'c':
			settings.loop_count = strtol(optarg, nullptr, 10);
		break;
		case 'd':
			if(strstr(optarg, "tflite") != NULL)
				selectedDelegate = ArmnnTfLite;
			else if(strstr(optarg, "xnnpack") != NULL)
				selectedDelegate = XNNPack;
			else
				selectedDelegate = none;
		break;
		case 'i':
			settings.input_bmp_name = optarg;
		break;
		case 'l':
			settings.labels_file_name = optarg;
		break;
		case 'm':
			settings.model_name = optarg;
		break;
		case 'n':
			if(strstr(optarg, "trace"))
				armnnLogLevel = armnn::LogSeverity::Trace;
			else if (strstr(optarg, "debug"))
				armnnLogLevel = armnn::LogSeverity::Debug;
			else if (strstr(optarg, "info"))
				armnnLogLevel = armnn::LogSeverity::Info;
			else if (strstr(optarg, "error"))
				armnnLogLevel = armnn::LogSeverity::Error;
		break;
		case 'p':
			settings.profiling = strtol(optarg, nullptr, 10);
		break;
		case 'r':
			if(strstr(optarg, "CpuRef"))
				backend = {armnn::Compute::CpuRef};
			else if (strstr(optarg, "GpuAcc"))
				backend = {armnn::Compute::GpuAcc};
		break;
		case 's':
			settings.input_std = strtod(optarg, nullptr);
		break;
		case 't':
			settings.number_of_threads = strtol(optarg, nullptr, 10);
		break;
		case 'v':
			settings.verbose = strtol(optarg, nullptr, 10);
		break;
		case 'h':
		case '?':
			/* getopt_long already printed an error message. */
			display_usage();
			exit(-1);
		default:
			exit(-1);
		}
	}

	/* Ensure inference is ran once in the case the loop_count *
	 * is not specified or is invalid			   */
	if (settings.loop_count < 1)
		settings.loop_count = 1;

	/* Print to standard output, including debug, up to specified level */
	armnn::ConfigureLogging(true, true, armnnLogLevel);

	RunInference(&settings, selectedDelegate, backend);
	return 0;
}

}  /* namespace label_image */
}  /* namespace tflite */

int main(int argc, char** argv)
{
	return tflite::label_image::Main(argc, argv);
}
