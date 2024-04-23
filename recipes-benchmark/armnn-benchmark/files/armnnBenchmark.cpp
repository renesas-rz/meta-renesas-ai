/*
 * Copyright (C) 2022 Renesas Electronics Corp.
 * This file is licensed under the terms of the MIT License
 * This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
 */

#include <armnn/ArmNN.hpp>
#include <armnn/TypesUtils.hpp>

#if defined(ARMNN_TF_LITE_PARSER)
#include "armnnTfLiteParser/ITfLiteParser.hpp"
#endif
#if defined(ARMNN_ONNX_PARSER)
#include "armnnOnnxParser/IOnnxParser.hpp"
#endif

#include "InferenceTest.hpp"

#include <Logging.hpp>
#include <Profiling.hpp>
#include "ImagePreprocessor.hpp"
#include "InferenceTestImage.hpp"

#include <dirent.h>
#include <getopt.h>
#include <fcntl.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <functional>
#include <future>
#include <algorithm>
#include <iterator>
#include <numeric>
#include <list>

static long int iterations = 30;

/*
 * Mark benchmarking output with the format:
 * Framework, model, model type, mean, stdev,
 */
std::list<std::string> bench;
enum Parser { tfLite, onnx };
Parser test_parser;
std::string benched_backend;
std::string benched_model;
std::string benched_type;

enum ModelStatus {
    MODEL_TEST_SKIP = -1,
    MODEL_TEST_FAIL = -2
};

std::map<int,std::string> label_file_map;

typedef struct model_params {
    std::string modelFormat;
    std::string ModelDtype;
    std::string modelPath;
    armnn::TensorShape inputTensorShape;
    unsigned int inputImageWidth;
    unsigned int inputImageHeight;
    std::string inputName;
    std::string outputName;
}model_params;

std::map<std::string,model_params> Model_Table;

template <typename TDataType>
int ProcessResult(std::vector<TDataType>& output, InferenceModelInternal::QuantizationParams quantParams, const string mode_type)
{
    std::map<float,int> resultMap;

    int index = 0;

    for (const auto & o : output)
    {
        float prob = ToFloat<TDataType>::Convert(o, quantParams);
        int classification = index++;

        std::map<float, int>::iterator lb = resultMap.lower_bound(prob);
        if (lb == resultMap.end() ||
            !resultMap.key_comp()(prob, lb->first)) {
            resultMap.insert(lb, std::map<float, int>::value_type(prob, classification));
        }
    }

    std::cout << "= Prediction values for test ";

    auto it = resultMap.rbegin();
    for (int i=0; i<5 && it != resultMap.rend(); ++i)
    {
        std::cout << "Top(" << (i+1) << ") prediction is " << it->second <<
            " with confidence: " << 100.0*(it->first) << "%";

        if(mode_type == "onnx")
            std::cout << "Result is " << label_file_map[it->second+1] << std::endl;
        else
            std::cout << "Result is " << label_file_map[it->second] << std::endl;

        ++it;
    }

    return 0;
}

void CaculateAvergeDeviation(vector<double>& time_vec)
{
    double sum = std::accumulate(time_vec.begin(), time_vec.end(), 0.0);
    double mean = sum / static_cast<double>(time_vec.size());

    std::vector<double> diff(time_vec.size());
    std::transform(time_vec.begin(), time_vec.end(), diff.begin(),
                   std::bind2nd(std::minus<double>(), mean));
    double sq_sum = std::inner_product(diff.begin(), diff.end(), diff.begin(), 0.0);
    double stdev = std::sqrt(sq_sum / static_cast<double>(time_vec.size()));

    std::cout << "Total Time Takes " << (sum) << " ms" << std::endl;

    std::cout << "Average Time Takes " << (mean) << " ms" << std::endl;

    std::cout << "Standard Deviation " << stdev << std::endl;

    /* Add the metrics for parsing */
    bench.push_back(std::to_string(mean) + "," + std::to_string(stdev) + ",");
}

