SUMMARY = "Protocol Buffers - structured data serialisation mechanism"
DESCRIPTION = "Protocol Buffers are a way of encoding structured data in an \
efficient yet extensible format. Google uses Protocol Buffers for almost \
all of its internal RPC protocols and file formats."
HOMEPAGE = "https://github.com/google/protobuf"
SECTION = "console/tools"
LICENSE = "BSD-3-Clause"

DEPENDS = "zlib"

LIC_FILES_CHKSUM = "file://LICENSE;md5=37b5762e07f0af8c74ce80a8bda4266b"

SRCREV = "ab8edf1dbe2237b4717869eaab11a2998541ad8d"

PV_append = "+git${SRCPV}"

SRC_URI = " \
	git://github.com/google/protobuf.git;branch=3.6.x \
	file://0001-Remove-googletest-to-reslove-configure.ac-error.patch \
"

EXTRA_OECONF += " --with-protoc=echo"

inherit autotools-brokensep

S = "${WORKDIR}/git"

BBCLASSEXTEND = "native nativesdk"
