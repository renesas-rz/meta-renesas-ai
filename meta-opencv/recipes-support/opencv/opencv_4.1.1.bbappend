FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2m|ek874)"

DEPENDS_append = "python-native"

#label file synset_words.txt is originally from
#https://raw.githubusercontent.com/opencv/opencv/master/samples/data/dnn/synset_words.txt

SRC_URI_append = " \
           https://s3.amazonaws.com/download.onnx/models/opset_9/squeezenet.tar.gz;name=onnx-squeezenet;subdir=${WORKDIR}/onnx-squeezenet \
           http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz;name=ssd_mobilenetv2;subdir=${WORKDIR}/tensorflowmodel;destsuffix=tensorflowmodel \
           https://docs.opencv.org/master/space_shuttle.jpg;name=sapce_shuttle\
           https://github.com/tensorflow/models/raw/master/research/object_detection/test_images/image2.jpg;downloadfilename=object_detection_sample.jpg;name=object_detection_sample \
           https://github.com/opencv/opencv/raw/master/samples/data/dnn/classification_classes_ILSVRC2012.txt;name=classes_ILSVRC2012 \
           https://github.com/opencv/opencv_extra/raw/master/testdata/dnn/bvlc_googlenet.prototxt;name=bvlc_googlenet_proto \
           https://github.com/opencv/opencv_extra/blob/master/testdata/dnn/dog416.png?raw=true;downloadfilename=dog416.png;name=dog416 \
           https://github.com/opencv/opencv_extra/raw/master/testdata/dnn/ssd_mobilenet_v2_coco_2018_03_29.pbtxt;name=ssd_mobilenetv2_pbtxt \
           file://synset_words.txt \
           file://opencv-onnx-image-classification.py \
           file://opencv-tensorflow-object-detection.py \
           file://bvlc_googlenet.caffemodel \
"

SRC_URI[onnx-squeezenet.md5sum] = "92e240a948f9bbc92534d752eb465317"
SRC_URI[onnx-squeezenet.sha256sum] = "f4c9a2906a949f089bee5ef1bf9ea1c0dc1b49d5abeb1874fff3d206751d0f3b"

SRC_URI[ssd_mobilenetv2.md5sum] = "71b1d303a39445d03a49c1b50ab1e7e7"
SRC_URI[ssd_mobilenetv2.sha256sum] = "b9380178b2e35333f1a735e39745928488bdabeb9ed20bc6fa07af8172cb5adc"

SRC_URI[sapce_shuttle.md5sum] = "c6bf45f56551707841620f245e70a252"
SRC_URI[sapce_shuttle.sha256sum] = "12a9c70863d95a9b6de0795ab9b9ba7ec59bd58eaac759a00fbd4836ce2f7938"

SRC_URI[classes_ILSVRC2012.md5sum] = "4fdfb6d202e9d8e65da14c78b604af95"
SRC_URI[classes_ILSVRC2012.sha256sum] = "4eb3da435cf544e4a6f390f62c84cb9c9bb68cf8b14e97f8a063452382e5efd2"

SRC_URI[bvlc_googlenet_proto.md5sum] = "a0888d41230461469a4a2d62fb9058d7"
SRC_URI[bvlc_googlenet_proto.sha256sum] = "3cf5576e43eaf70fdd8b599d0dabc4825c318df49ff9430d6c48c3a3668d9476"

SRC_URI[dog416.md5sum] = "167507cd2014b08ae93f60ec8f56a330"
SRC_URI[dog416.sha256sum] = "61db162464c0770138c5136af0e999ce3b6556244cec257945427396480d9caf"

SRC_URI[object_detection_sample.md5sum] = "50281d88bd2686c32ef0f4c106ab4ab6"
SRC_URI[object_detection_sample.sha256sum] = "87410f52f79cc256c3949b48a3548632c07c8e9943468ef8caa6250f6643be8e"

