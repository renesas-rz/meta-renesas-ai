SUMMARY = "PyTorch Framework"
DESCRIPTION = "AI Framework PyTorch"
HOMEPAGE = "https://pytorch.org/"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://LICENSE;md5=acf4d595f99e159bf31797aa872aef57"

S = "${WORKDIR}/git"

SRC_URI = " \
	gitsm://github.com/pytorch/pytorch.git;protocol=git;nobranch=1 \
	file://0001-add-base-cmake-native-configuration.patch \
	file://0002-remove-libraries-and-library-dirs-from-cppextension.patch \
"

SRCREV = "4ff3872a2099993bf7e8c588f7182f3df777205b"

inherit python3native setuptools3 native

DEPENDS += " \
	protobuf \
	protobuf-native \
	python3-numpy-native \
	python3-pyyaml-native \
	sleef-native \
	glog \
"

do_compile_prepend() {
	export NATIVE_BUILD_DIR=${RECIPE_SYSROOT_NATIVE}
	export BUILD_CUSTOM_PROTOBUF=ON
	export USE_CUDA=OFF
	export USE_NUMA=OFF
	export USE_MKLDNN=OFF
	export USE_QNNPACK=ON
	export USE_NNPACK=ON
	export USE_FBGEMM=OFF
	export BUILD_CAFFE2_OPS=ON
	export BUILD_PYTHON=ON
	export BUILD_TEST=ON
}
