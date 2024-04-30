# TensorFlow Lite

TensorFlow Lite is TensorFlow’s lightweight solution for mobile and embedded
devices. It enables on-device machine learning inference with low latency and
a small binary size. TensorFlow Lite uses many techniques for achieving low
latency such as optimizing the kernels for mobile apps, pre-fused activations,
and quantized kernels that allow smaller and faster (fixed-point math) models.


The official website is:
**https://www.tensorflow.org/lite**


In order to add TensorFlow Lite support to your project, make sure
*tensorflow-lite* is listed as a dependency to your recipe/package.
Listing *tensorflow-lite-staticdev* and *tensorflow-dev* in *IMAGE\_INSTALL*
variable could be beneficial when you just want to populate an SDK for
developing an application based on TensorFlow Lite. Adding
*tensorflow-lite-python* will include the Python TfLite module in
the RFS/SDK. Note that the Python bindings have the XNNPack Delegate
built in and enabled.


After the build is complete the static C++ TensorFlow Lite library
(*libtensorflow-lite.a*) will be generated.


The library can be verified with the TensorFlow Lite image classification sample
application named *label_image* which is included in the build (included by
package *tensorflow-lite*). The sample application is installed under
*/usr/bin/tensorflow-lite/examples/*.


To use *label_image* (C++):
1. Download model data:
`wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip`
2. Extract to */usr/bin/tensorflow-lite/examples/*
3. Execute  *label_image* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
./label_image
```


The output of a healthy execution should look like the following:
```
INFO: Loaded model ./mobilenet_quant_v1_224.tflite
INFO: resolved reporter
INFO: invoked
INFO: average time: 44.46 ms
INFO: 0.701961: 458 bow tie
INFO: 0.262745: 653 military uniform
INFO: 0.0117647: 835 suit
INFO: 0.00784314: 611 jersey
INFO: 0.00392157: 922 book jacket
```

To use *label_image* (Python):
1. Execute *label_image* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
python3 label_image.py \
--model_file /home/root/models/tensorflowlite/Mobile_Net_V1_Model/mobilenet_v1_1.0_224_quant.tflite \
--label_file /home/root/models/tensorflowlite/Mobile_Net_V1_Model/labels.txt \
--image /usr/bin/tensorflow-lite/examples/grace_hopper.bmp \
--num_threads 2
```


The output of a healthy execution should look like the following:
```
0.658824: military uniform
0.149020: Windsor tie
0.039216: bow tie
0.027451: mortarboard
0.019608: bulletproof vest
time: 70.138ms
```


To use *benchmark_model*:
1. Download model data:
`wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip`
2. Extract to */usr/bin/tensorflow-lite/examples/*
3. Execute  *benchmark_model* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
./benchmark_model --graph=mobilenet_quant_v1_224.tflite
```


The output of a healthy execution should look like the following:
```
INFO: STARTING!
INFO: Log parameter values verbosely: [0]
INFO: Graph: [mobilenet_quant_v1_224.tflite]
INFO: Loaded model mobilenet_quant_v1_224.tflite
INFO: The input model file size (MB): 4.2761
INFO: Initialized session in 5.617ms.
INFO: Running benchmark for at least 1 iterations and at least 0.5 seconds but terminate if exceeding 150 seconds.
INFO: count=5 first=119340 curr=102705 min=102705 max=119340 avg=107466 std=6256

INFO: Running benchmark for at least 50 iterations and at least 1 seconds but terminate if exceeding 150 seconds.
INFO: count=50 first=103238 curr=102789 min=102639 max=103238 avg=102879 std=119

INFO: Inference timings in us: Init: 5617, First inference: 119340, Warmup (avg): 107466, Inference (avg): 102879
INFO: Note: as the benchmark tool itself affects memory footprint, the following is only APPROXIMATE to the actual memory footprint of the model at runtime. Take the information at your discretion.
INFO: Memory footprint delta from the start of the tool (MB): init=5 overall=11.2695
```


For more information about the benchmark tool, please refer to
**https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/tools/benchmark**


To use *minimal*:
1. Download model data:
`wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip`
2. Extract to */usr/bin/tensorflow-lite/examples/*
3. Execute  *minimal* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
./minimal mobilenet_quant_v1_224.tflite
```


The output of a healthy execution will read the model file and perform
inference.


## Notes ##
**Using Large Models**\
Due to the limited memory size on some platforms, large pre-trained models could
cause out of memory issues. To overcome this memory limitation, a swap file can
used. Please see the top level *README.md* file for details.
