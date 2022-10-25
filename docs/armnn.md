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

**armnn-examples**: *UnitTests*, *SimpleSample*, *RenesasSample-Armnn*\
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
Running 3360 test cases...

*** No errors detected
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
INFO: TfLiteArmnnDelegate: Created TfLite ArmNN delegate.
Info: ArmNN v28.0.0
...
[doctest] test cases:   195 |   195 passed | 0 failed | 424 skipped
[doctest] assertions: 15487 | 15487 passed | 0 failed |
[doctest] Status: SUCCESS!
[doctest] doctest version is "2.4.0"
[doctest] run with "--help" for options
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
INFO: TfLiteArmnnDelegate: Created TfLite ArmNN delegate.
===============================================================================
[doctest] test cases:   226 |   226 passed | 0 failed | 393 skipped
[doctest] assertions: 18543 | 18543 passed | 0 failed |
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
Info: ArmNN v28.0.0
Info: Initialization time: 19.73 ms.
Info: Network parsing time: 149.43 ms.
Info: Optimization time: 7.52 ms.
Info: Network loading time: 220.87 ms.
Info: Execution time: 63.93 ms.
Info: Execution time: 49.87 ms.
Info: = Prediction values for test #0
Info: Top(1) prediction is 653 with value: 0.753906
Info: Top(2) prediction is 907 with value: 0.140625
Info: Top(3) prediction is 458 with value: 0.0195312
Info: Top(4) prediction is 466 with value: 0.0117188
Info: Top(5) prediction is 452 with value: 0.00390625
Info: Total time for 1 test cases: 0.050 seconds
Info: Average time per test case: 50.043 ms
Info: Overall accuracy: 1.000
Info: Shutdown time: 3.68 ms.
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
Info: ArmNN v28.0.0
Info: Initialization time: 32.87 ms.
Info: Network parsing time: 210.76 ms.
Info: Optimization time: 239.95 ms.
Info: Network loading time: 610.70 ms.
Info: Execution time: 801.13 ms.
Info: Execution time: 766.09 ms.
Info: = Prediction values for test #0
Info: Top(1) prediction is 652 with value: 13.1776
Info: Top(2) prediction is 457 with value: 11.1157
Info: Top(3) prediction is 451 with value: 9.20583
Info: Top(4) prediction is 439 with value: 8.73521
Info: Top(5) prediction is 400 with value: 7.13392
Info: Execution time: 766.69 ms.
Info: = Prediction values for test #1
Info: Top(1) prediction is 652 with value: 13.1776
Info: Top(2) prediction is 457 with value: 11.1157
Info: Top(3) prediction is 451 with value: 9.20583
Info: Top(4) prediction is 439 with value: 8.73521
Info: Top(5) prediction is 400 with value: 7.13392
Info: Execution time: 766.77 ms.
Info: = Prediction values for test #2
Info: Top(1) prediction is 652 with value: 13.1776
Info: Top(2) prediction is 457 with value: 11.1157
Info: Top(3) prediction is 451 with value: 9.20583
Info: Top(4) prediction is 439 with value: 8.73521
Info: Top(5) prediction is 400 with value: 7.13392
Info: Total time for 3 test cases: 2.300 seconds
Info: Average time per test case: 766.689 ms
Info: Overall accuracy: 1.000
Info: Shutdown time: 14.03 ms.
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
$ ./ExecuteNetwork -f tflite-binary -i input \
  -o MobilenetV1/Predictions/Reshape_1 \
  -d /usr/bin/armnn/examples/images/rsz_grace_hopper.csv -s 1,224,224,3 \
  -m /usr/bin/armnn/examples/tensorflow-lite/models/mobilenet_v1_1.0_224_quant.tflite \
  -c CpuAcc
```
2. It prints out the ouput tensor, for example,
```
Info: ArmNN v28.0.0
Info: Initialization time: 24.61 ms.
Info: Network parsing time: 148.62 ms.
Info: Optimization time: 7.51 ms.
Info: Network loading time: 223.71 ms.
Info: Execution time: 64.12 ms.

MobilenetV1/Predictions/Reshape_1: 0.000000 0.000000 0.000000...
Info:
Inference time: 64.27 ms

Info: Shutdown time: 3.72 ms.
```

## Supported Frameworks and Operators
The Arm NN SDK supports the following operators:

TensorFlow Lite:
**https://arm-software.github.io/armnn/22.02/parsers.xhtml#S6_tf_lite_parser**

ONNX:
**https://arm-software.github.io/armnn/22.02/parsers.xhtml#S5_onnx_parser**
