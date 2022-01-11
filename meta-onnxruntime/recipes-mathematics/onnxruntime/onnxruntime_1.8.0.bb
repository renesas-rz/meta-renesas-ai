DESCRIPTION = "ONNX Runtime is an open-source scoring engine for Open Neural \
Network Exchange (ONNX) models. ONNX Runtime has an open architecture that \
is continually evolving to address the newest developments and challenges \
in AI and Deep Learning."
SUMMARY = "ONNX Runtime"
HOMEPAGE = "https://github.com/microsoft/onnxruntime"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=0f7e3b1308cb5c00b372a6e78835732d"

COMPATIBLE_MACHINE = "(hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874|smarc-rzg2l|smarc-rzg2lc)"

SRCREV_FORMAT = "onnxruntime"

SRCREV_onnxruntime ="d4106deeb65c21eed3ed40df149efefeb72fe9a4"

S = "${WORKDIR}/git"

inherit cmake python3native

OECMAKE_SOURCEPATH = "${S}/cmake"

SRC_URI = " \
	gitsm://github.com/microsoft/onnxruntime.git;protocol=https;branch=rel-1.8.0;name=onnxruntime \
	file://patches/0001-Fix-no-test-cases-are-loaded-in-onnxruntime-test-cod.patch;patchdir=${WORKDIR}/git \
"

DEPENDS = " \
	cmake-native \
	protobuf3.16.0-native \
	zlib \
"

EXTRA_OECMAKE=" \
	-DONNX_CUSTOM_PROTOC_EXECUTABLE=${STAGING_DIR_NATIVE}${prefix}/bin/protoc \
	-Donnxruntime_USE_OPENMP=ON \
"

do_install() {
	install -d ${D}${includedir}/onnxruntime

	install -d ${D}${libdir}

	cp --parents \
		$(find . -name "*.a") \
		${D}/${libdir}
}

ALLOW_EMPTY_${PN} = "1"

FILES_${PN} = ""

FILES_${PN}-dev = " \
	${includedir} \
"

FILES_${PN}-staticdev = " \
	${libdir} \
"
