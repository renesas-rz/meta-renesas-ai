# meta-benchmark

This meta-layer provides benchmark tools for Arm NN SDK, Caffe2, TensorFlow,
TensorFlow Lite, ONNX Runtime and OpenCV.

Each framework has its own benchmark tool.

* For Arm NN SDK, it is armnnBenchmark
* For Caffe2, it is caffe2_Benchmark.sh
* For Google Coral TPU, it is google-coral-tpu-benchmark
* For TensorFlow, it is tensorflowBenchmark
* For TensorFlow-lite, it is tensorflow-lite-benchmark
* For ONNX Runtime, it is onnxruntime_benchmark
* For OpenCV, it is opencv-benchmark.sh
* For PyTorch, it is pytorch-benchmark.sh

The output of each benchmark tool shows the average inference time and the
standard deviation for each available model, which are printed in the terminal.

The instructions for using these benchmark tools are listed below:

## Arm NN SDK
```bash
cd /usr/bin/armnnBenchmark

# Run inference 30 times
./armnnBenchmark
```

## Caffe2
```bash
cd /usr/bin/caffe2Benchmark

# Run inference 30 times
./caffe2_Benchmark.sh
```

## Google Coral TPU
```bash
cd /usr/bin/google-coral-benchmark

# Resnet (inference run 30 times)
./run_TPU_measurement.py test_file_list_Resnet.txt \
/home/root/models/google-coral/Resnet/ 30

# MobileNet V2 (inference run 30 times)
./run_TPU_measurement.py test_file_list_MobileNet_v2.txt \
/home/root/models/google-coral/Mobile_Net_V2_Model/ 30
```

## TensorFlow
```bash
cd /usr/bin/tensorflowBenchmark

# Inception v3 (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV3/inception_v3_2016_08_28_frozen.pb" \
--labels="/home/root/models/tensorflow/InceptionV3/imagenet_slim_labels.txt"

# Test Inception v3 quant (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV3_Quant/inception_v3_2016_08_28_frozen_Quant.pb" \
--labels="/home/root/models/tensorflow/InceptionV3_Quant/imagenet_slim_labels.txt"

# Inception v4 (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV4/inception_v4.pb" \
--labels="/home/root/models/tensorflow/InceptionV4/imagenet_slim_labels.txt" \
--output_layer="InceptionV4/Logits/Predictions"

# Test Inception v4 quant (inference run 30 times)
./tensorflowBenchmark --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" \
--graph="/home/root/models/tensorflow/InceptionV4/inception_v4_299_quant_frozen.pb" \
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

## PyTorch
```bash
cd /usr/bin/pytorch-benchmark

# Run script that runs benchmarks for all models
# AlexNet, MnasNet, MobileNet v2, ResNet, and Inception v3
./pytorch-benchmark.sh
```

#### Run models individually
```bash
# Run script with --help for information
python3 alexnet.py --help

usage: alexnet.py [-h] [--count INFERENCE COUNT] Model Label Image

AlexNet Inference

positional arguments:
  Model
  Label
  Image

optional arguments:
  -h, --help            show this help message and exit
  --count INFERENCE COUNT
                        Change inference count, defaults to 30

# Example command with default inference count of 30
python3 alexnet.py alexnet-owt-4df8aa71.pth imagenet_classes.txt grace_hopper.jpg

# Number of inference runs can be changed with --count
python3 alexnet.py alexnet-owt-4df8aa71.pth imagenet_classes.txt grace_hopper.jpg --count 50
```
#### Other models
Other models can also be tested such as MnasNet, MobileNet v2,
ResNet and Inception v3.

Please note that to run Inception v3 models, python3-scipy must be added to your image.

For RZ/G1 devices:

 - Uncomment the following line in the `local.conf`:
```
require ${META_PYTORCH_DIR}/templates/python3-scipy/python3-scipy_RZ-G1.conf
```

For RZ/G2 devices:

 - Uncomment the following line in the `local.conf`:
```
#require ${META_PYTORCH_DIR}/templates/python3-scipy/python3-scipy_RZ-G2.conf
```
 - Comment the following line in the `local.conf`:
```
INCOMPATIBLE_LICENSE = "GPLv3 GPLv3+"
```
This will enable GPLv3 licensed software, please make sure you fully understand the
implications of enabling license GPLv3 by reading the relevant documents
(e.g. https://www.gnu.org/licenses/gpl-3.0.en.html).

#### More Examples
The commands to run benchmarking for these models are similar to
that above.

```bash
# MnasNet
python3 mnasnet.py mnasnet1.0_top1_73.512-f206786ef8.pth imagenet_classes.txt grace_hopper.jpg

# MobileNet v2
python3 mobilenet_v2.py mobilenet_v2-b0353104.pth imagenet_classes.txt grace_hopper.jpg

# ResNet
python3 resnet152.py resnet152-b121ed2d.pth imagenet_classes.txt grace_hopper.jpg

#Inception v3
python3 inception_v3.py inception_v3_google-1a9a5a14.pth imagenet_classes.txt grace_hopper.jpg
```
