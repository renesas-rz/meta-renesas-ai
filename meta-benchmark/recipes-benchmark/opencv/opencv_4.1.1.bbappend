FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

SRC_URI += " \
	file://classification.cpp \
	file://opencv-benchmark.sh \
	file://grace_hopper.jpg \
	https://github.com/pjreddie/darknet/raw/master/data/imagenet.shortnames.list;name=darknet_label;subdir=opencv \
	https://pjreddie.com/media/files/darknet19.weights;name=darkent19_weights;subdir=opencv \
	https://github.com/pjreddie/darknet/raw/master/cfg/darknet19.cfg;name=darkent19_cfg;subdir=opencv \
	https://github.com/pjreddie/darknet/raw/master/cfg/darknet.cfg;name=darkent_cfg;subdir=opencv \
	https://pjreddie.com/media/files/darknet.weights;name=darkent_weights;subdir=opencv \
	https://github.com/DeepScale/SqueezeNet/blob/master/SqueezeNet_v1.1/squeezenet_v1.1.caffemodel?raw=true;downloadfilename=squeezenet_v1.1.caffemodel;name=squeezenet_caffe;subdir=opencv \
	https://github.com/DeepScale/SqueezeNet/raw/master/SqueezeNet_v1.1/deploy.prototxt;name=squeezenet_caffe_proto;subdir=opencv \
	https://s3.amazonaws.com/onnx-model-zoo/squeezenet/squeezenet1.1/squeezenet1.1.onnx;name=squeezenet_onnx;subdir=opencv \
	https://s3.amazonaws.com/onnx-model-zoo/mobilenet/mobilenetv2-1.0/mobilenetv2-1.0.onnx;name=mobilenetv2_onnx;subdir=opencv \
	https://github.com/opencv/opencv/raw/master/samples/data/dnn/classification_classes_ILSVRC2012.txt;name=ilsvrc_label;subdir=opencv \
	https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz;name=inception_v3;subdir=opencv \
"

SRC_URI[darknet_label.md5sum] = "f5e3301cbb3ed333bd5f5faf38d18b7f"
SRC_URI[darknet_label.sha256sum] = "6ba751a14e6470ccaf740476ab79df657925d29d9f29311629eed20f7efb0ed5"
SRC_URI[darkent19_weights.md5sum] = "1eddf541dc78a2c7ace844cdac886afd"
SRC_URI[darkent19_weights.sha256sum] = "10419470e9e2ffce52f3d32f7e9a3c206afdb7bde306caa2b7f7dbf097d6dabb"
SRC_URI[darkent_cfg.md5sum] = "dd251ce35ef435fcd886ee2c99f0fcdb"
SRC_URI[darkent_cfg.sha256sum] = "7d24fe985303c8889b879b60e0a7ae033e57c719932292eac04d3467f80ada95"
SRC_URI[darkent_weights.md5sum] = "ee60922067d60576744437eede06642a"
SRC_URI[darkent_weights.sha256sum] = "1b5ddb91b85aba5dfd552ec4528d3f9243779c92e7c698a4659c79ea1d87de59"
SRC_URI[darkent19_cfg.md5sum] = "6d7d2d970b6351e0f5c2795a86f28bad"
SRC_URI[darkent19_cfg.sha256sum] = "7ac495cfb9f37c780ae5ea451dda4754ec147ae9820fa14b2fdd52f8e6426971"
SRC_URI[squeezenet_caffe.md5sum] = "0357e4e11d173c72a01615888826bc8e"
SRC_URI[squeezenet_caffe.sha256sum] = "72b912ace512e8621f8ff168a7d72af55910d3c7c9445af8dfbff4c2ee960142"
SRC_URI[squeezenet_caffe_proto.md5sum] = "425b30ccf1181cce57c5d0cbd85f9c06"
SRC_URI[squeezenet_caffe_proto.sha256sum] = "d041bfb2ab4b32fda4ff6c6966684132f2924e329916aa5bfe9285c6b23e3d1c"
SRC_URI[squeezenet_onnx.md5sum] = "497ad0774f4e0b59e4f2c77ae88fcdfc"
SRC_URI[squeezenet_onnx.sha256sum] = "1eeff551a67ae8d565ca33b572fc4b66e3ef357b0eb2863bb9ff47a918cc4088"
SRC_URI[mobilenetv2_onnx.md5sum] = "1b8a2fd91dc2b6c78f3cfe846cf16c88"
SRC_URI[mobilenetv2_onnx.sha256sum] = "c1c513582d56afceff8516c73804e484c81c6a830712ab6d682253f4a3cd042f"
SRC_URI[ilsvrc_label.md5sum] = "4fdfb6d202e9d8e65da14c78b604af95"
SRC_URI[ilsvrc_label.sha256sum] = "4eb3da435cf544e4a6f390f62c84cb9c9bb68cf8b14e97f8a063452382e5efd2"
SRC_URI[inception_v3.md5sum] = "a904ddf15593d03c7dd786d552e22d73"
SRC_URI[inception_v3.sha256sum] = "7045b72a954af4dce36346f478610acdccbf149168fa25c78e54e32f0c723d6d"

do_compile_append() {
	cp ../classification.cpp .
        ${CXX} classification.cpp -o opencv-dnn-benchmark \
		-I ${S}/modules/dnn/include -I ${S}/modules/imgproc/include \
		-I ${S}/modules/highgui/include/ -I ${S}/modules/core/include \
		-I ${S}/modules/imgcodecs/include -I ${S}/modules/videoio/include \
		-I .. -I ${S}/../build/ \
		-lpthread -lstdc++ -lm -ldl -lopencv_core \
		-lopencv_imgproc -lopencv_dnn -lopencv_imgcodecs \
		-lopencv_videoio -lopencv_highgui ${LDFLAGS} \
		-L ${S}/../build/lib/
}

do_install_append() {
	install -d ${D}${bindir}/opencvBenchmark
	install -m 0555 ${S}/../build/opencv-dnn-benchmark ${D}${bindir}/opencvBenchmark/
	install -m 0644 ${S}/../grace_hopper.jpg ${D}${bindir}/opencvBenchmark/
	install -m 0555 ${S}/../opencv-benchmark.sh ${D}${bindir}/opencvBenchmark/

	install -d ${D}/home/root/models/opencv/
	cp -r ${S}/../opencv/* ${D}/home/root/models/opencv/
}

FILES_${PN} += "\
	${bindir}/opencvBenchmark/* \
        /home/root/models/opencv \
"
