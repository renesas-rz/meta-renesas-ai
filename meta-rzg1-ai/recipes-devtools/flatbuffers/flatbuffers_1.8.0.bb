SUMMARY = "Memory Efficient Serialization Library"
HOMEPAGE = "https://github.com/google/flatbuffers"
LICENSE = "Apache-2.0"

PACKAGE_BEFORE_PN = "${PN}-compiler"

RDEPENDS_${PN}-compiler = "${PN}"
RDEPENDS_${PN}-dev += "${PN}-compiler"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=a873c5645c184d51e0f9b34e1d7cf559"

SRCREV = "34aea4361f829d3e4f1e4d50324e155ad4adec67"

SRC_URI = "git://github.com/google/flatbuffers.git"

# Make sure C++11 is used, required for example for GCC 4.9
CXXFLAGS += "-std=c++11"
BUILD_CXXFLAGS += "-std=c++11"

EXTRA_OECMAKE += "\
    -DFLATBUFFERS_BUILD_TESTS=OFF \
"

inherit cmake

S = "${WORKDIR}/git"

FILES_${PN}-compiler = "${bindir}"

FILES_${PN} = " \
        ${libdir}/cmake \
        ${libdir}/cmake/flatbuffers \
"

BBCLASSEXTEND = "native nativesdk"
