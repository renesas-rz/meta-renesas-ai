SUMMARY = "Torchvision"
DESCRIPTION = "Package library for computer vision"
HOMEPAGE = "https://pytorch.org/"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=bd7749a3307486a4d4bfefbc81c8b796"

S = "${WORKDIR}/git"

SRC_URI = "git://github.com/pytorch/vision.git;protocol=git"
SRCREV = "3bd7a405093742e837b2dc48d3c83fc16614d5df"

COMPATIBLE_MACHINE = "(x86_64|iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2m|ek874)"

inherit pythonnative setuptools

DEPENDS += " \
	python \
	pytorch-native \
	python-future-native \
"
RDEPENDS_${PN} = " \
	tiff \
	pytorch \
	python-numpy \
	python-pillow \
	python-six \
"

do_compile() {
	export NATIVE_BUILD_DIR=${RECIPE_SYSROOT_NATIVE}
	export CMAKE_PREFIX_PATH=${RECIPE_SYSROOT}/${prefix}
	python ${S}/setup.py build
}
