SUMMARY = "PyTorch Framework"
DESCRIPTION = "AI Framework PyTorch"
HOMEPAGE = "https://pytorch.org/"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://LICENSE;md5=acf4d595f99e159bf31797aa872aef57"

S = "${WORKDIR}/git"

SRC_URI = " \
	gitsm://github.com/pytorch/pytorch.git;protocol=git;nobranch=1 \
	file://0001-add-base-cmake-native-configuration.patch \
"

SRCREV = "74044638f755cd8667bedc73da4dbda4aa64c948"

inherit pythonnative setuptools native

DEPENDS += " \
	protobuf \
	protobuf-native \
	python-numpy-native \
	python-pyyaml-native \
	python-typing-native \
	sleef-native \
	glog \
"

RDEPENDS_${PN} = " \
	python-modules-native \
	python-future-native \
	python-numpy-native \
	gflags \
	glog \
"

do_compile() {
	export NATIVE_BUILD_DIR=${RECIPE_SYSROOT_NATIVE}
	export BUILD_CUSTOM_PROTOBUF=ON
	export USE_CUDA=OFF
	export USE_NUMA=OFF
	export USE_MKLDNN=OFF
	export USE_QNNPACK=ON
	export USE_NNPACK=ON
	export USE_FBGEMM=OFF
	export BUILD_CAFFE2_OPS=OFF
	export BUILD_PYTHON=ON
	export BUILD_TEST=ON
	python ${S}/setup.py build
}

do_install_append() {
	install -m 0644 ${D}/${PYTHON_SITEPACKAGES_DIR}/torch/lib/*.so ${D}/${libdir}
}
