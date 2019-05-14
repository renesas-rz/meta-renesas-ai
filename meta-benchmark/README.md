# meta-benchmark

This meta-layer provides benchmark tools for Arm NN SDK, Caffe2, TensorFlow,
TensorFlow Lite and Onnx Runtime.

Each framework has its own benchmark tool.

For Arm NN SDK, it is armnnBenchmark
For Caffe2, it is caffe2Benchmark
For TensorFlow, it is tensorflowBenchmark
For TensorFlow-lite, it is tensorflow-lite-benchmark
For ONNX Runtime, it is onnxruntime_benchmark

The output of each benchmark tool shows the average inference
time and the standard deviation for each available model, which 
are printed in the terminal.

The instruction of using these benchmark tools is listed below:

## Arm NN SDK
```bash
cd /usr/bin/armnnBenchmark

# Run inference 30 times
./armnnBenchmark
```

## Caffe2
```bash
export PYTHONPATH=$PYTHONPATH:/usr
cd /usr/bin/caffe2Benchmark

# Run inference 1000 times
./caffe2Benchmark.py grace_hopper.jpg
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

# Test on iwg20m or iwg22m with 2 cores (inference run 30 times)
./run_TF_measurement.py test_file_list_Inception_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV3/ 30 2

# Test on iwg21m with 4 cores (inference run 30 times)
./run_TF_measurement_4_cores.py test_file_list_Inception_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV3/ 30 4
```

## ONNX Runtime
```bash
cd /usr/bin/onnxruntime_benchmark

# Run inference 30 times
./onnxruntime_benchmark.sh
```
