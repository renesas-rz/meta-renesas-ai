DESCRIPTION = "Bazel build and test tool"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI[md5sum] = "fb6b928b62f068697bd66ad6d13aad53"
SRC_URI[sha256sum] = "c3b716e6625e6b8c323350c95cd3ae0f56aeb00458dddd10544d5bead8a7b602"

SRC_URI = " https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel-${PV}-dist.zip "

inherit native

S = "${WORKDIR}"

INHIBIT_SYSROOT_STRIP = "1"

do_compile () {
	export JAVA_HOME="${bindir}/openjdk-1.8-native/"
	./compile.sh
}

do_install () {
        install -d ${D}${bindir}
        cp -Rf \
		${S}/output/* \
		${D}${bindir}
}

DEPENDS += "openjdk-8-native"
RDEPENDS_${PN}-native += "openjdk-8-native"
