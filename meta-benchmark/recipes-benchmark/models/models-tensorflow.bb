DESCRIPTION = "Models for TensorFlow benchmarking"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=a9b73dae4a0b3a752f7eccb813bc2820 \
"

S = "${WORKDIR}"

SRC_URI = " \
        file://models/tensorflow \
        file://license/LICENSES \
        file://license/COPYING \
	https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz;name=inception_v3;subdir=tensorflow \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/inception_v4_2018_04_27.tgz;name=inception_v4_float;subdir=tensorflow \
	https://storage.googleapis.com/download.tensorflow.org/models/inception_v4_299_quant_20181026.tgz;name=inception_v4_quant;subdir=tensorflow \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_224.tgz;name=mobilenet;subdir=tensorflow \
"

SRC_URI[inception_v3.md5sum] = "a904ddf15593d03c7dd786d552e22d73"
SRC_URI[inception_v3.sha256sum] = "7045b72a954af4dce36346f478610acdccbf149168fa25c78e54e32f0c723d6d"
SRC_URI[inception_v4_float.md5sum] = "97da95494e4a4d755cf79d636c726bcb"
SRC_URI[inception_v4_float.sha256sum] = "305e45035c690f7a064b5babe27ea68a4e6da5819147c7c94319963c6f256467"
SRC_URI[inception_v4_quant.md5sum] = "2dff9819d610b98768927530f57a25d3"
SRC_URI[inception_v4_quant.sha256sum] = "e26c7fc6928efe9c63642eec0a72f8ae3fd9e12c04b25845c50ac4b8828e18f7"
SRC_URI[mobilenet.md5sum] = "d5f69cef81ad8afb335d9727a17c462a"
SRC_URI[mobilenet.sha256sum] = "1ccb74dbd9c5f7aea879120614e91617db9534bdfaa53dfea54b7c14162e126b"

do_install () {
	install -d ${D}/home/root/models/tensorflow/InceptionV3
	install -d ${D}/home/root/models/tensorflow/InceptionV3_Quant
	install -d ${D}/home/root/models/tensorflow/InceptionV4
	install -d ${D}/home/root/models/tensorflow/MobileNet
	install -m 0644 ${S}/tensorflow/imagenet_slim_labels.txt ${D}/home/root/models/tensorflow/InceptionV3/
	install -m 0644 ${S}/tensorflow/inception_v3_2016_08_28_frozen.pb ${D}/home/root/models/tensorflow/InceptionV3/
	install -m 0644 ${S}/tensorflow/imagenet_slim_labels.txt ${D}/home/root/models/tensorflow/InceptionV3_Quant/
	install -m 0644 ${S}/models/tensorflow/InceptionV3_Quant/* ${D}/home/root/models/tensorflow/InceptionV3_Quant/
	install -m 0644 ${S}/tensorflow/imagenet_slim_labels.txt ${D}/home/root/models/tensorflow/InceptionV4/
	install -m 0644 ${S}/tensorflow/inception_v4*.pb ${D}/home/root/models/tensorflow/InceptionV4/
	install -m 0644 ${S}/tensorflow/mobilenet_v1_1.0_224_frozen.pb ${D}/home/root/models/tensorflow/MobileNet/
}

FILES_${PN} = " \
        /home/root/models/tensorflow \
"
