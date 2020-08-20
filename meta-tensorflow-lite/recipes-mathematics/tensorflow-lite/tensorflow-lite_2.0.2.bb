DESCRIPTION = "TensorFlow Lite C++ Library"
LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=64a34301f8e355f57ec992c2af3e5157"

SRCREV = "2c2fdd3205a8d31e5f09a71ac7eb52b8c0294a60"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=r2.0 \
	file://0001-creating-a-new-Makefile-that-triggers-Makefile.inter.patch \
	file://0001-Tailor-our-own-Makefile-for-arm-arm64-cross-compilat.patch \
	file://0001-Fix-asm-mov-error.patch \
	file://0001-Remove-GPU-and-NNAPI.patch \
	file://0001-Use-wget-instead-of-curl-to-fetch-https-source.patch \
	file://0001-download-dependencies-Update-EIGEN_URL.patch \
"
PR = "r0"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

S = "${WORKDIR}/git"

PACKAGES += "${PN}-examples ${PN}-examples-dbg"
RDEPENDS_${PN}-examples += "${PN}"
RDEPENDS_${PN}-examples-dbg += "${PN}"

DEPENDS = "gzip-native unzip-native zlib"

do_configure(){
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}
	export http_proxy=${HTTP_PROXY}
	export https_proxy=${HTTPS_PROXY}

	${S}/tensorflow/lite/tools/make/download_dependencies.sh
}

CXXFLAGS += "--std=c++11"
FULL_OPTIMIZATION += "-O3 -DNDEBUG"

do_install(){
	install -d ${D}${libdir}
	cp -r \
		${S}/tensorflow/lite/tools/make/gen/lib/* \
		${D}${libdir}

	cd ${S}
	find tensorflow/lite -name "*.h" | cpio -pdm ${D}${includedir}/
	find tensorflow/lite -name "*.inc" | cpio -pdm ${D}${includedir}/

	install -d ${D}${includedir}/tensorflow_lite
	cd ${S}/tensorflow/lite
	cp --parents \
		$(find . -name "*.h*") \
		${D}${includedir}/tensorflow_lite

	install -d ${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
		${S}/tensorflow/lite/tools/make/gen/bin/label_image \
		${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
		${S}/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp \
		${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
                ${S}/tensorflow/lite/tools/make/gen/bin/minimal \
                ${D}${bindir}/${PN}-${PV}/examples
        install -m 0555 \
                ${S}/tensorflow/lite/tools/make/gen/bin/benchmark_model \
                ${D}${bindir}/${PN}-${PV}/examples
	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

ALLOW_EMPTY_${PN} = "1"

FILES_${PN} = ""

FILES_${PN}-dev = " \
	${includedir} \
"

FILES_${PN}-staticdev = " \
	${libdir} \
"

FILES_${PN}-dbg = " \
	/usr/src/debug/tensorflow-lite \
"

FILES_${PN}-examples = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${PV}/examples/label_image \
	${bindir}/${PN}-${PV}/examples/grace_hopper.bmp \
	${bindir}/${PN}-${PV}/examples/minimal \
	${bindir}/${PN}-${PV}/examples/benchmark_model \
"

FILES_${PN}-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/.debug \
"
