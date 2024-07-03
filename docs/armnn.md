# ArmNN
The Arm Neural Network SDK is a set of open-source Linux software and tools that
enables machine learning workloads on power-efficient devices. It provides a
bridge between existing neural network frameworks and power-efficient Arm Cortex
CPUs, Arm Mali GPUs or the Arm Machine Learning processor.

Arm NN SDK utilizes the Compute Library to target programmable cores, such as
Cortex-A CPUs and Mali GPUs, as efficiently as possible.

The official website is:\
**https://developer.arm.com/products/processors/machine-learning/arm-nn**

## Build Configuration
**armnn-tensorflow-lite**: Add as a dependency to your recipe/package to add Arm
NN TensorFlow Lite support and the related examples code.\
**armnn-dev**, **armnn-tensorflow-lite-dev**:  Useful to add to *IMAGE_INSTALL*
when creating an SDK for TensorFlow Lite application development.

**armnn-onnx**: Add as a dependency to your recipe/package to add Arm NN ONNX
support.\
**armnn-onnx-examples**: Add to *IMAGE_INSTALL* to populate Arm NN's ONNX parser
example code in your build.\
**armnn-dev**, **armnn-onnx-dev**:  Useful to add to *IMAGE_INSTALL* when
creating an SDK for ONNX application development.

**armnn-examples**: Add to *IMAGE_INSTALL* to add example applications that make
use of Arm NN.

## Build Output
Once the build is complete the following libraries are generated and added to
*/usr/lib*:\
Arm NN: libarmnn.so\
TensorFlow Lite Arm NN parser: libarmnnTfLiteParser.so\
ONNX Arm NN parser: libarmnnOnnxParser.so

Each library can be verified with the relevant sample application below,
if the relevant *-examples* was included in the build (see Build Configuration
above).

**armnn-examples**: *UnitTests*, *SimpleSample*, *RenesasSample-Armnn*, *ExecuteNetwork*\
**armnn-tensorflow-lite**: *TfLiteMobilenetQuantized-Armnn*\
**armnn-onnx-examples**: *OnnxMobileNet-Armnn*