SRC_URI[ssd_mobilenetv2_pbtxt.md5sum] = "2ee8b425cc3426165b86109393bae850"
SRC_URI[ssd_mobilenetv2_pbtxt.sha256sum] = "cfbecf9447c384403ef5cf695f4cd0bb4840c1312938280350639a9a8e82d303"


PACKAGECONFIG = "python2 dnn eigen jpeg png tiff v4l libv4l gstreamer samples tbb gphoto2 \
    ${@bb.utils.contains("DISTRO_FEATURES", "x11", "gtk", "", d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "wayland", "wayland", "", d)} \
    ${@bb.utils.contains("LICENSE_FLAGS_WHITELIST", "commercial", "libav", "", d)}"

inherit ${@bb.utils.contains('PACKAGECONFIG', 'python3', 'distutils3-base', '', d)}
inherit ${@bb.utils.contains('PACKAGECONFIG', 'python2', 'distutils-base', '', d)}

export PYTHON_CSPEC="-I${STAGING_INCDIR}/${PYTHON_DIR}"
export PYTHON="${STAGING_BINDIR_NATIVE}/${@bb.utils.contains('PACKAGECONFIG', 'python3', 'python3', 'python', d)}"

PACKAGECONFIG[wayland] = "-DWITH_QT=ON -DOE_QMAKE_PATH_EXTERNAL_HOST_BINS=${STAGING_BINDIR_NATIVE}/qt5 -D_qt5gui_OPENGL_INCLUDE_DIR=${STAGING_DIR_HOST},-DWITH_QT=OFF,qtbase qtbase-native,"

FILES_${PN}-samples += "${bindir}/${PN}-${PV}/examples/"

do_install_append() {

    install -d ${D}${bindir}/${PN}-${PV}/examples/opencv-qt-dnn-image-classification

    install -d ${D}${bindir}/${PN}-${PV}/examples/opencv-performance-test

    install -d ${D}${bindir}/${PN}-${PV}/examples/opencv-dnn-ml-inference

    install -d ${D}${bindir}/${PN}-${PV}/examples/opencv-dnn-object-detection

    install -d ${D}${bindir}/${PN}-${PV}/examples/opencv-models/testdata/dnn

    install -m 0555 \
        ${WORKDIR}/build/bin/example_dnn_classification \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-qt-dnn-image-classification

    install -m 0555 \
        ${WORKDIR}/build/bin/opencv_perf_core \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-performance-test

    install -m 0555 \
        ${WORKDIR}/build/bin/opencv_perf_dnn \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-performance-test

    install -m 0555 \
        ${WORKDIR}/opencv-onnx-image-classification.py \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-dnn-ml-inference

    install -m 0555 \
        ${WORKDIR}/opencv-tensorflow-object-detection.py \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-dnn-object-detection

    install -m 0644 \
        ${WORKDIR}/object_detection_sample.jpg \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models/testdata/dnn/object_detection_sample.jpg

    install -m 0644 \
        ${WORKDIR}/dog416.png \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models/testdata/dnn/dog416.png

    install -m 0644 \
        ${WORKDIR}/space_shuttle.jpg \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models/testdata/dnn/

    install -m 0644 \
        ${WORKDIR}/ssd_mobilenet_v2_coco_2018_03_29.pbtxt \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models

    install -m 0644 \
        ${WORKDIR}/tensorflowmodel/ssd_mobilenet_v2_coco_2018_03_29/frozen_inference_graph.pb \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models

    install -m 0644 \
        ${WORKDIR}/onnx-squeezenet/squeezenet/model.onnx \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models/

    install -m 0644 \
        ${WORKDIR}/bvlc_googlenet.caffemodel \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models

    install -m 0644 \
        ${WORKDIR}/bvlc_googlenet.prototxt \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models

    install -m 0644 \
        ${WORKDIR}/classification_classes_ILSVRC2012.txt \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models

    install -m 0644 \
        ${WORKDIR}/synset_words.txt \
        ${D}${bindir}/${PN}-${PV}/examples/opencv-models

    cd ${D}${bindir}
    ln -sf ${PN}-${PV} ${PN}
}
