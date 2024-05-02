﻿/*
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
#include <functional>
#include <future>
#include <algorithm>
#include <iterator>
#include <numeric>
#include <list>

enum ModelType { MODEL_TYPE_FLOAT32, MODEL_TYPE_UINT8 };

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

std::map<int,std::string> label_file_map;

std::string base_path = "/usr/bin/armnn/examples";

std::string common_model_path = "/home/root/models/";

std::string base_more_models_path_tensorflow_lite = common_model_path + "tensorflowlite";

std::string base_more_models_path_onnx = base_path + "/onnx/models";

typedef struct model_params {
    std::string modelFormat;
    ModelType ModelDtype;
    std::string modelPath;
    armnn::TensorShape inputTensorShape;
    std::string inputName;
    std::string outputName;
    unsigned int inputImageWidth;
    unsigned int inputImageHeight;
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
             ModelType ModelDtype,
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
        return EXIT_FAILURE;
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

        switch(ModelDtype) {
        case MODEL_TYPE_FLOAT32:
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
            break;
        }
        case MODEL_TYPE_UINT8:
        {
            std::cout << "uint8 Model is loaded" << std::endl;
            auto inputBinding = model.GetInputBindingInfo();
            printf("Scale %f\n", inputBinding.second.GetQuantizationScale());
            printf("Offset %d\n", inputBinding.second.GetQuantizationOffset());
            ImagePreprocessor<TDataType> Image(inputTensorDataFilePath, inputImageWidth, inputImageHeight, imageSet,
                                                1, {{0, 0, 0}}, {{1, 1, 1}});

            TestCaseData = Image.GetTestCaseData(0);

            outputDataContainers.push_back(std::vector<uint8_t>(model.GetOutputSize()));
            break;
        }
        default:
            std::cout << "Failed to get test case data, unsupported model type " << ModelDtype;
            return EXIT_FAILURE;
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
            return EXIT_FAILURE;
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

        switch(ModelDtype) {
        case MODEL_TYPE_FLOAT32:
        {
            std::vector<float> output;
            output = mapbox::util::get<std::vector<float>>(outputDataContainers[0]);
            ProcessResult<float>(output, model.GetQuantizationParams(), mode_type);
            break;
        }
        case MODEL_TYPE_UINT8:
        {
            std::vector<unsigned char> output;
            output = mapbox::util::get<std::vector<unsigned char>>(outputDataContainers[0]);
            ProcessResult<unsigned char>(output, model.GetQuantizationParams(), mode_type);
            break;
        }
        default:
            std::cout << "Failed to map vector, unsupported model type " << ModelDtype;
            return EXIT_FAILURE;
        }
    }
    catch (armnn::Exception const& e)
    {
        std::cout << "Armnn Error: " << e.what();
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

std::vector<std::string> excelTestModel;

void CreateModelTestOrder()
{
    excelTestModel.push_back("mnasnet_0.5_224.tflite");
    excelTestModel.push_back("mnasnet_0.75_224.tflite");
    excelTestModel.push_back("mnasnet_1.0_96.tflite");
    excelTestModel.push_back("mnasnet_1.0_128.tflite");
    excelTestModel.push_back("mnasnet_1.0_160.tflite");
    excelTestModel.push_back("mnasnet_1.0_192.tflite");
    excelTestModel.push_back("mnasnet_1.0_224.tflite");
    excelTestModel.push_back("mnasnet_1.3_224.tflite");
    excelTestModel.push_back("inception_v3.tflite");
    excelTestModel.push_back("inception_v3_quant.tflite");
    excelTestModel.push_back("inception_v4.tflite");
    excelTestModel.push_back("inception_v4_299_quant.tflite");
    excelTestModel.push_back("squeezenet.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_224_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_192_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_160_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_128_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_224_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_192_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_160_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_128_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_224_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_192_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_160_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_128_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_224_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_192_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_160_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_128_quant.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_224.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_192.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_160.tflite");
    excelTestModel.push_back("mobilenet_v1_1.0_128.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_224.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_192.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_160.tflite");
    excelTestModel.push_back("mobilenet_v1_0.75_128.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_224.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_192.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_160.tflite");
    excelTestModel.push_back("mobilenet_v1_0.5_128.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_224.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_192.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_160.tflite");
    excelTestModel.push_back("mobilenet_v1_0.25_128.tflite");
    excelTestModel.push_back("mobilenet_v2_1.0_224_quant.tflite");
    excelTestModel.push_back("mobilenet_v2_1.4_224.tflite");
    excelTestModel.push_back("mobilenet_v2_1.3_224.tflite");
    excelTestModel.push_back("mobilenet_v2_1.0_224.tflite");
    excelTestModel.push_back("mobilenet_v2_1.0_192.tflite");
    excelTestModel.push_back("mobilenet_v2_1.0_160.tflite");
    excelTestModel.push_back("mobilenet_v2_1.0_128.tflite");
    excelTestModel.push_back("mobilenet_v2_1.0_96.tflite");
    excelTestModel.push_back("mobilenet_v2_0.75_224.tflite");
    excelTestModel.push_back("mobilenet_v2_0.75_192.tflite");
    excelTestModel.push_back("mobilenet_v2_0.75_160.tflite");
    excelTestModel.push_back("mobilenet_v2_0.75_128.tflite");
    excelTestModel.push_back("mobilenet_v2_0.75_96.tflite");
    excelTestModel.push_back("mobilenet_v2_0.5_224.tflite");
    excelTestModel.push_back("mobilenet_v2_0.5_192.tflite");
    excelTestModel.push_back("mobilenet_v2_0.5_160.tflite");
    excelTestModel.push_back("mobilenet_v2_0.5_128.tflite");
    excelTestModel.push_back("mobilenet_v2_0.5_96.tflite");
    excelTestModel.push_back("mobilenet_v2_0.35_224.tflite");
    excelTestModel.push_back("mobilenet_v2_0.35_192.tflite");
    excelTestModel.push_back("mobilenet_v2_0.35_160.tflite");
    excelTestModel.push_back("mobilenet_v2_0.35_128.tflite");
    excelTestModel.push_back("mobilenet_v2_0.35_96.tflite");
    excelTestModel.push_back("mobilenet_v2-1.0.onnx");
}

void initModelTable()
{
    //Mnasnet Model
    Model_Table["mnasnet_0.5_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_0.5_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "output", 224, 224};
    Model_Table["mnasnet_0.75_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_0.75_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "output", 224, 224};
    Model_Table["mnasnet_1.0_96.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_96.tflite", armnn::TensorShape({ 1, 96, 96, 3}), "input", "output", 96, 96};
    Model_Table["mnasnet_1.0_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "output", 128, 128};
    Model_Table["mnasnet_1.0_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "output", 160, 160};
    Model_Table["mnasnet_1.0_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "output", 192, 192};
    Model_Table["mnasnet_1.0_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "output", 224, 224};
    Model_Table["mnasnet_1.3_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.3_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "output", 224, 224};

    //Squeezenet model
    Model_Table["squeezenet.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Squeezenet/squeezenet.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "Placeholder", "softmax_tensor", 224, 224};

    //Tensorflow lite model
    Model_Table["inception_v3.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_InceptionV3/inception_v3.tflite", armnn::TensorShape({ 1, 299, 299, 3}), "input", "InceptionV3/Predictions/Reshape_1", 299, 299};
    Model_Table["inception_v3_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_InceptionV3/inception_v3_quant.tflite", armnn::TensorShape({ 1, 299, 299, 3}), "input", "output", 299, 299};
    Model_Table["inception_v4.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_InceptionV4/inception_v4.tflite", armnn::TensorShape({ 1, 299, 299, 3}), "input", "InceptionV4/Logits/Predictions", 299, 299};
    Model_Table["inception_v4_299_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_InceptionV4/inception_v4_299_quant.tflite", armnn::TensorShape({ 1, 299, 299, 3}), "input", "InceptionV4/Logits/Predictions", 299, 299};

   Model_Table["mobilenet_v1_1.0_224_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_224_quant.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_1.0_192_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_192_quant.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_1.0_160_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_160_quant.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_1.0_128_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_128_quant.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input","MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_0.75_224_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_224_quant.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_0.75_192_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_192_quant.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_0.75_160_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_160_quant.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_0.75_128_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_128_quant.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_0.5_224_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_224_quant.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_0.5_192_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_192_quant.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_0.5_160_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_160_quant.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_0.5_128_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_128_quant.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_0.25_224_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_224_quant.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_0.25_192_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_192_quant.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_0.25_160_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_160_quant.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_0.25_128_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_128_quant.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_1.0_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input","MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_1.0_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_1.0_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_1.0_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_0.75_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_0.75_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_0.75_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_0.75_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_0.5_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_0.5_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_0.5_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_0.5_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v1_0.25_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v1_0.25_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v1_0.25_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v1_0.25_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v2_1.0_224_quant.tflite"] = {"tflite-binary", MODEL_TYPE_UINT8, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_224_quant.tflite", armnn::TensorShape({ 1, 224, 224, 3}),"input", "output", 224, 224};
    Model_Table["mobilenet_v2_1.4_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.4_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v2_1.3_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.3_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v2_1.0_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v2_1.0_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v2_1.0_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v2_1.0_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v2_1.0_96.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_96.tflite", armnn::TensorShape({ 1, 96, 96, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 96, 96};
    Model_Table["mobilenet_v2_0.75_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input","MobilenetV2/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v2_0.75_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v2_0.75_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v2_0.75_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v2_0.75_96.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_96.tflite", armnn::TensorShape({ 1, 96, 96, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 96, 96};
    Model_Table["mobilenet_v2_0.5_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input","MobilenetV2/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v2_0.5_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input","MobilenetV2/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v2_0.5_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v2_0.5_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v2_0.5_96.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_96.tflite", armnn::TensorShape({ 1, 96, 96, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 96, 96};
    Model_Table["mobilenet_v2_0.35_224.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_224.tflite", armnn::TensorShape({ 1, 224, 224, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 224, 224};
    Model_Table["mobilenet_v2_0.35_192.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_192.tflite", armnn::TensorShape({ 1, 192, 192, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 192, 192};
    Model_Table["mobilenet_v2_0.35_160.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_160.tflite", armnn::TensorShape({ 1, 160, 160, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 160, 160};
    Model_Table["mobilenet_v2_0.35_128.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_128.tflite", armnn::TensorShape({ 1, 128, 128, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 128, 128};
    Model_Table["mobilenet_v2_0.35_96.tflite"] = {"tflite-binary", MODEL_TYPE_FLOAT32, base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_96.tflite", armnn::TensorShape({ 1, 96, 96, 3}), "input", "MobilenetV2/Predictions/Reshape_1", 96, 96};

    //ONNX model
    Model_Table["mobilenet_v2-1.0.onnx"] = {"onnx-binary", MODEL_TYPE_FLOAT32, base_more_models_path_onnx + "/mobilenetv2-1.0.onnx", armnn::TensorShape({ 1, 224, 224, 3}), "data", "mobilenetv20_output_flatten0_reshape0", 224, 224};
}

// This will run a test
template<typename TDataType>
int RunTest(const std::string& modelFormat,
            const ModelType ModelDtype,
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
        return EXIT_FAILURE;
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
        return EXIT_FAILURE;
#endif
    }
    else if(modelFormat.find("tflite") != std::string::npos)
    {
#if defined(ARMNN_TF_LITE_PARSER)
        if (! isModelBinary)
        {
            std::cout << "Unknown model format: '" << modelFormat << "'. Only 'binary' format supported \
              for tflite files";
            return EXIT_FAILURE;
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
        return EXIT_FAILURE;
#endif
    }
    else
    {
        std::cout << "Unknown model format: '" << modelFormat <<
                                 "'. Please include 'tflite' or 'onnx'";
        return EXIT_FAILURE;
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
  std::cout << "./armnnBenchmark [-m] [-f] [-c <backend>] [-n <log level>]  [-i <iterations>] [-h]\n"
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
    armnn::LogSeverity armnnLogLevel = armnn::LogSeverity::Warning;

    // Default to the CpuAcc backend, otherwise InferenceModel.hpp
    // will use CpuRef
    std::vector<armnn::BackendId> backend = {armnn::Compute::CpuAcc};
    benched_backend = " (CpuAcc)";

    initModelTable();

    model_params params;

    bool enableProfiling = false;
    bool enableFastMath = false;
    bool enableFp16TurboMode = false;
    size_t subgraphId = 0;
    string inputImageName = "grace_hopper.jpg";
    string inputImagePath = "/usr/bin/armnn/examples/images/";
    int ret = 0;

    while (1) {
        int arguement;
        int option_index = 0;

        static struct option long_options[] = {
                {"enable-fast-math", no_argument, nullptr, 'm'},
                {"fp16-turbo-mode", no_argument, nullptr, 'f'},
                {"compute", required_argument, nullptr, 'c'},
                {"iterations", required_argument, nullptr, 'i'},
                {"armnn-log-level", required_argument, nullptr, 'n'},
                {"help", no_argument, nullptr, 'h'},
                {nullptr, 0, nullptr, 0}
        };

        arguement = getopt_long(argc, argv, "mfhc:i:",
                                long_options, &option_index);

        /* Detect the end of the options. */
        if (arguement == -1) break;

        switch (arguement) {
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

    armnn::ConfigureLogging(true, true, armnnLogLevel);
    CreateModelTestOrder();

    for ( auto it = excelTestModel.begin(); it != excelTestModel.end(); it++ )
    {
        params = Model_Table[*it];

        //load label file
        string label_file_name = "/usr/bin/armnn/examples/tensorflow-lite/models/labels.txt";

        loadLabelFile(label_file_name);

        std::cout << "====================" << std::endl;
        std::cout << "current model is " << *it << std::endl;

        benched_model = *it + ",";

        switch (params.ModelDtype) {
        case MODEL_TYPE_FLOAT32:
            benched_type = "float32,";
            RunTest<float>(params.modelFormat, params.ModelDtype, params.inputTensorShape, params.modelPath,
            params.inputName, inputImagePath, inputImageName, params.inputImageWidth, params.inputImageHeight,
            params.outputName, enableProfiling, subgraphId, enableFastMath, enableFp16TurboMode, &backend);
            break;
        case MODEL_TYPE_UINT8:
            benched_type = "uint8,";
            RunTest<uint8_t>(params.modelFormat, params.ModelDtype, params.inputTensorShape, params.modelPath,
            params.inputName, inputImagePath, inputImageName, params.inputImageWidth, params.inputImageHeight,
            params.outputName, enableProfiling, subgraphId, enableFastMath, enableFp16TurboMode, &backend);
            break;
        default:
            std::cout << "un-supported model type " << params.ModelDtype << " for model " << *it << std::endl;
            ret = -1;
            continue;
        }

        bench.push_back("\n");
    }

    /* Output benchmarks */
    for (std::string ben : bench) {
        std::cout << ben;
    }
    std::cout << std::endl;

    bench.clear();

    return ret;
}
