DESCRIPTION = "Bazel build and test tool"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI[md5sum] = "1f1227ff947dd30fd42d5490f9209775"
SRC_URI[sha256sum] = "2418c619bdd44257a170b85b9d2ecb75def29e751b725e27186468ada2e009ea"
SRC_URI = " \
	https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel-${PV}-dist.zip \
"

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
