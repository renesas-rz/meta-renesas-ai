SUMMARY = "Protocol Buffers - structured data serialisation mechanism"
DESCRIPTION = "Protocol Buffers are a way of encoding structured data in an \
efficient yet extensible format. Google uses Protocol Buffers for almost \
all of its internal RPC protocols and file formats."
HOMEPAGE = "https://github.com/protocolbuffers/protobuf"
SECTION = "console/tools"
LICENSE = "BSD-3-Clause"

DEPENDS = "zlib"

LIC_FILES_CHKSUM = "file://LICENSE;md5=37b5762e07f0af8c74ce80a8bda4266b"

SRCREV = "c9d2bd2fc781fe67ebf306807b9b6edb4a0d2764"

PV_append = "+git${SRCPV}"

SRC_URI = " \
	gitsm://github.com/protocolbuffers/protobuf.git;nobranch=1 \
	file://0001-Remove-googletest-to-reslove-configure.ac-error.patch \
"

EXTRA_OECONF += " --with-protoc=echo"

inherit autotools-brokensep

S = "${WORKDIR}/git"

BBCLASSEXTEND = "native nativesdk"