template<typename TParser, typename TDataType>
int MainImpl(const char* modelPath,
             const string ModelDtype,
             const string mode_type,
             const char* inputName,
             const armnn::TensorShape* inputTensorShape,
             const char* inputTensorDataFilePath,
             const string inputImageName,
             const unsigned int inputImageWidth,
             const unsigned int inputImageHeight,
             const char* outputName,
             bool enableProfiling,
             const size_t subgraphId,
             const std::shared_ptr<armnn::IRuntime>& runtime = nullptr,
             bool enableFastMath = false,
             bool enableFp16TurboMode = false,
             std::vector<armnn::BackendId> *backend = {armnn::Compute::CpuAcc})
{
    // Loads input tensor.
    std::vector<TDataType> input;

    std::ifstream inputTensorFile(inputTensorDataFilePath);
    if (!inputTensorFile.good())
    {
        std::cout << "Failed to load input tensor data file from " << inputTensorDataFilePath;
        return MODEL_TEST_FAIL;
    }

    using TContainer = 
           mapbox::util::variant<std::vector<float>, std::vector<int>, std::vector<unsigned char>, std::vector<int8_t>>;

    std::vector<TContainer> inputDataContainers;
    std::vector<TContainer> outputDataContainers;

    std::vector<ImageSet> imageSet =
    {
        {inputImageName, 0},
    };

    try
    {
        // Creates an InferenceModel, which will parse the model and load it into an IRuntime.
        typename InferenceModel<TParser, TDataType>::Params params;
        params.m_ModelPath = modelPath;
        params.m_IsModelBinary = true;
        params.m_InputBindings.push_back(std::string(inputName));
        params.m_InputShapes.push_back(*inputTensorShape);
        params.m_OutputBindings.push_back(outputName);
        params.m_SubgraphId = subgraphId;
        params.m_ComputeDevices = *backend;
        params.m_EnableFastMath = enableFastMath;
        params.m_EnableFp16TurboMode = enableFp16TurboMode;
        InferenceModel<TParser, TDataType> model(params, enableProfiling, "", runtime);

        // Executes the model.
        std::unique_ptr<ClassifierTestCaseData<TDataType>> TestCaseData;

        if (ModelDtype == "float32")
        {
            std::cout << "float32 Model is loaded" << std::endl;
            if(mode_type == "onnx")
            {
                ImagePreprocessor<TDataType>  Image(inputTensorDataFilePath, inputImageWidth, inputImageHeight, imageSet,
                                                    255.0f, {{0.485f, 0.456f, 0.406f}}, {{0.229f, 0.224f, 0.225f}},
                                                    ImagePreprocessor<TDataType>::DataFormat::NCHW);

                TestCaseData = Image.GetTestCaseData(0);
            }
            else
            {
                ImagePreprocessor<TDataType> Image(inputTensorDataFilePath, inputImageWidth, inputImageHeight, imageSet);
                TestCaseData = Image.GetTestCaseData(0);
            }

            outputDataContainers.push_back(std::vector<float>(model.GetOutputSize()));
        }
        else if (ModelDtype == "uint8")
        {
            std::cout << "uint8 Model is loaded" << std::endl;
            auto inputBinding = model.GetInputBindingInfo();
            printf("Scale %f\n", inputBinding.second.GetQuantizationScale());
            printf("Offset %d\n", inputBinding.second.GetQuantizationOffset());
            ImagePreprocessor<TDataType> Image(inputTensorDataFilePath, inputImageWidth, inputImageHeight, imageSet,
                                                1, {{0, 0, 0}}, {{1, 1, 1}});

            TestCaseData = Image.GetTestCaseData(0);

            outputDataContainers.push_back(std::vector<uint8_t>(model.GetOutputSize()));
        }

        inputDataContainers.push_back(TestCaseData->m_InputImage);

        //warm up
	const std::vector<TContainer>& inputRef = inputDataContainers;
        model.Run(inputRef, outputDataContainers);

        time_point<high_resolution_clock> predictStart;
        time_point<high_resolution_clock> predictEnd;

        std::vector<double> time_vector;

        for(unsigned int i = 0; i < iterations; i++)
        {
            predictStart = high_resolution_clock::now();

            model.Run(inputRef, outputDataContainers);

            predictEnd = high_resolution_clock::now();

            double timeTakenS = duration<double>(predictEnd - predictStart).count();

            time_vector.push_back(timeTakenS*1000.0);
        }

        /* Find the version of ArmNN in the RFS  */
        string usrDir = "/usr/bin/";
        string armnnPrefix = "armnn-2";
        DIR *dir;
        struct dirent *dirp;
        string armnnVer = "Arm NN SDK v";

        if((dir = opendir(usrDir.c_str())) != NULL)
        {
            while ((dirp = readdir(dir)) != NULL) {
                string filename = dirp->d_name;

                if(filename.find(armnnPrefix) != std::string::npos) {
                    armnnVer = armnnVer.append(filename.substr(6));
                    break;
                }
            }
        } else {
            std::cout << "Error opening" << usrDir << std::endl;
            return MODEL_TEST_FAIL;
        }
        closedir(dir);

	bench.push_back("AI_BENCHMARK_MARKER,");
	bench.push_back(armnnVer);
	bench.push_back(benched_backend);

        switch (test_parser) {
            case tfLite:
                bench.push_back(": TensorFlow Lite");
            break;

            case onnx:
                bench.push_back(": ONNX");
            break;
        }

	if(enableFastMath)
		bench.push_back(" (Fast Math)");
	if(enableFp16TurboMode)
		bench.push_back(" (FP16 Turbo)");

        bench.push_back(",");
        bench.push_back(benched_model);
        bench.push_back(benched_type);
        CaculateAvergeDeviation(time_vector);

        if (ModelDtype == "float32")
        {
            std::vector<float> output;
            output = mapbox::util::get<std::vector<float>>(outputDataContainers[0]);
            ProcessResult<float>(output, model.GetQuantizationParams(), mode_type);
        }
        else if (ModelDtype == "uint8")
        {
            std::vector<unsigned char> output;
            output = mapbox::util::get<std::vector<unsigned char>>(outputDataContainers[0]);
            ProcessResult<unsigned char>(output, model.GetQuantizationParams(), mode_type);
        }
    }
    catch (armnn::Exception const& e)
    {
        std::cout << "Armnn Error: " << e.what();
        return MODEL_TEST_FAIL;
    }

    return EXIT_SUCCESS;
}

