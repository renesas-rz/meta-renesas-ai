/*
 * Copyright (C) 2019 Renesas Electronics Corp. 
 * This file is licensed under the terms of the MIT License
 * This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
*/

#include <assert.h>
#include "onnxruntime_c_api.h"
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <map>
#include <fstream>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

std::map<int,std::string> label_file_map;

void loadLabelFile(std::string label_file_name)
{
    int counter = 0;
    std::ifstream infile(label_file_name);
    std::string line;
    while(std::getline(infile,line))
    {
        label_file_map[counter++] = line;
    }
}

int main(int argc, char* argv[]) 
{
  OrtEnv* env;
  OrtCreateEnv(ORT_LOGGING_LEVEL_WARNING, "test", &env);

  OrtSession* session;

  const char* model_path = "mobilenetv2-1.0.onnx";

  OrtSessionOptions* session_options = NULL;

  OrtCreateSession(env, model_path, session_options, &session);

  size_t num_input_nodes;
  OrtStatus* status;
  OrtAllocator* allocator;
  OrtCreateDefaultAllocator(&allocator);

  status = OrtSessionGetInputCount(session, &num_input_nodes);
  std::vector<const char*> input_node_names(num_input_nodes);
  std::vector<int64_t> input_node_dims;

  printf("Number of inputs = %zu\n", num_input_nodes);

  // iterate over all input nodes
  for (size_t i = 0; i < num_input_nodes; i++) {
    // print input node names
    char* input_name;
    status = OrtSessionGetInputName(session, i, allocator, &input_name);
    printf("Input %zu : name=%s\n", i, input_name);
    input_node_names[i] = input_name;

    // print input node types
    OrtTypeInfo* typeinfo;
    status = OrtSessionGetInputTypeInfo(session, i, &typeinfo);
    const OrtTensorTypeAndShapeInfo* tensor_info = OrtCastTypeInfoToTensorInfo(typeinfo);
    ONNXTensorElementDataType type = OrtGetTensorElementType(tensor_info);
    printf("Input %zu : type=%d\n", i, type);

    size_t num_dims = 4;
    printf("Input %zu : num_dims=%zu\n", i, num_dims);
    input_node_dims.resize(num_dims);
    OrtGetDimensions(tensor_info, (int64_t*)input_node_dims.data(), num_dims);
    for (size_t j = 0; j < num_dims; j++)
      printf("Input %zu : dim %zu=%jd\n", i, j, input_node_dims[j]);

    OrtReleaseTypeInfo(typeinfo);
  }

  OrtReleaseAllocator(allocator);

  size_t input_tensor_size = 224 * 224 * 3;

  std::vector<float> input_tensor_values(input_tensor_size);
  std::vector<const char*> output_node_names = {"mobilenetv20_output_flatten0_reshape0"};

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
  OrtAllocatorInfo* allocator_info;
  OrtCreateCpuAllocatorInfo(OrtArenaAllocator, OrtMemTypeDefault, &allocator_info);
  OrtValue* input_tensor = NULL;
  OrtCreateTensorWithDataAsOrtValue(allocator_info, input_tensor_values.data(), input_tensor_size * sizeof(float), input_node_dims.data(), 4, ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT, &input_tensor);
  assert(OrtIsTensor(input_tensor));
  OrtReleaseAllocatorInfo(allocator_info);

  // score model & input tensor, get back output tensor
  OrtValue* output_tensor = NULL;
  OrtRun(session, NULL, input_node_names.data(), (const OrtValue* const*)&input_tensor, 1, output_node_names.data(), 1, &output_tensor);
  assert(OrtIsTensor(output_tensor));

  // Get pointer to output tensor float values
  float* floatarr;
  OrtGetTensorMutableData(output_tensor, (void**)&floatarr);

  std::map<float,int> result;

  // score the model, and print scores for first 5 classes
  for (int i = 0; i < 1000; i++)
  {
      result[floatarr[i]] = i;
  }

  std::string filename("/usr/bin/onnxruntime/examples/inference/synset_words.txt");

  loadLabelFile(filename);

  int counter = 0;
  for (auto it = result.rbegin(); it != result.rend(); it++)
  {
      counter++;

      if(counter > 6)
          break;
 
      printf("index [%d]: %s :prob [%f]\n",(*it).second,label_file_map[(*it).second].c_str(),(*it).first);
  }

  OrtReleaseValue(output_tensor);
  OrtReleaseValue(input_tensor);
  OrtReleaseSession(session);
  OrtReleaseSessionOptions(session_options);
  OrtReleaseEnv(env);
  printf("Done!\n");
  return 0;
}

