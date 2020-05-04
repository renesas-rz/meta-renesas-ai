SUMMARY = "PyTorch Framework"
DESCRIPTION = "AI Framework PyTorch"
HOMEPAGE = "https://pytorch.org/"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://LICENSE;md5=acf4d595f99e159bf31797aa872aef57"

S = "${WORKDIR}/git"

SRC_URI = " \
	gitsm://github.com/pytorch/pytorch.git;protocol=git;nobranch=1 \
	file://0001-add-base-cmake-configuration.patch \
"

SRCREV = "74044638f755cd8667bedc73da4dbda4aa64c948"

SRC_URI_append_arm = " \
	file://0002-add-armv7l-processor-into-check-condition-cpuinfo.patch \
	file://0003-add-cmake-configuration-for-arm.patch \
"

SRC_URI_append_aarch64 = " \
	file://0002-add-cmake-configuration-for-aarch64.patch \
"
COMPATIBLE_MACHINE = "(x86_64|iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2m|hihope-rzg2n|ek874)"

inherit pythonnative setuptools

DEPENDS += " \
	protobuf \
	protobuf-native \
	sleef-native \
	python-numpy-native \
	python-pyyaml-native \
	python-typing-native \
	glog \
"

RDEPENDS_${PN} = " \
	python-modules \
	python-future \
	python-numpy \
	gflags \
	glog \
"

TARGET_CC_ARCH += "${LDFLAGS}"

CFLAGS_append_arm = " -mfp16-format=ieee "
CXXFLAGS_append_arm = " -mfp16-format=ieee "

do_compile() {
	export USE_CUDA=OFF
	export USE_NUMA=OFF
	export USE_MKLDNN=OFF
	export USE_QNNPACK=ON
	export USE_NNPACK=ON
	export USE_FBGEMM=OFF
	export BUILD_CUSTOM_PROTOBUF=OFF
	export BUILD_CAFFE2_OPS=OFF
	export BUILD_PYTHON=ON
	export BUILD_TEST=ON
	export CMAKE_SYSROOT=${RECIPE_SYSROOT}
	python ${S}/setup.py build
}

do_install_append() {
	install ${D}/${PYTHON_SITEPACKAGES_DIR}/torch/lib/*.so ${D}/${libdir}
}

PACKAGES = "libtorch pytorch-dbg pytorch" 
FILES_libtorch = "${libdir}/*.so" 