std::vector<std::string> excelTestModel;
std::map<std::string, int> model_line_numbers;
std::vector<std::string> skipped_models;

std::map<std::string, model_params> CreateModelMap(const std::string& filepath)
{
    std::map<std::string, model_params> Model_Table;
    std::ifstream infile(filepath);
    int line_number = 0;

    if (!infile)
    {
        std::cout << "Cannot open file: " << filepath << std::endl;
        exit(EXIT_FAILURE);
    }

    std::string line;

    while (std::getline(infile, line))
    {
        line_number++;
        bool skip_model = false;

        // Skip any line that is empty or has a # as the first character
        if (line.empty() || line.at(0) == '#')
        {
            continue;
        }

        // Skip and print any line that does not contain an '=' sign
        if (line.find('=') == std::string::npos)
        {
            std::cout << "Invalid format: " << line << std::endl << "Please check line: "
                      << line_number << " in the text file: " << filepath << std::endl;
            continue;
        }

        std::stringstream model_info(line);

        // Retrieve the model key used to identify the model
        std::string key;
        std::getline(model_info, key, '=');

        if (key.empty())
        {
            std::cout << "No model name set: " << line << std::endl << "Please check line: "
                      << line_number << " in the text file: " << filepath << std::endl;
            continue;
        }

        model_params params;
        std::string value;
        int value_count = 0;

        // Retrieve model information from the text file
        // Each value is located by looking for commas ',' as delimiters
        while (std::getline(model_info, value, ','))
        {
            switch (value_count)
            {
                case 0:
                    params.modelFormat = value;
                    break;
                case 1:
                    params.ModelDtype = value;

                    if (params.ModelDtype != "float32" && params.ModelDtype != "uint8")
                    {
                        std::cout << "Invalid datatype for model: " << key << std::endl << "Please check line: "
                                  << line_number << " in the text file: " << filepath << std::endl;
                        skip_model = true;
                    }

                    break;
                case 2:
                {
                    params.modelPath = value;
                    std::ifstream model_file(params.modelPath);

                    if (!model_file)
                    {
                        std::cout << "Cannot read file: " << params.modelPath << std::endl << "Please check line: "
                                  << line_number << " in the text file: " << filepath << std::endl;
                        skip_model = true;
                    }

                    break;
                }
                case 3:
                {
                    std::stringstream tensor_dimensions(value);
                    std::string dim;
                    std::vector<unsigned int> dimensions;

                    // 'x' is used as the deliminator to find the values for the dimensions
                    while (std::getline(tensor_dimensions, dim, 'x'))
                    {
                        dimensions.push_back(std::stoi(dim));
                    }

                    // Make sure that the number of dimensions is equal to 4 otherwise skip the model
                    if (dimensions.size() != 4)
                    {
                        std::cout << "Invalid inputTensorShape parameters for model: " << key << std::endl << "Please check line: "
                                  << line_number << " in the text file: " << filepath << std::endl;
                        skip_model = true;
                    }

                    // Extract the input image height and width from the tensor shape provided
                    params.inputTensorShape = armnn::TensorShape({dimensions[0], dimensions[1], dimensions[2], dimensions[3]});
                    params.inputImageWidth = dimensions[2];
                    params.inputImageHeight = dimensions[1];
                    break;
                }
                case 4:
                    params.inputName = value;
                    break;
                case 5:
                    params.outputName = value;
                    break;
                default:
                    std::cout << "Unexpected value encounted for model: " << key << std::endl;
                    break;
            }

            if (skip_model)
                break;

            value_count++;
        }

        // Skip model if there are attributes missing or too many attributes present
        if (value_count != 6 && !skip_model)
        {
            skip_model = true;
            std::cout << "Invalid format for model: " << key << std::endl << "Please check line: "
                      << line_number << " in the text file: " << filepath << std::endl;
        }
        model_line_numbers[key] = line_number;

        // Create model map and model order
        if (!skip_model)
        {
            Model_Table[key] = params;
            excelTestModel.push_back(key);
        }
        else
        {
            skipped_models.push_back(key);
        }
    }

    infile.close();

    return Model_Table;
}