The sample applications are installed under */usr/bin/armnn/examples/*.

## Using the Sample Applications
### UnitTests
1. Export environment variable *ARMNN_TF_LITE_SCHEMA_PATH*:
```
$ export ARMNN_TF_LITE_SCHEMA_PATH="/usr/include/tensorflow/lite/schema/schema.fbs"
```
2. Execute *UnitTests* by running the following commands:
```
$ cd /usr/bin/armnn/examples/UnitTests/
$ ./UnitTests -- --dynamic-backend-build-dir "/usr/bin/armnn/examples/UnitTests/"
```
3. The output of a healthy execution should look like the following:
```
[doctest] doctest version is "2.4.6"
[doctest] run with "--help" for options
...
===============================================================================
[doctest] test cases:   4445 |   4445 passed | 0 failed | 3 skipped
[doctest] assertions: 808108 | 808108 passed | 0 failed |
[doctest] Status: SUCCESS!
```

### DelegateUnitTests
1. Execute *DelegateUnitTests* with CPU Acceleration by running the following commands:
```
$ cd /usr/bin/armnn/examples/DelegateUnitTests
$ ./DelegateUnitTests --test-suite=*CpuAcc*
```
2. The output of a healthy execution should look like the following:
```
[doctest] doctest version is "2.4.6"
[doctest] run with "--help" for options
...
===============================================================================
[doctest] test cases:   7 |   7 passed | 0 failed | 315 skipped
[doctest] assertions: 628 | 628 passed | 0 failed |
[doctest] Status: SUCCESS!
```
3. Execute *DelegateUnitTests* with CPU Reference by running the following commands:
```
$ cd /usr/bin/armnn/examples/DelegateUnitTests
$ ./DelegateUnitTests --test-suite=*CpuRef*
```
4. The output of a healthy execution should look like the following:
```
[doctest] doctest version is "2.4.6"
[doctest] run with "--help" for options
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Created TfLite ArmNN delegate.
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
INFO: TfLiteArmnnDelegate: Added backend CpuAcc
INFO: TfLiteArmnnDelegate: Added backend CpuRef
===============================================================================
[doctest] test cases:   21 |   21 passed | 0 failed | 301 skipped
[doctest] assertions: 2052 | 2052 passed | 0 failed |
[doctest] Status: SUCCESS!
```

### SimpleSample
In this sample application the user's single input number is multiplied by 1.0f
using a fully connected layer with a single neuron to produce an output number
that is the same as the input.

1. Execute *SimpleSample* by running the following commands:
```
$ cd /usr/bin/armnn/examples/SampleApp/
$ ./SimpleSample
```

2. The output of a healthy execution should look like the following:
```
Please enter a number:
$ 1
Your number was 1
```

### TfLiteMobilenetQuantized-Armnn
1. Execute *TfLiteMobilenetQuantized-Armnn* by running the following commands:

```
$ cd /usr/bin/armnn/examples/tensorflow-lite
$ ./TfLiteMobilenetQuantized-Armnn -d /usr/bin/armnn/examples/images/ \
  --model-dir /usr/bin/armnn/examples/tensorflow-lite/models/ \
  --compute CpuAcc
```

2. The output of a healthy execution should look like the following:
```
Info: ArmNN v33.1.0
Info: Initialization time: 0.16 ms.
Info: Network parsing time: 111.71 ms.
Info: Optimization time: 7.64 ms.
Info: Network loading time: 38.47 ms.
Info: Execution time: 193.45 ms.
Info: Execution time: 59.93 ms.
Info: = Prediction values for test #0
Info: Top(1) prediction is 653 with value: 0.753906
Info: Top(2) prediction is 907 with value: 0.140625
Info: Top(3) prediction is 458 with value: 0.0195312
Info: Top(4) prediction is 466 with value: 0.0117188
Info: Top(5) prediction is 452 with value: 0.00390625
Info: Total time for 1 test cases: 0.060 seconds
Info: Average time per test case: 60.030 ms
Info: Overall accuracy: 1.000
Info: Shutdown time: 1.89 ms.
```

### OnnxMobileNet-Armnn
1. Execute *OnnxMobileNet-Armnn* by running the following commands:
```
$ cd /usr/bin/armnn/examples/onnx
$ ./OnnxMobileNet-Armnn -d /usr/bin/armnn/examples/images/ \
  --model-dir /usr/bin/armnn/examples/onnx/models/ \
  --compute CpuAcc
```

2. The output of a healthy execution should look like the following:
```
Info: ArmNN v33.1.0
Info: Initialization time: 0.17 ms.
Info: Network parsing time: 163.46 ms.
Info: Optimization time: 122.46 ms.
Info: Network loading time: 237.05 ms.
Info: Execution time: 591.39 ms.
Info: Execution time: 377.22 ms.
Info: = Prediction values for test #0
Info: Top(1) prediction is 652 with value: 13.1776
Info: Top(2) prediction is 457 with value: 11.1157
Info: Top(3) prediction is 451 with value: 9.20581
Info: Top(4) prediction is 439 with value: 8.7352
Info: Top(5) prediction is 400 with value: 7.13391
Info: Execution time: 378.35 ms.
Info: = Prediction values for test #1
Info: Top(1) prediction is 652 with value: 13.1776
Info: Top(2) prediction is 457 with value: 11.1157
Info: Top(3) prediction is 451 with value: 9.20581
Info: Top(4) prediction is 439 with value: 8.7352
Info: Top(5) prediction is 400 with value: 7.13391
Info: Execution time: 376.16 ms.
Info: = Prediction values for test #2
Info: Top(1) prediction is 652 with value: 13.1776
Info: Top(2) prediction is 457 with value: 11.1157
Info: Top(3) prediction is 451 with value: 9.20581
Info: Top(4) prediction is 439 with value: 8.7352
Info: Top(5) prediction is 400 with value: 7.13391
Info: Total time for 3 test cases: 1.132 seconds
Info: Average time per test case: 377.343 ms
Info: Overall accuracy: 1.000
Info: Shutdown time: 7.58 ms.
```

### RenesasSample-Armnn
*RenesasSample-Armnn* is a inference framework designed by Renesas to
demonstrate how to use the Arm NN SDK API in a generic way.

1. Execute *RenesasSample-Armnn* by running the following commands:
```
$ cd /usr/bin/armnn/examples/RenesasSample-Armnn/
$ ./RenesasSample-Armnn
```

2. The following models will be run automatically:
* TensorFlow Lite: mobilenet quant v1.0.224

3. The output of a healthy execution should look like the following:
```
====================
current model is mobilenet_v1_1.0_224_quant.tflite
Info: ArmNN v33.1.0
Info: Initialization time: 0.13 ms.
Info: Network parsing time: 78.80 ms.
Info: Optimization time: 7.53 ms.
Info: Network loading time: 38.51 ms.
Quant Model is loaded
Scale 0.007812
Offset 128
Info: Execution time: 190.01 ms.
Info: Execution time: 59.45 ms.
Info: Execution time: 59.27 ms.
Info: Execution time: 60.07 ms.
Info: Execution time: 59.93 ms.
Info: Execution time: 59.95 ms.
Info: Execution time: 60.75 ms.
Info: Execution time: 59.65 ms.
Info: Execution time: 60.11 ms.
Info: Execution time: 59.20 ms.
Info: Execution time: 59.17 ms.
Info: Execution time: 59.89 ms.
Info: Execution time: 59.55 ms.
Info: Execution time: 59.40 ms.
Info: Execution time: 59.16 ms.
Info: Execution time: 59.48 ms.
Info: Execution time: 59.30 ms.
Info: Execution time: 59.23 ms.
Info: Execution time: 59.74 ms.
Info: Execution time: 60.13 ms.
Info: Execution time: 59.90 ms.
Info: Execution time: 59.74 ms.
Info: Execution time: 59.26 ms.
Info: Execution time: 59.77 ms.
Info: Execution time: 60.38 ms.
Info: Execution time: 60.35 ms.
Info: Execution time: 59.86 ms.
Info: Execution time: 59.94 ms.
Info: Execution time: 59.83 ms.
Info: Execution time: 60.41 ms.
Info: Execution time: 59.43 ms.
Total Time Takes 1795.1 ms
Average Time Takes 59.8365 ms
Standard Deviation 0.412387
= Prediction values for test Top(1) prediction is 653 with confidence: 75.3906%Result is military uniform
Top(2) prediction is 458 with confidence: 1.95312%Result is bow tie, bow-tie, bowtie
Top(3) prediction is 452 with confidence: 0.390625%Result is bolo tie, bolo, bola tie, bola
Top(4) prediction is 0 with confidence: 0%Result is background
Info: Shutdown time: 1.90 ms.
```

### ExecuteNetwork
*ExecuteNetwork* is a generic model inference test application,
which takes any model and any input tensor, and simply
prints out the output tensor. Renesas provides a sample input
tensor file called "rsz_grace_hopper.csv", which can be used
for any model (whose operator is supported in Armnn) that
accepts 224 X 224 input tensor size. Run with no arguments
to see command-line help for more information.

For example, for mobilenet_v1_1.0_224:

1. Execute *ExecuteNetwork* by running the following commands:
```
$ cd /usr/bin/armnn/examples/ExecuteNetwork/
$ ./ExecuteNetwork -c CpuAcc\
  -d /usr/bin/armnn/examples/images/rsz_grace_hopper.csv \
  -m /usr/bin/armnn/examples/tensorflow-lite/models/mobilenet_v1_1.0_224_quant.tflite \
```
2. It prints out the ouput tensor, for example,
```
Info: ArmNN v33.1.0
Info: Initialization time: 0.13 ms.
Info: Optimization time: 8.84 ms
===== Network Info =====
Inputs in order:
input, [1,224,224,3], QAsymmU8 Quantization Offset: 128 Quantization scale: 0.0078125
Outputs in order:
MobilenetV1/Predictions/Reshape_1, [1,1001], QAsymmU8 Quantization Offset: 0 Quantization scale: 0.00390625
Info: Inferences began at: (1600598977135723166 ns) Sun Sep 20 10:49:37 2020
Info: Execution time: 201.51 ms.
MobilenetV1/Predictions/Reshape_1: 0 0 0...
Info: Inference time: 201.59 ms
Info: Inferences ended at: (1600598977337754294 ns) Sun Sep 20 10:49:37 2020
Info: Shutdown time: 1.88 ms.
```

## Supported Frameworks and Operators
The Arm NN SDK supports the following operators:

TensorFlow Lite:
**https://arm-software.github.io/armnn/24.05/parsers.html#S6_tf_lite_parser**

ONNX:
**https://arm-software.github.io/armnn/24.05/parsers.html#S5_onnx_parser**
