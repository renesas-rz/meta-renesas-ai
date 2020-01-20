DESCRIPTION = "Bazel build and test tool"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI[md5sum] = "7f66122853137fb98dfe5e61ff8b1275"
SRC_URI[sha256sum] = "56ea1b199003ad832813621744178e42b39e6206d34fbae342562c287da0cd54"

SRC_URI = "https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel-${PV}-dist.zip"

inherit native

S = "${WORKDIR}"

INHIBIT_SYSROOT_STRIP = "1"

DEPENDS = "coreutils-native zip-native"

do_compile () {
        export HTTP_PROXY=${HTTP_PROXY}
        export HTTPS_PROXY=${HTTPS_PROXY}
        export http_proxy=${HTTP_PROXY}
        export https_proxy=${HTTPS_PROXY}
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