// This will run a test
template<typename TDataType>
int RunTest(const std::string& modelFormat,
            const string ModelDtype,
            const armnn::TensorShape& inputTensorShape,
            const std::string& modelPath,
            const std::string& inputName,
            const std::string& inputTensorDataFilePath,
            const std::string& inputImageName,
            const unsigned int inputImageWidth,
            const unsigned int inputImageHeight,
            const std::string& outputName,
            bool enableProfiling,
            const size_t subgraphId,
            bool enableFastMath = false,
            bool enableFp16TurboMode = false,
            std::vector<armnn::BackendId> *backend = {armnn::Compute::CpuAcc},
            const std::shared_ptr<armnn::IRuntime>& runtime = nullptr)
{
    // Parse model binary flag from the model-format string we got from the command-line
    bool isModelBinary;
    if (modelFormat.find("bin") != std::string::npos)
    {
        isModelBinary = true;
    }
    else if (modelFormat.find("txt") != std::string::npos || modelFormat.find("text") != std::string::npos)
    {
        isModelBinary = false;
    }
    else
    {
        std::cout << "Unknown model format: '" << modelFormat << "'. Please include 'binary' or 'text'";
        return MODEL_TEST_SKIP;
    }

    // Forward to implementation based on the parser type
    if (modelFormat.find("onnx") != std::string::npos)
    {
#if defined(ARMNN_ONNX_PARSER)
        test_parser = onnx;
        return MainImpl<armnnOnnxParser::IOnnxParser, float>(modelPath.c_str(),
                                                         ModelDtype, "onnx",
                                                         inputName.c_str(), &inputTensorShape,
                                                         inputTensorDataFilePath.c_str(), inputImageName,
                                                         inputImageWidth, inputImageHeight, outputName.c_str(),
                                                         enableProfiling, subgraphId, runtime, enableFastMath,
                                                         enableFp16TurboMode, backend);
#else
        std::cout << "Not built with Onnx parser support.";
        return MODEL_TEST_FAIL;
#endif
    }
    else if(modelFormat.find("tflite") != std::string::npos)
    {
#if defined(ARMNN_TF_LITE_PARSER)
        if (! isModelBinary)
        {
            std::cout << "Unknown model format: '" << modelFormat << "'. Only 'binary' format supported \
              for tflite files";
            return MODEL_TEST_SKIP;
        }

        test_parser = tfLite;
        return MainImpl<armnnTfLiteParser::ITfLiteParser, TDataType>(modelPath.c_str(),
                                                                 ModelDtype, "tflite",
                                                                 inputName.c_str(), &inputTensorShape,
                                                                 inputTensorDataFilePath.c_str(), inputImageName,
                                                                 inputImageWidth, inputImageHeight, outputName.c_str(),
                                                                 enableProfiling, subgraphId, runtime, enableFastMath,
                                                                 enableFp16TurboMode, backend);
#else
        std::cout << "Not built with TfLite parser support.";
        return MODEL_TEST_FAIL;
#endif
    }
    else
    {
        std::cout << "Unknown model format: '" << modelFormat <<
                                 "'. Please include 'tflite' or 'onnx'";
        return MODEL_TEST_SKIP;
    }
}

