# meta-benchmark

This meta-layer provides benchmark tools for Arm NN SDK, TensorFlow,
TensorFlow Lite, ONNX Runtime and OpenCV.

Each framework has its own benchmark tool.

* For Arm NN SDK, it is armnnBenchmark and armnnTFLiteDelegateBenchmark
* For Google Coral TPU, it is google-coral-tpu-benchmark
* For TensorFlow, it is tensorflowBenchmark
* For TensorFlow-lite, it is tensorflow-lite-benchmark
* For ONNX Runtime, it is onnxruntime_benchmark
* For OpenCV, it is opencv-benchmark.sh

The output of each benchmark tool shows the average inference time and the
standard deviation for each available model, which are printed in the terminal.

The instructions for using these benchmark tools are listed below:

## Arm NN SDK
```bash
cd /usr/bin/armnnBenchmark

# Run inference 30 times
./armnnBenchmark
```
```bash
cd /usr/bin/armnnDelegateBenchmark

# Run inference 30 times on each TfLite model using the ArmNN TfLite Delegate
./run_Delegate_measurement.py test_model_list_armnnDelegate.txt \
/home/root/models/tensorflowlite/ 30 2 tflite warning
```

## Google Coral TPU
```bash
cd /usr/bin/google-coral-benchmark

# Resnet (inference run 30 times)
./run_TPU_measurement.py test_file_list_Resnet.txt \
/home/root/models/google-coral/Resnet/ 30

# MobileNet (inference run 30 times)
./run_TPU_measurement.py test_file_list_MobileNet.txt \
/home/root/models/google-coral/Mobile_Net_Model/ 30

# Inception (inference run 30 times)
./run_TPU_measurement.py test_file_list_Inception.txt \
/home/root/models/google-coral/Mobile_Inception_Model/ 30

# EfficientNet (inference run 30 times)
./run_TPU_measurement.py test_file_list_EfficientNet.txt \
/home/root/models/google-coral/Mobile_Efficient_Net_Model/ 30
```

## TensorFlow
```bash
cd /usr/bin/tensorflowBenchmark

# Inception v3 (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV3/inception_v3_2016_08_28_frozen.pb" \
--model_type="float32" \
--labels="/home/root/models/tensorflow/InceptionV3/imagenet_slim_labels.txt"

# Test Inception v3 quant (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV3_Quant/inception_v3_2016_08_28_frozen_Quant.pb" \
--model_type="uint8" \
--labels="/home/root/models/tensorflow/InceptionV3_Quant/imagenet_slim_labels.txt"

# Inception v4 (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV4/inception_v4.pb" \
--model_type="float32" \
--labels="/home/root/models/tensorflow/InceptionV4/imagenet_slim_labels.txt" \
--output_layer="InceptionV4/Logits/Predictions"

# Test Inception v4 quant (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV4/inception_v4_299_quant_frozen.pb" \
--model_type="uint8" \
--labels="/home/root/models/tensorflow/InceptionV4/imagenet_slim_labels.txt" \
--output_layer="InceptionV4/Logits/Predictions"
```

## TensorFlow Lite
```bash
cd /usr/bin/tensorflow-lite-benchmark

# Test on iwg20m, iwg22m, hihope-rzg2n or ek874 with 2 cores
(inference run 30 times)
./run_TF_measurement.py test_file_list_Inception_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV3/ 30 2

# Test on iwg21m with 4 cores (inference run 30 times)
./run_TF_measurement.py test_file_list_Inception_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV3/ 30 4

# Test on hihope-rzg2m with 6 cores (inference run 30 times)
./run_TF_measurement.py test_file_list_Inception_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV3/ 30 6
```

Other models can also be tested such as MnasNet, MobileNet v1, MobileNet v2,
Nasnet, Resnet and Squeezenet. The steps to run benchmarking for these models
are almost the same as above.

Outputting metrics in a parsable format can also be completed by adding the
"benchmark" flag. For example:
```bash
./run_TF_measurement.py test_file_list_Mobile_Net_V2.txt \
/home/root/models/tensorflowlite/Mobile_Net_V2_Model/ 30 2 benchmark
```

Some examples can be found below (assuming 2 cores and inference 30 times):

```bash
./run_TF_measurement.py test_file_list_Inception_Net_V4.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV4/ 30 2

./run_TF_measurement.py test_file_list_Mnasnet.txt \
/home/root/models/tensorflowlite/MnasNet/ 30 2

./run_TF_measurement.py test_file_list_Mobile_Net_V1.txt \
/home/root/models/tensorflowlite/Mobile_Net_V1_Model/ 30 2

./run_TF_measurement.py test_file_list_Mobile_Net_V2.txt \
/home/root/models/tensorflowlite/Mobile_Net_V2_Model/ 30 2

./run_TF_measurement.py test_file_list_Mobile_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_Net_V3_Model/ 30 2

./run_TF_measurement.py test_file_list_Nasnet.txt \
/home/root/models/tensorflowlite/NasNet/ 30 2

./run_TF_measurement.py test_file_list_Resnet.txt \
/home/root/models/tensorflowlite/Resnet/ 30 2

./run_TF_measurement.py test_file_list_Squeezenet.txt \
/home/root/models/tensorflowlite/Squeezenet/ 30 2
```

## ONNX Runtime
```bash
cd /usr/bin/onnxruntime_benchmark

# Run inference 30 times
./onnxruntime_benchmark.sh
```

## OpenCV
```bash
cd /usr/bin/opencvBenchmark

# Run inference 30 times
./opencv-benchmark.sh
```

#### Run models individually
```bash
# Run script with --help for information
python3 alexnet.py --help

usage: alexnet.py [-h] [--count INFERENCE COUNT] Model Label Image

AlexNet Inference

positional arguments:
  Model
  ModelType
  Label
  Image

optional arguments:
  -h, --help            show this help message and exit
  --count INFERENCE COUNT
                        Change inference count, defaults to 30

# Example command with default inference count of 30
python3 alexnet.py alexnet-owt-4df8aa71.pth float32 imagenet_classes.txt grace_hopper.jpg

# Number of inference runs can be changed with --count
python3 alexnet.py alexnet-owt-4df8aa71.pth float32 imagenet_classes.txt grace_hopper.jpg --count 50
```

#### More Examples
The commands to run benchmarking for these models are similar to
that above.

```bash
# MnasNet
python3 mnasnet.py mnasnet1.0_top1_73.512-f206786ef8.pth float32 imagenet_classes.txt grace_hopper.jpg

# MobileNet v2
python3 mobilenet_v2.py mobilenet_v2-b0353104.pth float32 imagenet_classes.txt grace_hopper.jpg

# ResNet
python3 resnet152.py resnet152-b121ed2d.pth float32 imagenet_classes.txt grace_hopper.jpg

#Inception v3
python3 inception_v3.py inception_v3_google-1a9a5a14.pth float32 imagenet_classes.txt grace_hopper.jpg
```

## Sample Build Configurations
Two sets of configuration templates are included in the *templates* directory.
These allow different frameworks that use compatible dependencies to be easily
built together.

### armnn+coral+tf+tfl
This incorporates:
* ArmNN SDK
* TensorFlow
* TensorFlow Lite (including Google Coral TPU support)
* Various pre-built models that can be used for testing/benchmarking

### onnx+opencv
This incorporates:
* ONNX Runtime
* OpenCV
* Various pre-built models that can be used for testing/benchmarking
