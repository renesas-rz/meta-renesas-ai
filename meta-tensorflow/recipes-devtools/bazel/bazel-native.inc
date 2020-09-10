DESCRIPTION = "Bazel build and test tool"

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
