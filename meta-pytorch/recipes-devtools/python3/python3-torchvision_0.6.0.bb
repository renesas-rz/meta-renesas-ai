SUMMARY = "Torchvision"
DESCRIPTION = "Package library for computer vision"
HOMEPAGE = "https://pytorch.org/"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=bd7749a3307486a4d4bfefbc81c8b796"

S = "${WORKDIR}/git"

SRC_URI = "\
	git://github.com/pytorch/vision.git;protocol=git;nobranch=1 \
"

SRCREV = "b68adcf9a9280aef02fc08daed170d74d0892361"

COMPATIBLE_MACHINE = "(x86_64|iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

inherit python3native setuptools3

DEPENDS += " \
	python3 \
	python3-pytorch-native \
"

RDEPENDS_${PN} = " \
	tiff \
	python3-pytorch \
	python3-numpy \
	python3-pillow \
	python3-six \
"

do_compile_prepend() {
	export NATIVE_BUILD_DIR=${RECIPE_SYSROOT_NATIVE}
	export CMAKE_PREFIX_PATH=${RECIPE_SYSROOT}/${prefix}
}
