# meta-opencv
OpenCV (Open Source Computer Vision Library) is an open source computer vision
and machine learning software library. OpenCV was built to provide a common
infrastructure for computer vision applications and to accelerate the use of
machine perception in the commercial products.

The official website is:  
**https://opencv.org/**

This Yocto/OpenEmbedded meta-layer provides OpenCV support for the RZ/G AI BSP.

## Build Configuration
**python-opencv**: Add as a dependency to your recipe/package to add OpenCV
python support or Add to *IMAGE_INSTALL* to populate OpenCV's
python binding in your build.  
**opencv-samples**: Add to *IMAGE_INSTALL* to populate opencv's
example code in your build.  
**opencv-apps**: Add to *IMAGE_INSTALL* to populate opencv's
application code in your build.  
**opencv-dev**, **openv-staticdev**:  Useful to add to *IMAGE_INSTALL* when
supporting the native compilation on the target.

## Build Output
Once the build is complete, OpenCV core and DNN libraries are generated.

Each library can be verified with the relevant sample application below, if
*opencv-samples* was included in the build (see Build Configuration above).

**opencv-core-functions**: *opencv_perf_core*  
**opencv-dnn-functions**:  *opencv_perf_dnn*  
**opencv-load-ml-model-functions**: *opencv-onnx-image-classification.py*  
**opencv-object-detection-functions**: *opencv-tensorflow-object-detection.py*  
**opencv-qt-backend-functions**: *opencv-qt-dnn-image-classification*

The sample applications are installed under */usr/bin/opencv/examples/*.


## Using the Sample Applications
### Functional and Performance Tests
1. Export environment variable *OPENCV_TEST_DATA_PATH*:
```
$ export OPENCV_TEST_DATA_PATH=/usr/bin/opencv/examples/opencv-models/testdata
```
2. Execute *opencv_perf_core* by running the following commands:
```
$ cd /usr/bin/opencv/examples/opencv-performance-test/
$ ./opencv_perf_core
```
3. The output of a healthy execution should look like the following:
```
[----------] Global test environment tear-down
[==========] 2371 tests from 53 test cases ran. (636986 ms total)
[  PASSED  ] 2371 tests.
```
4. Execute *opencv_perf_dnn* by running the following commands:
```
$ cd /usr/bin/opencv/examples/opencv-performance-test/
$ ./opencv_perf_dnn
```
5. The output of a healthy execution should look like the following:
```
[----------] Global test environment tear-down
[==========] 135 tests from 3 test cases ran. (361126 ms total)
[  PASSED  ] 135 tests.
```

### opencv-dnn-ml-inference
In this test application the OpenCV DNN library loads the ONNX Squeezenet model
and does image classification.

1. Execute *opencv-onnx-image-classification.py* by running the following
commands:
```
$ cd /usr/bin/opencv/examples/opencv-dnn-ml-inference
$ ./opencv-onnx-image-classification.py ../opencv-models/testdata/dnn/space_shuttle.jpg
```

2. The output of a healthy execution should look like the following:
```
(1, 3, 224, 224)
shuttle shuttle: 91.00%
airliner: 2.56%
missile missile: 2.30%
dirigible dirigible: 1.91%
military plane plane: 1.21%
```

### opencv-qt-dnn-image-classification
This test requires full Qt support.  
For RZ/G2 devices please build with bitbake core-image-qt.  
For RZ/G1 devices please build with bitbake core-image-weston.  
For more information about how to add full Qt support in the image, please refer
to the official Renesas Yocto recipe Start-Up Guide.

1. Execute *example_dnn_classification* by running the following commands:
```
$ cd /usr/bin/opencv/examples/opencv-qt-dnn-image-classification
$ ./example_dnn_classification --model=/usr/bin/opencv/examples/opencv-models/bvlc_googlenet.caffemodel --config=/usr/bin/opencv/examples/opencv-models/bvlc_googlenet.prototxt --width=224 --height=224 --classes=/usr/bin/opencv/examples/opencv-models/classification_classes_ILSVRC2012.txt --input=/usr/bin/opencv/examples/opencv-models/testdata/dnn/space_shuttle.jpg --mean="104 117 123" --rgb
```

2. The output of a healthy execution in the console should look like the
following:
```
Using Wayland-EGL
```

3. The output of a healthy execution in the Weston desktop should show an image
of a space shuttle in a Qt GUI window displaying inference time and prediction
result in the top left window.


### opencv-dnn-object-detection
1. Execute *opencv-tensorflow-object-detection* by running the following
commands:

```
$ cd /usr/bin/opencv/examples/opencv-dnn-object-detection
$ ./opencv-tensorflow-object-detection.py ../opencv-models/testdata/dnn/object_detection_sample.jpg
```

2. The output of a healthy execution will generate an image
*opencv-tensorflow-object-detection.jpg* under the directory
*/usr/bin/opencv/examples/opencv-dnn-object-detection*.
