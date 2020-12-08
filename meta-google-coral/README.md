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
(*libedgetpu.so.1*) will be generated.

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
Loaded model ./models/resnet_v2_101_299_quant_edgetpu.tflite
invoked
average time: 13.281 ms
1: 89   89  macaw
```

## Google Coral USB clock speed
Google's [install.sh](https://github.com/google-coral/libedgetpu/blob/release-frogfish/scripts/install.sh#L109)
script states the following warning:
> Warning: If you're using the Coral USB Accelerator, it may heat up during operation, depending
> on the computation workloads and operating frequency. Touching the metal part of the USB
> Accelerator after it has been operating for an extended period of time may lead to discomfort
> and/or skin burns. As such, if you enable the Edge TPU runtime using the maximum operating
> frequency, the USB Accelerator should be operated at an ambient temperature of 25°C or less.
> Alternatively, if you enable the Edge TPU runtime using the reduced operating frequency, then
> the device is intended to safely operate at an ambient temperature of 35°C or less.
>
> Google does not accept any responsibility for any loss or damage if the device
> is operated outside of the recommended ambient temperature range.

By default the recipe included in this repository installs the "direct" version
of the *libedgetpu* library with will run the TPU device at maximum operating
frequency.

The *GOOGLE_CORAL_SPEED* variable can be set in *local.conf* to change this
behaviour.

*GOOGLE_CORAL_SPEED* can be set as follows:  
`GOOGLE_CORAL_SPEED = "direct"`: Use the maximum operating frequency  
`GOOGLE_CORAL_SPEED = "throttled"`: Use reduced operating frequency
