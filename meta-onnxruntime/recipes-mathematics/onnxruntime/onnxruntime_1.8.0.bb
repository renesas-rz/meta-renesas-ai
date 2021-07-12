DESCRIPTION = "ONNX Runtime is an open-source scoring engine for Open Neural \
Network Exchange (ONNX) models. ONNX Runtime has an open architecture that \
is continually evolving to address the newest developments and challenges \
in AI and Deep Learning."
SUMMARY = "ONNX Runtime"
HOMEPAGE = "https://github.com/microsoft/onnxruntime"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=0f7e3b1308cb5c00b372a6e78835732d"

COMPATIBLE_MACHINE = "(hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874|smarc-rzg2l|smarc-rzg2lc)"

SRCREV_onnxruntime ="d4106deeb65c21eed3ed40df149efefeb72fe9a4"

S = "${WORKDIR}/git"

inherit cmake python3native

OECMAKE_SOURCEPATH = "${S}/cmake"

SRC_URI = " \
	gitsm://github.com/microsoft/onnxruntime.git;protocol=https;branch=rel-1.8.0;name=onnxruntime \
	file://patches/0001-Fix-no-test-cases-are-loaded-in-onnxruntime-test-cod.patch;patchdir=${WORKDIR}/git \
	https://s3.amazonaws.com/download.onnx/models/opset_9/squeezenet.tar.gz;name=onnx-squeezenet;subdir=${WORKDIR}/onnx-squeezenet \
"

SRC_URI[onnx-squeezenet.md5sum] = "92e240a948f9bbc92534d752eb465317"
SRC_URI[onnx-squeezenet.sha256sum] = "f4c9a2906a949f089bee5ef1bf9ea1c0dc1b49d5abeb1874fff3d206751d0f3b"

DEPENDS = " \
	cmake-native \
	protobuf3.16.0-native \
"

EXTRA_OECMAKE=" \
	-DONNX_CUSTOM_PROTOC_EXECUTABLE=${STAGING_DIR_NATIVE}${prefix}/bin/protoc \
	-Donnxruntime_USE_OPENMP=ON \
	-Donnxruntime_BUILD_SHARED_LIB=ON \
"

do_install_append() {
	install -d ${D}${bindir}/${PN}-${PV}/examples
	install -d ${D}${bindir}/${PN}-${PV}/examples/unittest

	install -m 0555 \
		${B}/onnx_test_runner \
		${D}${bindir}/${PN}-${PV}/examples/unittest

	cp -r	${WORKDIR}/onnx-squeezenet/squeezenet \
		${D}${bindir}/${PN}-${PV}/examples/unittest

	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

FILES_${PN} += "${libdir}/libonnxruntime.so.${PV} \
		${libdir}/libonnxruntime_providers_shared.so \
		${libdir}/pkgconfig \
		${libdir}/pkgconfig/libonnxruntime.pc \
"
FILES_${PN}-dev = "${includedir} \
		   ${libdir}/libonnxruntime.so \
"
