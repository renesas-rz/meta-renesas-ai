/*
 * Copyright (C) 2021 Renesas Electronics Corp.
 * This file is licensed under the terms of the MIT License
 * This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
 */

#include <armnn/ArmNN.hpp>
#include <armnn/TypesUtils.hpp>

#if defined(ARMNN_CAFFE_PARSER)
#include "armnnCaffeParser/ICaffeParser.hpp"
#endif
#if defined(ARMNN_TF_PARSER)
#include "armnnTfParser/ITfParser.hpp"
#endif
#if defined(ARMNN_TF_LITE_PARSER)
#include "armnnTfLiteParser/ITfLiteParser.hpp"
#endif
#if defined(ARMNN_ONNX_PARSER)
#include "armnnOnnxParser/IOnnxParser.hpp"
#endif

#include "CsvReader.hpp"
#include "InferenceTest.hpp"

#include <Logging.hpp>
#include <Profiling.hpp>
#include "ImagePreprocessor.hpp"
#include "InferenceTestImage.hpp"

#include <boost/algorithm/string/trim.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>
#include <boost/program_options.hpp>
#include <boost/variant.hpp>

#include <iostream>
#include <fstream>
#include <functional>
#include <future>
#include <algorithm>
#include <iterator>
#include <numeric>

#define NUMBER_RUN_TESTS 30

/*
 * Mark benchmarking output with the format:
 * Framework, model, model type, mean, stdev,
 */
std::list<std::string> bench;
enum Parser { caffe, tensorflow, tfLite, onnx };
Parser test_parser;
std::string benched_model;
std::string benched_type;
#define ARMNN_VERSION "Arm NN SDK v19.08.01"

std::map<int,std::string> label_file_map;

std::string base_path = "/usr/bin/armnn/examples";

std::string common_model_path = "/home/root/models/";

std::string base_more_models_path_tensorflow_lite = common_model_path + "tensorflowlite";

std::string base_more_models_path_tensorflow_quant = common_model_path + "armnn/tensorflow";

std::string base_more_models_path_onnx = base_path + "/onnx/models";

typedef struct model_params {
    std::string modelFormat;
    bool isFloatModel;
    std::string modelPath;
    armnn::TensorShape inputTensorShape;
    std::string inputName;
    std::string outputName;
    unsigned int inputImageWidth;
    unsigned int inputImageHeight;
}model_params;

std::map<std::string,model_params> Model_Table;

template <typename TDataType>
int ProcessResult(std::vector<TDataType>& output,InferenceModelInternal::QuantizationParams quantParams,const string mode_type)
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

    BOOST_LOG_TRIVIAL(info) << "= Prediction values for test ";

    auto it = resultMap.rbegin();
    for (int i=0; i<5 && it != resultMap.rend(); ++i)
    {
        BOOST_LOG_TRIVIAL(info) << "Top(" << (i+1) << ") prediction is " << it->second <<
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

    std::cout << "Total Time Takes " << (sum) << " ms"<< std::endl;

    std::cout << "Average Time Takes " << (mean) << " ms"<< std::endl;

    std::cout << "Standard Deviation " << stdev << std::endl;

    /* Add the metrics for parsing */
    bench.push_back(std::to_string(mean) + "," + std::to_string(stdev) + ",");
}

