/*
 * Copyright (C) 2020 Renesas Electronics Corp.
 * This file is licensed under the terms of the MIT License
 * This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
 */

#include <assert.h>
#include <onnxruntime_c_api.h>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <map>
#include <fstream>
#include <sys/time.h>
#include <iostream>
#include <numeric>
#include <algorithm>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

const OrtApi* g_ort = OrtGetApiBase()->GetApi(ORT_API_VERSION);

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

    if (!infile.is_open())
    {
        perror("error while opening file");
        return -1;
    }

    std::string line;
    while(std::getline(infile,line))
    {
        label_file_map[counter++] = line;
    }

    if (infile.bad())
    {
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

    std::cout << "Total Time Takes " << (sum) << " ms"<< std::endl;
    std::cout << "Average Time Takes " << (mean) << " ms"<< std::endl;
    std::cout << "Standard Deviation " << stdev << std::endl;
}


int main(int argc, char* argv[])
{

  if (argc != 3)
  {
      fprintf(stderr,"Incorrect number of parameters. 2 parameters expected.\n");
      return -1;
  }

  int inference_count = 0;

  try {

      inference_count = std::stoi(std::string(argv[1]));
  }
  catch(std::exception const & e)
  {
     std::cout << "read input parameter error: " << e.what() << std::endl;
  }

  std::string model_name(argv[2]);

  std::map<std::string, std::string> onnx_models_map =
  {
      {"model.onnx", "softmaxout_1"},
      {"mobilenetv2-1.0.onnx", "mobilenetv20_output_flatten0_reshape0"}
  };

  std::map<std::string, std::string> onnx_models_path_map =
  {
      {"model.onnx", "/usr/bin/onnxruntime/examples/unitest/squeezenet/model.onnx"},
      {"mobilenetv2-1.0.onnx", "/usr/bin/onnxruntime/examples/inference/mobilenetv2-1.0.onnx"}
  };

  auto it = onnx_models_map.find(model_name);

  if (it == onnx_models_map.end())
  {
      fprintf(stderr,"Fail to find model %s\n",model_name);
      return -1;
  }

  OrtEnv* env;
  CheckStatus(g_ort->CreateEnv(ORT_LOGGING_LEVEL_WARNING, "test", &env));

  OrtSession* session;

  std::string model_path = onnx_models_path_map[it->first];

  OrtSessionOptions* session_options = NULL;

  CheckStatus(g_ort->CreateSession(env, model_path.c_str(), session_options, &session));

  size_t num_input_nodes;
  OrtStatus* status;
  OrtAllocator* allocator;
  CheckStatus(g_ort->GetAllocatorWithDefaultOptions(&allocator));

  status = g_ort->SessionGetInputCount(session, &num_input_nodes);
  std::vector<const char*> input_node_names(num_input_nodes);
  std::vector<int64_t> input_node_dims;

  printf("Current Model is %s\n",it->first.c_str());
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
    ONNXTensorElementDataType type;
    CheckStatus(g_ort->GetTensorElementType(tensor_info, &type));
    printf("Input %zu : type=%d\n", i, type);

    size_t num_dims = 4;
    printf("Input %zu : num_dims=%zu\n", i, num_dims);
    input_node_dims.resize(num_dims);
    g_ort->GetDimensions(tensor_info, (int64_t*)input_node_dims.data(), num_dims);
    for (size_t j = 0; j < num_dims; j++)
      printf("Input %zu : dim %zu=%jd\n", i, j, input_node_dims[j]);

    g_ort->ReleaseTypeInfo(typeinfo);
  }

  size_t input_tensor_size = 224 * 224 * 3;

  std::vector<float> input_tensor_values(input_tensor_size);
  std::vector<const char*> output_node_names;

  output_node_names.push_back(it->second.c_str());

  // initialize input data with values in [0.0, 1.0]

  int img_sizex, img_sizey, img_channels;

  stbi_uc * img_data = stbi_load("/usr/bin/onnxruntime/examples/images/grace_hopper_224_224.jpg", &img_sizex, &img_sizey, &img_channels, STBI_default);

  struct S_Pixel
  {
      unsigned char RGBA[3];
  };

  const S_Pixel * imgPixels(reinterpret_cast<const S_Pixel *>(img_data));

  const float mean[3]	= { 0.485f, 0.456f, 0.406f };
  const float stddev[3]	= { 0.229f, 0.224f, 0.225f };

  size_t offs = 0;

  for (size_t c = 0; c < 3; c++)
  {
	  for (size_t y = 0; y < 224; y++)
	  {
		  for (size_t x = 0; x < 224; x++, offs++)
		  {
			  const float val((float)imgPixels[y * 224 + x].RGBA[c]/255);

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
  for (int i = 0; i < inference_count; i++)
  {
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
  for (int i = 0; i < 1000; i++)
  {
      result[floatarr[i]] = i;
  }

  std::string filename("/usr/bin/onnxruntime/examples/inference/synset_words.txt");

  if (loadLabelFile(filename) != 0)
  {
      fprintf(stderr,"Fail to open or process file %s\n",filename.c_str());
      return -1;
  }

  int counter = 0;
  for (auto it = result.rbegin(); it != result.rend(); it++)
  {
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

  return 0;
}
