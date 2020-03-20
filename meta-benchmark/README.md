# meta-benchmark

This meta-layer provides benchmark tools for Arm NN SDK, Caffe2, TensorFlow,
TensorFlow Lite, ONNX Runtime and OpenCV.

Each framework has its own benchmark tool.

* For Arm NN SDK, it is armnnBenchmark
* For Caffe2, it is caffe2_Benchmark.sh
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

## Caffe2
```bash
cd /usr/bin/caffe2Benchmark

# Run inference 30 times
./caffe2_Benchmark.sh
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
Nasnet and Squeezenet. The steps to run benchmarking for these models are almost
the same as above.

Some examples can be found below (assuming 2 cores and inference 30 times):

```bash
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
