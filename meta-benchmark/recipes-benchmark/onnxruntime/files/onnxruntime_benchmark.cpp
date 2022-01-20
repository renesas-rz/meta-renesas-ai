// Copyright(c) Microsoft Corporation.All rights reserved.
// Licensed under the MIT License.
//
// Additional changes:
// Copyright (C) 2020-2022 Renesas Electronics Corp.

#include <assert.h>
#include <onnxruntime_c_api.h>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <map>
#include <fstream>
#include <sys/time.h>
#include <numeric>
#include <algorithm>
#include <list>
#include <iostream>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

const OrtApi* g_ort = OrtGetApiBase()->GetApi(ORT_API_VERSION);

/*
 * Mark benchmarking output with the format:
 * Framework, model, model type, mean, stdev,
 */
std::list<std::string> bench;

// helper function to check for status
void CheckStatus(OrtStatus* status)
{
  if (status != NULL) {
    const char* msg = g_ort->GetErrorMessage(status);
    fprintf(stderr, "%s\n", msg);
    g_ort->ReleaseStatus(status);
    exit(1);
  }
}

std::map<int,std::string> label_file_map;

int loadLabelFile(std::string label_file_name)
{
  int counter = 0;
  std::ifstream infile(label_file_name);

  if (!infile.is_open()) {
    perror("error while opening file");
    return -1;
  }

  std::string line;
  while(std::getline(infile,line)) {
    label_file_map[counter++] = line;
  }

  if (infile.bad()) {
    perror("error while reading file");
    return -1;
  }

  return 0;
}

static double timedifference_msec(struct timeval t0, struct timeval t1)
{
  return (t1.tv_sec - t0.tv_sec) * 1000.0 + (t1.tv_usec - t0.tv_usec) / 1000.0;
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

  printf("Total Time Takes %f ms\n", sum);
  printf("Average Time Takes  %f ms\n", mean);
  printf("Standard Deviation  %f\n", stdev);

  /* Add the metrics for parsing */
  bench.push_back(std::to_string(mean) + "," + std::to_string(stdev) + ",");
}


