# meta-google-coral
A USB accessory featuring Google's Edge TPU that brings ML inferencing to
existing systems.

The official website is:  
**https://coral.ai/**

This Yocto/OpenEmbedded meta-layer provides Google USB TPU Accelerator support
for the RZ/G1 and RZ/G2 family of System on Chips. For best performance the USB
3.0 ports should be used.

In order to add Google Coral support to your project, make sure *google-coral*
is listed as a dependency to your recipe/package. Listing *google-coral-dev* in
*IMAGE\_INSTALL* variable could be beneficial when you just want to populate an
SDK for developing an application based on Google Coral.

After the build is complete the dynamic C++ Google Coral library
(*libedgetup.so.1*) will be generated.

The library can be verified with the Google Coral sample image classification
application named *label_image_tpu* which is included in the build (included by
package *google-coral-examples*). The sample application is installed under
*/usr/bin/google-coral*.


To use *label_image_tpu*:  
```
cd /usr/bin/google-coral/
./label_image_tpu -m ./models/mobilenet_v2_1.0_224_quant_edgetpu.tflite -i ./images/parrot.bmp -l models/imagenet_labels.txt
```

The output of a healthy execution should look like the following:  
```
Loaded model ./models/mobilenet_v2_1.0_224_quant_edgetpu.tflite
resolved reporter
INFO: Initialized TensorFlow Lite runtime.
invoked
average time: 16.723 ms
1: 89   89  macaw
```


To use *minimal*:  
```
cd /usr/bin/google-coral/
./minimal ./models/mobilenet_v2_1.0_224_quant_edgetpu.tflite ./images/grace_hopper_224_224.bmp
```

The output of a healthy execution should look like the following:  
```
INFO: Initialized TensorFlow Lite runtime.
[Image analysis] max value index: 653 value: 0.878906
```
