DESCRIPTION = "Models for ArmNN benchmarking"
LICENSE = "Apache-2.0"
LICENSE_FLAGS = "commercial"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=a9b73dae4a0b3a752f7eccb813bc2820 \
"

S = "${WORKDIR}"

RDEPENDS_${PN} = " \
	models-onnx \
	models-tensorflow \
	models-tensorflow-lite \
"

SRC_URI = " \
        file://models/armnn \
        file://license/LICENSES \
        file://license/COPYING \
"
do_install () {
	install -d ${D}/home/root/models/armnn
	cp -r ${S}/models/armnn/* ${D}/home/root/models/armnn/
}

FILES_${PN} = " \
        /home/root/models/armnn \
"
