DESCRIPTION = "Models for ONNX benchmarking"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=01ef493f179b9c768ffe3a8e4431b222 \
"

S = "${WORKDIR}"

SRC_URI = " \
        file://license/LICENSES \
        file://license/COPYING \
	https://s3.amazonaws.com/onnx-model-zoo/squeezenet/squeezenet1.1/squeezenet1.1.onnx;name=squeezenet_onnx;subdir=onnx \
	https://s3.amazonaws.com/onnx-model-zoo/mobilenet/mobilenetv2-1.0/mobilenetv2-1.0.onnx;name=mobilenetv2_onnx;subdir=onnx \
"

SRC_URI[squeezenet_onnx.md5sum] = "497ad0774f4e0b59e4f2c77ae88fcdfc"
SRC_URI[squeezenet_onnx.sha256sum] = "1eeff551a67ae8d565ca33b572fc4b66e3ef357b0eb2863bb9ff47a918cc4088"
SRC_URI[mobilenetv2_onnx.md5sum] = "1b8a2fd91dc2b6c78f3cfe846cf16c88"
SRC_URI[mobilenetv2_onnx.sha256sum] = "c1c513582d56afceff8516c73804e484c81c6a830712ab6d682253f4a3cd042f"

do_install () {
	install -d ${D}/home/root/models/onnx
	cp -r ${S}/onnx/* ${D}/home/root/models/onnx/
}

FILES_${PN} = " \
        /home/root/models/onnx \
"