int main(int argc, char* argv[])
{
  if (argc != 5) {
    fprintf(stderr,"Incorrect number of parameters. 4 parameters expected.\n");
    fprintf(stderr,"%s <nr inferences to run> <model name> <model> <input image file>\n", argv[0]);
    return -1;
  }

  const char *model_name = argv[2];
  const char *model_path = argv[3];
  const char *image_path = argv[4];

  int inference_count = 0;

  try {
    inference_count = std::stoi(std::string(argv[1]));
  }
  catch(std::exception const & e) {
      printf("read input parameter error:  %s\n", e.what());
  }

  OrtEnv* env;
  CheckStatus(g_ort->CreateEnv(ORT_LOGGING_LEVEL_WARNING, "test", &env));

  OrtSession* session;

  OrtSessionOptions* session_options = NULL;

  CheckStatus(g_ort->CreateSession(env, model_path, session_options, &session));

  size_t num_input_nodes;
  size_t num_output_nodes;
  OrtStatus* status;
  OrtAllocator* allocator;
  CheckStatus(g_ort->GetAllocatorWithDefaultOptions(&allocator));

  status = g_ort->SessionGetInputCount(session, &num_input_nodes);
  status = g_ort->SessionGetOutputCount(session, &num_output_nodes);

  std::vector<const char*> input_node_names(num_input_nodes);
  std::vector<const char*> output_node_names(num_output_nodes);
  std::vector<int64_t> input_node_dims;
  std::vector<int64_t> output_node_dims;

  printf("Current Model is %s\n", model_name);

  bench.push_back("AI_BENCHMARK_MARKER,");
  bench.push_back("ONNX Runtime v");
  bench.push_back(OrtGetApiBase()->GetVersionString());
  bench.push_back(",");
  bench.push_back(model_name);
  bench.push_back(",");

  ONNXTensorElementDataType type;

  printf("Number of inputs = %zu\n", num_input_nodes);
  // iterate over all input nodes
  for (size_t i = 0; i < num_input_nodes; i++) {
    // print input node names
    char* input_name;
    status = g_ort->SessionGetInputName(session, i, allocator, &input_name);
    printf("Input %zu : name=%s\n", i, input_name);
    input_node_names[i] = input_name;

    // print input node types
    OrtTypeInfo* typeinfo;
    status = g_ort->SessionGetInputTypeInfo(session, i, &typeinfo);
    const OrtTensorTypeAndShapeInfo* tensor_info;
    CheckStatus(g_ort->CastTypeInfoToTensorInfo(typeinfo, &tensor_info));
    CheckStatus(g_ort->GetTensorElementType(tensor_info, &type));
    printf("Input %zu : type=%d\n", i, type);

    // print input shapes/dims
    size_t num_dims;
    CheckStatus(g_ort->GetDimensionsCount(tensor_info, &num_dims));
    printf("Input %zu : num_dims=%zu\n", i, num_dims);
    input_node_dims.resize(num_dims);
    CheckStatus(g_ort->GetDimensions(tensor_info, (int64_t*)input_node_dims.data(), num_dims));
    for (size_t j = 0; j < num_dims; j++)
      printf("Input %zu : dim %zu=%jd\n", i, j, input_node_dims[j]);

    g_ort->ReleaseTypeInfo(typeinfo);
  }

  switch (type) {
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16:
      bench.push_back("bfloat16,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL:
      bench.push_back("bool,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128:
      bench.push_back("complex128,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64:
      bench.push_back("complex64,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE:
      bench.push_back("double,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT:
      bench.push_back("float32,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16:
      bench.push_back("float16,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16:
      bench.push_back("int16,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32:
      bench.push_back("int32,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64:
      bench.push_back("int64,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8:
      bench.push_back("int8,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING:
      bench.push_back("string,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16:
      bench.push_back("uint16,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32:
      bench.push_back("uint32,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64:
      bench.push_back("uint64,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8:
      bench.push_back("uint8,");
      break;
    case ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED:
    default:
      bench.push_back("Unknown,");
  }

  printf("Number of outputs = %zu\n", num_output_nodes);
  // iterate over all output nodes
  for (size_t i = 0; i < num_output_nodes; i++) {
    // print output node names
    char* output_name;
    status = g_ort->SessionGetOutputName(session, i, allocator, &output_name);
    printf("output %zu : name=%s\n", i, output_name);
    output_node_names[i] = output_name;

    // print output node types
    OrtTypeInfo* typeinfo;
    status = g_ort->SessionGetOutputTypeInfo(session, i, &typeinfo);
    const OrtTensorTypeAndShapeInfo* tensor_info;
    CheckStatus(g_ort->CastTypeInfoToTensorInfo(typeinfo,&tensor_info));
    ONNXTensorElementDataType type;
    CheckStatus(g_ort->GetTensorElementType(tensor_info,&type));
    printf("Output %zu : type=%d\n", i, type);

    // print output shapes/dims
    size_t num_dims;
    CheckStatus(g_ort->GetDimensionsCount(tensor_info, &num_dims));
    printf("Output %zu : num_dims=%zu\n", i, num_dims);
    output_node_dims.resize(num_dims);
    CheckStatus(g_ort->GetDimensions(tensor_info, (int64_t*)output_node_dims.data(), num_dims));

    for (size_t j = 0; j < num_dims; j++) {
      printf("Output %zu : dim %zu=%jd\n", i, j, output_node_dims[j]);
    }

    g_ort->ReleaseTypeInfo(typeinfo);
  }

  // initialize input data
  int img_sizex, img_sizey, img_channels;

  stbi_uc* img_data = stbi_load(image_path, &img_sizex, &img_sizey, &img_channels, STBI_default);

  size_t input_tensor_size = img_sizex * img_sizey  * 3;
  std::vector<float> input_tensor_values(input_tensor_size);

  struct S_Pixel {
    unsigned char RGBA[3];
  };

  const S_Pixel* imgPixels(reinterpret_cast<const S_Pixel *>(img_data));

  // Normalize the input values using factors calculated from the Imagenet dataset
  // If you have uncommon lighting or scenes you may want to calculate your own values.
  const float mean[3]   = { 0.485f, 0.456f, 0.406f };
  const float stddev[3] = { 0.229f, 0.224f, 0.225f };

  size_t offs = 0;

  for (size_t c = 0; c < 3; c++) {
    for (size_t y = 0; y < img_sizey; y++) {
      for (size_t x = 0; x < img_sizex; x++, offs++) {
        const float val((float)imgPixels[y * img_sizex + x].RGBA[c]/255);

        input_tensor_values[offs] = (val- mean[c])/stddev[c];
      }
    }
  }

  // create input tensor object from data values
  OrtMemoryInfo* memory_info;
  CheckStatus(g_ort->CreateCpuMemoryInfo(OrtArenaAllocator, OrtMemTypeDefault, &memory_info));
  OrtValue* input_tensor = NULL;
  CheckStatus(g_ort->CreateTensorWithDataAsOrtValue(memory_info, input_tensor_values.data(), input_tensor_size * sizeof(float), input_node_dims.data(), 4, ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT, &input_tensor));
  int is_tensor;
  CheckStatus(g_ort->IsTensor(input_tensor, &is_tensor));
  assert(is_tensor);
  g_ort->ReleaseMemoryInfo(memory_info);

  std::vector<double> time_vector;
  struct timeval start_time, stop_time;
  // score model & input tensor, get back output tensor
  OrtValue* output_tensor = NULL;
  // Run once without measuring the time to warm things up
  CheckStatus(g_ort->Run(session, NULL, input_node_names.data(), (const OrtValue* const*)&input_tensor, 1, output_node_names.data(), 1, &output_tensor));
  for (int i = 0; i < inference_count; i++) {
    gettimeofday(&start_time, nullptr);
    CheckStatus(g_ort->Run(session, NULL, input_node_names.data(), (const OrtValue* const*)&input_tensor, 1, output_node_names.data(), 1, &output_tensor));
    gettimeofday(&stop_time, nullptr);
    CheckStatus(g_ort->IsTensor(output_tensor, &is_tensor));
    assert(is_tensor);

    double diff = timedifference_msec(start_time,stop_time);
    time_vector.push_back(diff);
  }

  CaculateAvergeDeviation(time_vector);

  // get pointer to output tensor float values
  float* floatarr;
  CheckStatus(g_ort->GetTensorMutableData(output_tensor, (void**)&floatarr));

  std::map<float,int> result;

  // score the model, and print scores for first 5 classes
  for (int i = 0; i < 1000; i++) {
    result[floatarr[i]] = i;
  }

  std::string filename("/usr/bin/onnxruntime/examples/inference/synset_words.txt");

  if (loadLabelFile(filename) != 0) {
    fprintf(stderr,"Fail to open or process file %s\n",filename.c_str());
    return -1;
  }

  int counter = 0;
  for (auto it = result.rbegin(); it != result.rend(); it++) {
    counter++;

    if (counter > 6)
      break;

    printf("index [%d]: %s :prob [%f]\n",(*it).second,label_file_map[(*it).second].c_str(),(*it).first);
  }

  g_ort->ReleaseValue(output_tensor);
  g_ort->ReleaseValue(input_tensor);
  g_ort->ReleaseSession(session);
  g_ort->ReleaseSessionOptions(session_options);
  g_ort->ReleaseEnv(env);
  printf("Done!\n");

  /* Output benchmarks */
  for (std::string ben : bench) {
    std::cout << ben;
  }
  std::cout << std::endl;

  bench.clear();

  return 0;
}
