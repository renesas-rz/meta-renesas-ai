DESCRIPTION = "TensorFlow Lite C++ Library"
LICENSE = "Apache-2.0 & MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=5131e32d71a4eb06326ea1772d0de6fd"

# tag v2.5.3
SRCREV = "959e9b2a0c06df945f9fb66bd367af8832ca0d28"
TFL_VER = "2.5.3"

S = "${WORKDIR}/git"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=r2.5 \
	file://0001-Remove-GPU-and-NNAPI.patch \
	file://0001-Use-wget-instead-of-curl-to-fetch-https-source.patch \
	file://0001-Add-poky-cross-compiler-to-build_aarch64_lib.sh.patch \
"

PR = "r0"

COMPATIBLE_MACHINE = "(hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874|smarc-rzg2l|smarc-rzg2lc)"

S = "${WORKDIR}/git"

# TensorFlow Lite Makefile based build system does not generate a .so file,
# this statement makes sure package -staticdev goes where package -dev goes,
# as package -staticdev contains the .a file.
RDEPENDS_${PN}-dev += "${PN}-staticdev"

DEPENDS = "gzip-native unzip-native zlib"

CXX_append_smarc-rzg2l    += "-flax-vector-conversions"
CFLAGS_append_smarc-rzg2l += "-flax-vector-conversions"
CXX_append_smarc-rzg2lc    += "-flax-vector-conversions"
CFLAGS_append_smarc-rzg2lc += "-flax-vector-conversions"

do_configure() {
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}
	export http_proxy=${HTTP_PROXY}
	export https_proxy=${HTTPS_PROXY}

	${S}/tensorflow/lite/tools/make/download_dependencies.sh
}

do_compile_prepend() {
	${S}/tensorflow/lite/tools/make/build_${TARGET_ARCH}_lib.sh
	${S}/tensorflow/lite/tools/make/build_${TARGET_ARCH}_lib.sh label_image
}

do_install() {
	install -d ${D}${libdir}
	cp -r ${S}/tensorflow/lite/tools/make/gen/linux_${TARGET_ARCH}/lib/* \
	      ${D}${libdir}

	cd ${S}
	find tensorflow/lite -name "*.h" | cpio -pdm ${D}${includedir}/
	find tensorflow/lite -name "*.inc" | cpio -pdm ${D}${includedir}/
	cp ${S}/tensorflow/lite/examples/label_image/bitmap_helpers.cc ${D}${includedir}
	install -d ${D}${includedir}/flatbuffers
	install -m 0644 ${S}/tensorflow/lite/tools/make/downloads/flatbuffers/include/flatbuffers/* ${D}${includedir}/flatbuffers

	install -d ${D}${includedir}/tensorflow_lite
	cd ${S}/tensorflow/lite
	cp --parents $(find . -name "*.h*") \
		${D}${includedir}/tensorflow_lite

	install -d ${D}${bindir}/${PN}-${TFL_VER}/examples
	install -m 0555 \
		${S}/tensorflow/lite/tools/make/gen/linux_${TARGET_ARCH}/bin/label_image \
		${D}${bindir}/${PN}-${TFL_VER}/examples
	install -m 0555 \
		${S}/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp \
		${D}${bindir}/${PN}-${TFL_VER}/examples
	install -m 0555 \
                ${S}/tensorflow/lite/tools/make/gen/linux_${TARGET_ARCH}/bin/minimal \
                ${D}${bindir}/${PN}-${TFL_VER}/examples
        install -m 0555 \
                ${S}/tensorflow/lite/tools/make/gen/linux_${TARGET_ARCH}/bin/benchmark_model \
                ${D}${bindir}/${PN}-${TFL_VER}/examples

	cd ${D}${bindir}
	ln -sf ${PN}-${TFL_VER} ${PN}
}

ALLOW_EMPTY_${PN} = "1"
INSANE_SKIP_${PN} = "ldflags"

FILES_${PN} = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${TFL_VER}/examples/label_image \
	${bindir}/${PN}-${TFL_VER}/examples/grace_hopper.bmp \
	${bindir}/${PN}-${TFL_VER}/examples/minimal \
	${bindir}/${PN}-${TFL_VER}/examples/benchmark_model \
"
FILES_${PN} += "${bindir}/${PN}-${TFL_VER}/examples/*"
FILES_${PN}-dev = "${includedir}"
FILES_${PN}-staticdev = "${libdir}"
FILES_${PN}-dbg = " \
	/usr/src/debug/tensorflow-lite \
	${bindir}/${PN}-${TFL_VER}/examples/.debug \
"
