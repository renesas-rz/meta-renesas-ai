# meta-tensorflow

TensorFlow is an open source software library for high performance numerical
computation. Its flexible architecture allows easy deployment of computation
across a variety of platforms (CPUs, GPUs, TPUs), and from desktops to clusters
of servers to mobile and edge devices. Originally developed by researchers and
engineers from the Google Brain team within Google’s AI organization, it comes
with strong support for machine learning and deep learning and the flexible
numerical computation core is used across many other scientific domains.


The official website is:  
**https://www.tensorflow.org/**


This Yocto/OpenEmbedded meta-layer provides TensorFlow support for the RZ/G1
family of System on Chips.


In order to add TensorFlow support to your project, make sure *tensorflow* is
listed as a dependency to your recipe/package.
Listing *tensorflow* and *tensorflow-dev* in *IMAGE_INSTALL* variable could be
beneficial when you just want to populate an SDK for developing an application
based on TensorFlow.


After the build is complete, both Tensorflow C (*libtensorflow_cc.so*) and C++
(*libtensorflow.so*) libraries will be generated.

The C++ library can be verified with the TensorFlow image classification sample
application named *label_image* which is included in the build. Please refer to
the official TensorFlow documentation for instructions on how to use
*label_image*:  
**https://github.com/tensorflow/tensorflow/tree/master/tensorflow/examples/label_image**


In summary:  
1. Download model data:  
`wget https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz`  
2. Extract to home directory on target.  
3. Run label_image, specifying the downloaded files:  
`/usr/bin/tensorflow/examples/label_image --image="/usr/bin/tensorflow/examples/grace_hopper.jpg" --graph="/home/root/inception_v3_2016_08_28_frozen.pb" --labels="/home/root/imagenet_slim_labels.txt"`


Instructions for verifying the C library can be found in the "Validate your
installation" section of:
**https://www.tensorflow.org/install/install_c**


---

**Note**  
When using TensorFlow with the iwg22m platform one should take note of the fact
that there is only 512MB of memory available. Out of memory errors will occur
when using larger models.

---
