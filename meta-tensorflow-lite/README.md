# meta-tensorflow-lite

TensorFlow Lite is TensorFlow’s lightweight solution for mobile and embedded
devices. It enables on-device machine learning inference with low latency and
a small binary size. TensorFlow Lite uses many techniques for achieving low
latency such as optimizing the kernels for mobile apps, pre-fused activations,
and quantized kernels that allow smaller and faster (fixed-point math) models.


The official website is:  
**https://www.tensorflow.org/mobile/tflite/**


This Yocto/OpenEmbedded meta-layer provides TensorFlow Lite support for the
RZ/G1 family of System on Chips.


In order to add TensorFlow Lite support to your project, make sure
*tensorflow-lite* is listed as a dependency to your recipe/package.
Listing *tensorflow-lite-staticdev* and *tensorflow-dev* in *IMAGE\_INSTALL*
variable could be beneficial when you just want to populate an SDK for
developing an application based on TensorFlow Lite.


After the build is complete the static C++ TensorFlow Lite library
(*libtensorflow-lite.a*) will be generated.


The library can be verified with the TensorFlow Lite image classification sample
application named *label_image* which is included in the build (included by
package *tensorflow-lite-examples*). The sample application is installed under
*/usr/bin/tensorflow-lite/examples/*.


To use *label_image*:  
1. Download model data:  
`wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip`  
2. Extract to */usr/bin/tensorflow-lite/examples/*.  
3. Execute  *label_image* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
./label_image
```


The output of a healthy execution should look like the following:
> Neon Support  
> Loaded model ./mobilenet_quant_v1_224.tflite  
> resolved reporter  
> invoked  
> average time: 317.484 ms  
> 0.666667: 458 bow tie  
> 0.290196: 653 military uniform  
> 0.0117647: 835 suit  
> 0.00784314: 611 jersey  
> 0.00392157: 922 book jacket  


To use *benchmark_model*:  
1. Download model data:  
`wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip`  
2. Extract to */usr/bin/tensorflow-lite/examples/*.  
3. Execute  *benchmark_model* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
./benchmark_model --graph=mobilenet_quant_v1_224.tflite
```


For more information about the output of the execution, please refer to
**https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/lite/tools/benchmark**


To use *minimal*:  
1. Download model data:  
`wget https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip`  
2. Extract to */usr/bin/tensorflow-lite/examples/*.  
3. Execute  *minimal* by running the following commands:
```
cd /usr/bin/tensorflow-lite/examples/
./minimal mobilenet_quant_v1_224.tflite
```


The output of a healthy execution will read the model file and perform
inference.


## Notes ##
**Using Large Models**  
Due to the limited memory size on some platforms, large pre-trained models could
cause out of memory issues. To overcome this memory limitation, a swap file can
used. Please see the top level *README.md* file for details.