void loadLabelFile(string label_file_name)
{
    std::ifstream infile(label_file_name);

    string line;
    while(std::getline(infile, line))
    {
        stringstream line_stream(line);
        string item;
        std::vector<string> item_vector;
        while(std::getline(line_stream, item, ':'))
        {
            //std::cout << item << std::endl;
            item_vector.push_back(item);
        }

        label_file_map[std::stoi(item_vector[0])] = item_vector[1];
    }
}

void display_usage() {
  std::cout << "./armnnBenchmark -l <model attributes text file path> [-m] [-f] [-c <backend>] [-n <log level>]  [-i <iterations>] [-h]\n"
            << "--list-of-models, -l: file path to .txt file containing the list of models and their attributes\n"
            << "--enable-fast-math, -m: use fast maths armnn option\n"
            << "--fp16-turbo-mode, -f: use fp16-turbo-mode armnn option\n"
            << "--compute, -c: [CpuAcc|CpuRef|GpuAcc] (Default: CpuAcc)\n"
            << "--armnn-log-level, -n: [trace|debug|info|warning|error] (Default: warning) Print level of ArmNN specific information\n"
            << "--iterations, -i: Loop inference run count\n"
            << "--help, -h: display this message \n"
            << "\n";
}

int main(int argc, char** argv)
{
    std::string model_list_filepath;
    armnn::LogSeverity armnnLogLevel = armnn::LogSeverity::Warning;

    // Default to the CpuAcc backend, otherwise InferenceModel.hpp
    // will use CpuRef
    std::vector<armnn::BackendId> backend = {armnn::Compute::CpuAcc};
    benched_backend = " (CpuAcc)";

    model_params params;

    bool enableProfiling = false;
    bool enableFastMath = false;
    bool enableFp16TurboMode = false;
    size_t subgraphId = 0;
    string inputImageName = "grace_hopper.jpg";
    string inputImagePath = "/usr/bin/armnn/examples/images/";
    std::vector<std::string> failed_models;
    int ret_app = 0;
    int ret_test_result = 0;

    while (1) {
        int arguement;
        int option_index = 0;

        static struct option long_options[] = {
                {"list-of-models", required_argument, nullptr, 'l'},
                {"enable-fast-math", no_argument, nullptr, 'm'},
                {"fp16-turbo-mode", no_argument, nullptr, 'f'},
                {"compute", required_argument, nullptr, 'c'},
                {"iterations", required_argument, nullptr, 'i'},
                {"armnn-log-level", required_argument, nullptr, 'n'},
                {"help", no_argument, nullptr, 'h'},
                {nullptr, 0, nullptr, 0}
        };

        arguement = getopt_long(argc, argv, "l:mfhc:i:",
                                long_options, &option_index);

        /* Detect the end of the options. */
        if (arguement == -1) break;

        switch (arguement) {
          case 'l':
              model_list_filepath = optarg;
              if (model_list_filepath.empty())
              {
                  std::cout << "Error: option -l not specified." << std::endl;
                  display_usage();
                  exit(-1);
              }
          break;
          case 'm':
              enableFastMath = true;
          break;
          case 'f':
              enableFp16TurboMode = true;
          break;
          case 'c':
              if (strstr(optarg, "CpuRef")) {
                  benched_backend = " (CpuRef)";
                  backend = {armnn::Compute::CpuRef};
              } else if (strstr(optarg, "GpuAcc")) {
                  benched_backend = " (GpuAcc)";
                  backend = {armnn::Compute::GpuAcc};
              } else {
                  benched_backend = " (CpuAcc)";
                  backend = {armnn::Compute::CpuAcc};
              }
          break;
          case 'i':
              iterations = strtol(optarg, nullptr, 10);
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
          case 'h':
          case '?':
              display_usage();
              exit(-1);

          default:
              std::cout << "Unknown parameter." << std::endl;
              display_usage();
              exit(-1);
        }
    }

    if (model_list_filepath.empty())
    {
        std::cout << "Error: -l option is mandatory." << std::endl;
        display_usage();
        exit(-1);
    }

    armnn::ConfigureLogging(true, true, armnnLogLevel);

    std::map<std::string, model_params> Model_Table = CreateModelMap(model_list_filepath);

    for ( auto it = excelTestModel.begin(); it != excelTestModel.end(); it++ )
    {
        params = Model_Table[*it];

        //load label file
        string label_file_name = "/usr/bin/armnn/examples/tensorflow-lite/models/labels.txt";

        loadLabelFile(label_file_name);

        std::cout << "====================" << std::endl;
        std::cout << "current model is " << *it << std::endl;

        benched_model = *it + ",";

        if (params.ModelDtype == "float32")
        {
            benched_type = "float32,";
            ret_test_result = RunTest<float>(params.modelFormat, params.ModelDtype, params.inputTensorShape, params.modelPath,
            params.inputName, inputImagePath, inputImageName, params.inputImageWidth, params.inputImageHeight,
            params.outputName, enableProfiling, subgraphId, enableFastMath, enableFp16TurboMode, &backend);
        }
        else if (params.ModelDtype == "uint8")
        {
            benched_type = "uint8,";
            ret_test_result = RunTest<uint8_t>(params.modelFormat, params.ModelDtype, params.inputTensorShape, params.modelPath,
            params.inputName, inputImagePath, inputImageName, params.inputImageWidth, params.inputImageHeight,
            params.outputName, enableProfiling, subgraphId, enableFastMath, enableFp16TurboMode, &backend);
        }

        bench.push_back("\n");

        if (ret_test_result == MODEL_TEST_SKIP)
        {
            skipped_models.push_back(*it);
        }
        else if (ret_test_result == MODEL_TEST_FAIL)
        {
            failed_models.push_back(*it);
        }
    }

    /* Output benchmarks */
    for (std::string ben : bench) {
        std::cout << ben;
    }
    std::cout << std::endl;

    if (!skipped_models.empty())
    {
        ret_app = EXIT_FAILURE;
        std::cout << "====================" << std::endl << "Models skipped from "
                  << model_list_filepath << " are:" << std::endl;

        for (const auto& skipped_model : skipped_models)
        {
            if (model_line_numbers.find(skipped_model) != model_line_numbers.end())
            {
                std::cout << skipped_model << " on line number " << model_line_numbers[skipped_model] << std::endl;
            }
        }
        std::cout << "Please check formatting" << std::endl;
    }

    if (!failed_models.empty())
    {
        ret_app = EXIT_FAILURE;
        std::cout << "====================" << std::endl << "Models failed from "
                  << model_list_filepath << " are:" << std::endl;
        for (const auto& failed_model : failed_models)
        {
            std::cout << failed_model << std::endl;
        }

        std::cout << "Please check logs" << std::endl;
    }

    if (excelTestModel.empty())
    {
        std::cout << "No models found in file: " << model_list_filepath << std::endl;
    }

    bench.clear();

    return ret_app;
}
