SUMMARY = "PyTorch Framework"
DESCRIPTION = "AI Framework PyTorch"
HOMEPAGE = "https://pytorch.org/"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://LICENSE;md5=acf4d595f99e159bf31797aa872aef57"

S = "${WORKDIR}/git"

SRC_URI = " \
	gitsm://github.com/pytorch/pytorch.git;protocol=git;nobranch=1 \
	file://0001-add-base-cmake-configuration.patch \
	file://0002-remove-cwd-from-lib_path-to-make-it-relative-for-cro.patch \
"

SRCREV = "3c31d73c875d9a4a6ea8a843b9a0d1b19fbe36f3"

SRC_URI_append_arm = " \
	file://0003-add-armv7l-processor-into-check-condition-cpuinfo.patch \
	file://0004-add-cmake-configuration-for-arm.patch \
"

SRC_URI_append_aarch64 = " \
	file://0003-QNNPACK-q8gemm-8x8-dq-aarch64-neon.S-fix-mov-operand.patch \
	file://0004-disable-fp16-for-armv8-a.patch \
	file://0005-add-cmake-configuration-for-aarch64.patch \
"

COMPATIBLE_MACHINE = "(x86_64|iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2m|hihope-rzg2n|ek874)"

inherit python3native setuptools3

DEPENDS += " \
	protobuf \
	protobuf-native \
	sleef-native \
	python3-numpy-native \
	python3-pyyaml-native \
	glog \
"

RDEPENDS_${PN} = " \
	python3-modules \
	python3-numpy \
	gflags \
	glog \
"

TARGET_CC_ARCH += "${LDFLAGS}"

CFLAGS_append_arm = " -mfp16-format=ieee "
CXXFLAGS_append_arm = " -mfp16-format=ieee "

do_compile_prepend() {
	export USE_CUDA=OFF
	export USE_NUMA=OFF
	export USE_MKLDNN=OFF
	export USE_QNNPACK=ON
	export USE_NNPACK=ON
	export USE_FBGEMM=OFF
	export BUILD_CUSTOM_PROTOBUF=OFF
	export BUILD_CAFFE2_OPS=ON
	export BUILD_PYTHON=ON
	export BUILD_TEST=ON
	export CMAKE_SYSROOT=${RECIPE_SYSROOT}
}
