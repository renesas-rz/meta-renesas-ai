DESCRIPTION = "TensorFlow Lite C++ Library"
LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=01e86893010a1b87e69a213faa753ebd"

SRCREV = "024aecf414941e11eb643e29ceed3e1c47a115ad"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=master \
	file://0001-Get-TensorFlow-lite-to-cross-compile.patch \
	file://0002-Compile-label_image.patch \
	file://0003-Fix-compile-time-error.patch \
	file://0004-Check-NEON-support.patch \
	file://0005-Disable-dlopen-error-of-libneuralnetworks-for-non-An.patch \
	file://0001-Use-fixed-versions-of-NEON-and-Flatbuffers.patch \
"

COMPATIBLE_MACHINE = "(iwg20m|iwg21m|iwg22m)"

S = "${WORKDIR}/git"

PACKAGES += "${PN}-examples ${PN}-examples-dbg"

do_configure(){
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}

	${S}/tensorflow/contrib/lite/download_dependencies.sh
}

CXXFLAGS += "--std=c++11"
FULL_OPTIMIZATION += "-O3 -DNDEBUG"

do_install(){
	install -d ${D}${libdir}
	cp -r \
		${S}/tensorflow/contrib/lite/gen/lib/* \
		${D}${libdir}

	install -d ${D}${includedir}/tensorflow_lite
	cd ${S}/tensorflow/contrib/lite
	cp --parents \
		$(find . -name "*.h*") \
		${D}${includedir}/tensorflow_lite

	install -d ${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
		${S}/tensorflow/contrib/lite/gen/bin/label_image \
		${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
		${S}/tensorflow/contrib/lite/examples/label_image/testdata/grace_hopper.bmp \
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
"

FILES_${PN}-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/.debug \
"
