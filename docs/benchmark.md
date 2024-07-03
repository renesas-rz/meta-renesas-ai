# Benchmarking

The recipes in the recipes-benchmark directory provide benchmark tools for
Arm NN SDK, TensorFlow Lite and ONNX Runtime.

Each framework has its own benchmark tool.

* For Arm NN SDK, it is *armnnBenchmark*
* For TensorFlow Lite, it is *tensorflow-lite-benchmark*
* For ONNX Runtime, it is *onnxruntime_benchmark*

*tfLiteDelegateBenchmark* is also provided as a tool for benchmarking the
TensorFlow Lite delegates provided by various frameworks.

The output of each benchmark tool shows the average inference time and the
standard deviation for each available model, which are printed in the terminal.

The instructions for using these benchmark tools are listed below:

## Arm NN SDK
```bash
cd /usr/bin/armnnBenchmark

# Run inference 30 times
./armnnBenchmark -l model_list.txt
```

## TensorFlow Lite
```bash
cd /usr/bin/tensorflow-lite-benchmark

# Test on hihope-rzg2n or ek874 with 2 cores
(inference run 30 times)
./run_TF_measurement.py test_file_list_Inception_Net_V3.txt \
/home/root/models/tensorflowlite/Mobile_InceptionV3/ 30 2

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

## TensorFlow Lite Delegate
```bash
cd /usr/bin/tfLiteDelegateBenchmark

# Run inference 30 times on each TfLite model using the ArmNN Delegate
./run_Delegate_measurement.py -f /usr/bin/tfLiteDelegateBenchmark/test_model_list_delegate.txt \
                                        --base_dir /home/root/models/tensorflowlite/ \
                                        --iterations 30 --threads 2 --delegate armnn \
                                        --armnn_log_level warning --compute CpuAcc

# Run inference 30 times on each TfLite model using the XNNPack Delegate
./run_Delegate_measurement.py --models_file /usr/bin/tfLiteDelegateBenchmark/test_model_list_delegate.txt \
                                        --base_dir /home/root/models/tensorflowlite/ --iterations 30 \
                                        --threads 2 --delegate xnnpack


# Run inference 30 times on each TfLite model using the ArmNN Delegate and the GPU Accelerator
./run_Delegate_measurement.py -f /usr/bin/tfLiteDelegateBenchmark/test_model_list_delegate.txt \
                                        --base_dir /home/root/models/tensorflowlite/ \
                                        --iterations 30 --threads 2 --delegate armnn \
                                        --armnn_log_level warning --compute GpuAcc
```

## ONNX Runtime
```bash
cd /usr/bin/onnxruntime_benchmark

# Run inference 30 times
./onnxruntime_benchmark.sh
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