template<typename TParser, typename TDataType>
int MainImpl(const char* modelPath,
             bool isFloatModel,
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
             const std::shared_ptr<armnn::IRuntime>& runtime = nullptr)
{
    // Loads input tensor.
    std::vector<TDataType> input;

    std::ifstream inputTensorFile(inputTensorDataFilePath);
    if (!inputTensorFile.good())
    {
        BOOST_LOG_TRIVIAL(fatal) << "Failed to load input tensor data file from " << inputTensorDataFilePath;
        return EXIT_FAILURE;
    }

    using TContainer = boost::variant<std::vector<float>, std::vector<int>, std::vector<unsigned char>>;

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
        params.m_ComputeDevices = {armnn::Compute::CpuAcc};
        InferenceModel<TParser, TDataType> model(params, enableProfiling, "", runtime);

        // Executes the model.
        std::unique_ptr<ClassifierTestCaseData<TDataType>> TestCaseData;

        if(isFloatModel)
        {
            if(mode_type == "onnx")
            {
                ImagePreprocessor<TDataType>  Image(inputTensorDataFilePath,inputImageWidth,inputImageHeight,imageSet,\
                                                    255.0f,{{0.485f, 0.456f, 0.406f}},{{0.229f, 0.224f, 0.225f}},\
                                                    ImagePreprocessor<TDataType>::DataFormat::NCHW);

                TestCaseData = Image.GetTestCaseData(0);
            }
            else
            {
                ImagePreprocessor<TDataType> Image(inputTensorDataFilePath,inputImageWidth,inputImageHeight,imageSet);
                TestCaseData = Image.GetTestCaseData(0);
            }

            outputDataContainers.push_back(std::vector<float>(model.GetOutputSize()));
        }
        else
        {
            std::cout << "Quant Model is loaded" << std::endl;
            auto inputBinding = model.GetInputBindingInfo();
            printf("Scale %f\n",inputBinding.second.GetQuantizationScale());
            printf("Offset %d\n",inputBinding.second.GetQuantizationOffset());
            ImagePreprocessor<TDataType>  Image(inputTensorDataFilePath,inputImageWidth,inputImageHeight,imageSet,\
                                                1,{{0, 0, 0}},{{1, 1, 1}});

            TestCaseData = Image.GetTestCaseData(0);

            outputDataContainers.push_back(std::vector<uint8_t>(model.GetOutputSize()));

        }

        inputDataContainers.push_back(TestCaseData->m_InputImage);

        //warm up
        model.Run(inputDataContainers, outputDataContainers);

        time_point<high_resolution_clock> predictStart;
        time_point<high_resolution_clock> predictEnd;

        std::vector<double> time_vector;

        for(unsigned int i = 0; i < NUMBER_RUN_TESTS; i++)
        {
            predictStart = high_resolution_clock::now();

            model.Run(inputDataContainers, outputDataContainers);

            predictEnd = high_resolution_clock::now();

            double timeTakenS = duration<double>(predictEnd - predictStart).count();

            time_vector.push_back(timeTakenS*1000.0);
        }

	bench.push_back("AI_BENCHMARK_MARKER,");
	bench.push_back(ARMNN_VERSION);
        switch (test_parser) {
            case caffe:
                bench.push_back(": Caffe,");
            break;

            case tensorflow:
                bench.push_back(": TensorFlow,");
            break;

            case tfLite:
                bench.push_back(": TensorFlow Lite,");
            break;

            case onnx:
                bench.push_back(": ONNX,");
            break;
        }
        bench.push_back(benched_model);
        bench.push_back(benched_type);
        CaculateAvergeDeviation(time_vector);

        if(isFloatModel)
        {
            std::vector<float> output;
            output = boost::get<std::vector<float>>(outputDataContainers[0]);
            ProcessResult<float>(output,model.GetQuantizationParams(),mode_type);
        }
        else
        {
            std::vector<unsigned char> output;
            output = boost::get<std::vector<unsigned char>>(outputDataContainers[0]);
            ProcessResult<unsigned char>(output,model.GetQuantizationParams(),mode_type);
        }
    }
    catch (armnn::Exception const& e)
    {
        BOOST_LOG_TRIVIAL(fatal) << "Armnn Error: " << e.what();
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

std::vector<std::string> excelTestModel;

void CreateModelTestOrder()
{
    excelTestModel.push_back("inception_v3_2016_08_28_frozen.pb");
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
    //Tensorflow model
    Model_Table["inception_v3_2016_08_28_frozen.pb"] = {"tensorflow-binary", true , common_model_path + "armnn/tensorflow/inception_v3_2016_08_28_frozen_transformed.pb",armnn::TensorShape({ 1, 299, 299, 3}),"input","InceptionV3/Predictions/Reshape_1", 299, 299};

    //Mnasnet Model
    Model_Table["mnasnet_0.5_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_0.5_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","output", 224, 224};

    Model_Table["mnasnet_0.75_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_0.75_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","output", 224, 224};

    Model_Table["mnasnet_1.0_96.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_96.tflite",armnn::TensorShape({ 1, 96, 96, 3}),"input","output", 96, 96};

    Model_Table["mnasnet_1.0_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","output", 128, 128};

    Model_Table["mnasnet_1.0_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","output", 160, 160};

    Model_Table["mnasnet_1.0_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","output", 192, 192};

    Model_Table["mnasnet_1.0_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.0_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","output", 224, 224};

    Model_Table["mnasnet_1.3_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/MnasNet/mnasnet_1.3_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","output", 224, 224};

    //squeezenet model
    Model_Table["squeezenet.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Squeezenet/squeezenet.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"Placeholder","softmax_tensor", 224, 224};

    //Tensorflow lite model
    Model_Table["inception_v3.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_InceptionV3/inception_v3.tflite",armnn::TensorShape({ 1, 299, 299, 3}),"input","InceptionV3/Predictions/Reshape_1", 299, 299};

    Model_Table["inception_v3_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_InceptionV3/inception_v3_quant.tflite",armnn::TensorShape({ 1, 299, 299, 3}),"input","output", 299, 299};

   Model_Table["mobilenet_v1_1.0_224_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_224_quant.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_1.0_192_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_192_quant.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_1.0_160_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_160_quant.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_1.0_128_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_128_quant.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v1_0.75_224_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_224_quant.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_0.75_192_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_192_quant.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_0.75_160_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_160_quant.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_0.75_128_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_128_quant.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v1_0.5_224_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_224_quant.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_0.5_192_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_192_quant.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_0.5_160_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_160_quant.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_0.5_128_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_128_quant.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v1_0.25_224_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_224_quant.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_0.25_192_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_192_quant.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_0.25_160_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_160_quant.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_0.25_128_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_128_quant.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

   Model_Table["mobilenet_v1_1.0_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_1.0_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_1.0_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_1.0_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_1.0_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v1_0.75_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_0.75_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_0.75_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_0.75_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.75_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v1_0.5_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_0.5_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_0.5_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_0.5_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.5_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v1_0.25_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV1/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v1_0.25_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV1/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v1_0.25_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV1/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v1_0.25_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V1_Model/mobilenet_v1_0.25_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV1/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v2_1.0_224_quant.tflite"] = {"tflite-binary", false , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_224_quant.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","output", 224, 224};

    Model_Table["mobilenet_v2_1.4_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.4_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV2/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v2_1.3_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.3_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV2/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v2_1.0_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV2/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v2_1.0_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV2/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v2_1.0_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV2/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v2_1.0_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV2/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v2_1.0_96.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_1.0_96.tflite",armnn::TensorShape({ 1, 96, 96, 3}),"input","MobilenetV2/Predictions/Reshape_1", 96, 96};

    Model_Table["mobilenet_v2_0.75_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV2/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v2_0.75_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV2/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v2_0.75_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV2/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v2_0.75_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV2/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v2_0.75_96.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.75_96.tflite",armnn::TensorShape({ 1, 96, 96, 3}),"input","MobilenetV2/Predictions/Reshape_1", 96, 96};

    Model_Table["mobilenet_v2_0.5_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV2/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v2_0.5_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV2/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v2_0.5_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV2/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v2_0.5_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV2/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v2_0.5_96.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.5_96.tflite",armnn::TensorShape({ 1, 96, 96, 3}),"input","MobilenetV2/Predictions/Reshape_1", 96, 96};

    Model_Table["mobilenet_v2_0.35_224.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_224.tflite",armnn::TensorShape({ 1, 224, 224, 3}),"input","MobilenetV2/Predictions/Reshape_1", 224, 224};

    Model_Table["mobilenet_v2_0.35_192.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_192.tflite",armnn::TensorShape({ 1, 192, 192, 3}),"input","MobilenetV2/Predictions/Reshape_1", 192, 192};

    Model_Table["mobilenet_v2_0.35_160.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_160.tflite",armnn::TensorShape({ 1, 160, 160, 3}),"input","MobilenetV2/Predictions/Reshape_1", 160, 160};

    Model_Table["mobilenet_v2_0.35_128.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_128.tflite",armnn::TensorShape({ 1, 128, 128, 3}),"input","MobilenetV2/Predictions/Reshape_1", 128, 128};

    Model_Table["mobilenet_v2_0.35_96.tflite"] = {"tflite-binary", true , base_more_models_path_tensorflow_lite + "/Mobile_Net_V2_Model/mobilenet_v2_0.35_96.tflite",armnn::TensorShape({ 1, 96, 96, 3}),"input","MobilenetV2/Predictions/Reshape_1", 96, 96};

    Model_Table["mobilenet_v2-1.0.onnx"] = {"onnx-binary", true , base_more_models_path_onnx + "/mobilenetv2-1.0.onnx",armnn::TensorShape({ 1, 224, 224, 3}),"data","mobilenetv20_output_flatten0_reshape0", 224, 224};
}

// This will run a test
template<typename TDataType>
int RunTest(const std::string& modelFormat,
            const bool isFloatModel,
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
        BOOST_LOG_TRIVIAL(fatal) << "Unknown model format: '" << modelFormat << "'. Please include 'binary' or 'text'";
        return EXIT_FAILURE;
    }

    // Forward to implementation based on the parser type
    if (modelFormat.find("caffe") != std::string::npos)
    {
#if defined(ARMNN_CAFFE_PARSER)
        test_parser = caffe;
        return MainImpl<armnnCaffeParser::ICaffeParser, TDataType>(modelPath.c_str(), isFloatModel,"caffe",
                                                               inputName.c_str(), &inputTensorShape,
                                                               inputTensorDataFilePath.c_str(), inputImageName,
                                                               inputImageWidth, inputImageHeight, outputName.c_str(),
                                                               enableProfiling, subgraphId, runtime);
#else
        BOOST_LOG_TRIVIAL(fatal) << "Not built with Caffe parser support.";
        return EXIT_FAILURE;
#endif
    }
    else if (modelFormat.find("onnx") != std::string::npos)
    {
#if defined(ARMNN_ONNX_PARSER)
        test_parser = onnx;
        return MainImpl<armnnOnnxParser::IOnnxParser, float>(modelPath.c_str(), isFloatModel, "onnx",
                                                         inputName.c_str(), &inputTensorShape,
                                                         inputTensorDataFilePath.c_str(), inputImageName,
                                                         inputImageWidth, inputImageHeight, outputName.c_str(),
                                                         enableProfiling, subgraphId, runtime);
#else
        BOOST_LOG_TRIVIAL(fatal) << "Not built with Onnx parser support.";
        return EXIT_FAILURE;
#endif
    }
    else if (modelFormat.find("tensorflow") != std::string::npos)
    {
#if defined(ARMNN_TF_PARSER)
        test_parser = tensorflow;
        return MainImpl<armnnTfParser::ITfParser, TDataType>(modelPath.c_str(), isFloatModel, "tensorflow",
                                                         inputName.c_str(), &inputTensorShape,
                                                         inputTensorDataFilePath.c_str(), inputImageName,
                                                         inputImageWidth, inputImageHeight, outputName.c_str(),
                                                         enableProfiling, subgraphId, runtime);
#else
        BOOST_LOG_TRIVIAL(fatal) << "Not built with Tensorflow parser support.";
        return EXIT_FAILURE;
#endif
    }
    else if(modelFormat.find("tflite") != std::string::npos)
    {
#if defined(ARMNN_TF_LITE_PARSER)
        if (! isModelBinary)
        {
            BOOST_LOG_TRIVIAL(fatal) << "Unknown model format: '" << modelFormat << "'. Only 'binary' format supported \
              for tflite files";
            return EXIT_FAILURE;
        }

        test_parser = tfLite;
        return MainImpl<armnnTfLiteParser::ITfLiteParser, TDataType>(modelPath.c_str(), isFloatModel, "tflite",
                                                                 inputName.c_str(), &inputTensorShape,
                                                                 inputTensorDataFilePath.c_str(), inputImageName,
                                                                 inputImageWidth, inputImageHeight, outputName.c_str(),
                                                                 enableProfiling, subgraphId, runtime);
#else
        BOOST_LOG_TRIVIAL(fatal) << "Unknown model format: '" << modelFormat <<
            "'. Please include 'caffe', 'tensorflow', 'tflite' or 'onnx'";
        return EXIT_FAILURE;
#endif
    }
    else
    {
        BOOST_LOG_TRIVIAL(fatal) << "Unknown model format: '" << modelFormat <<
                                 "'. Please include 'caffe', 'tensorflow', 'tflite' or 'onnx'";
        return EXIT_FAILURE;
    }
}

void loadLabelFile(string label_file_name)
{
    std::ifstream infile(label_file_name);

    string line;
    while(std::getline(infile,line))
    {
        stringstream line_stream(line);
        string item;
        std::vector<string> item_vector;
        while(std::getline(line_stream,item,':'))
        {
            //std::cout << item << std::endl;
            item_vector.push_back(item);
        }

        label_file_map[std::stoi(item_vector[0])] = item_vector[1];
    }
}

int main(int argc, const char* argv[])
{
    // Configures logging for both the ARMNN library and this test program.
#ifdef NDEBUG
    armnn::LogSeverity level = armnn::LogSeverity::Info;
#else
    armnn::LogSeverity level = armnn::LogSeverity::Debug;
#endif
    armnn::ConfigureLogging(true, true, level);
    armnnUtils::ConfigureLogging(boost::log::core::get().get(), true, true, level);

    initModelTable();

    model_params params;

    bool enableProfiling = false;
    size_t subgraphId = 0;
    string inputImageName = "grace_hopper.jpg";
    string inputImagePath = "/usr/bin/armnn/examples/images/";

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

        if(params.isFloatModel)
        {
            benched_type = "Float,";
            RunTest<float>(params.modelFormat, params.isFloatModel, params.inputTensorShape, params.modelPath,\
            params.inputName, inputImagePath, inputImageName,\
            params.inputImageWidth,params.inputImageHeight, params.outputName, enableProfiling, subgraphId);
        }
        else
        {
            benched_type = "Quant,";
            RunTest<uint8_t>(params.modelFormat, params.isFloatModel, params.inputTensorShape, params.modelPath,\
            params.inputName, inputImagePath, inputImageName,\
            params.inputImageWidth,params.inputImageHeight, params.outputName, enableProfiling, subgraphId);
        }
            bench.push_back("\n");
    }

    /* Output benchmarks */
    for (std::string ben : bench) {
        std::cout << ben;
    }
    std::cout << std::endl;

    bench.clear();

    return 0;
}
