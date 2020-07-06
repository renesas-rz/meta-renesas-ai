DESCRIPTION = "A USB accessory featuring Google's Edge TPU that brings ML \
inferencing to existing systems."
SUMMARY = "Google Coral USB TPU Accelerator"
HOMEPAGE = "https://github.com/google-coral"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d8927f3331d2b3e321b7dd1925166d25"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2m|hihope-rzg2n|ek874)"

PACKAGES += "${PN}-examples"

SRC_URI += " \
	gitsm://github.com/google-coral/edgetpu.git;protocol=https;name=edgetpu \
	https://dl.google.com/coral/canned_models/mobilenet_v2_1.0_224_quant_edgetpu.tflite;name=mobilenet_tpu \
	https://dl.google.com/coral/canned_models/imagenet_labels.txt;name=label_tpu \
	git://github.com/google/benchmark.git;protocol=https;name=benchmark;subdir=${WORKDIR}/benchmark;destsuffix=benchmark \
	file://label_image/ \
	file://images/ \
"

S = "${WORKDIR}/git"

SRCREV_edgetpu = "14237f65ba07b7b1d8287e9f60dd20c88562871a"

SRCREV_benchmark = "090faecb454fbd6e6e17a75ef8146acb037118d4"

SRC_URI[mobilenet_tpu.md5sum] = "5c5a507ac190a46fd7d8ae8550ef745a"
SRC_URI[mobilenet_tpu.sha256sum] = "3bacfdfb97f8c6ddf9521244bbbfbe938bd460e07cc782efd4b7dd5df41f8ad2"

SRC_URI[label_tpu.md5sum] = "e5a9c11845b354d8514554a8fe1444e1"
SRC_URI[label_tpu.sha256sum] = "50f42753c6c6a76d4257b5f72cb506e6b8f7266cf8819edf7d3812cf549c4d41"

DEPENDS = "libusb1 tensorflow-lite"

# Set "direct" for maximum clock, or "throttled" for reduced clock speed
GOOGLE_CORAL_SPEED ?= "direct"

do_compile_prepend_arm () {
	TFLITE_LIB_DIR_ARCH="lib"
	TPU_LIB_DIR_ARCH="armv7a"
}

do_compile_prepend_aarch64 () {
	TFLITE_LIB_DIR_ARCH="lib64"
	TPU_LIB_DIR_ARCH="aarch64"
}

do_compile() {
	${CXX} -std=c++11 ${S}/../label_image/label_image.cc \
		${S}/../label_image/bitmap_helpers.cc \
		-o ${S}/../label_image_tpu \
		-I . -I edgetpu -I libedgetpu/  \
		-I ${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/tools/make/downloads/flatbuffers/include \
		-lstdc++ -lpthread -lm -ldl ${STAGING_DIR_TARGET}/usr/${TFLITE_LIB_DIR_ARCH}/libtensorflow-lite.a \
		-l:libedgetpu.so.1.0 -L libedgetpu/${GOOGLE_CORAL_SPEED}/${TPU_LIB_DIR_ARCH} ${LDFLAGS}

	${CXX} -std=c++11 ${S}/src/cpp/examples/minimal.cc \
		${S}/src/cpp/examples/model_utils.cc \
		-o ${S}/../minimal \
		-I . -I edgetpu -I libedgetpu/  \
		-I ${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/tools/make/downloads/flatbuffers/include \
		-lstdc++ -lpthread -lm -ldl ${STAGING_DIR_TARGET}/usr/${TFLITE_LIB_DIR_ARCH}/libtensorflow-lite.a \
		-l:libedgetpu.so.1.0 -L libedgetpu/${GOOGLE_CORAL_SPEED}/${TPU_LIB_DIR_ARCH} ${LDFLAGS}
}

do_install_append_arm () {
	# Install "maximum" and "throttled" libraries in case user wants to switch at run time
	install -m 0555 ${S}/libedgetpu/direct/armv7a/libedgetpu.so.1 ${D}${libdir}/libedgetpu_direct.so.1
	install -m 0555 ${S}/libedgetpu/throttled/armv7a/libedgetpu.so.1 ${D}${libdir}/libedgetpu_throttled.so.1

	ln -rsf ${D}${libdir}/libedgetpu_${GOOGLE_CORAL_SPEED}.so.1 ${D}${libdir}/libedgetpu.so.1
}

do_install_append_aarch64 () {
	# Install "maximum" and "throttled" libraries in case user wants to switch at run time
	install -m 0555 ${S}/libedgetpu/direct/aarch64/libedgetpu.so.1 ${D}${libdir}/libedgetpu_direct.so.1
	install -m 0555 ${S}/libedgetpu/throttled/aarch64/libedgetpu.so.1 ${D}${libdir}/libedgetpu_throttled.so.1

	ln -rsf ${D}${libdir}/libedgetpu_${GOOGLE_CORAL_SPEED}.so.1 ${D}${libdir}/libedgetpu.so.1
}

do_install() {
	# Install header files
	install -d ${D}${libdir}
	install -d ${D}${includedir}/${PN}-${PV}
	install -m 0555 ${S}/libedgetpu/edgetpu_c.h ${D}${includedir}/${PN}-${PV}/
	install -m 0555 ${S}/libedgetpu/edgetpu.h ${D}${includedir}/${PN}-${PV}/

	# Install example code
	install -d ${D}${bindir}/${PN}-${PV}/models
	install -d ${D}${bindir}/${PN}-${PV}/images
	install -m 0644 ${S}/../mobilenet_v2_1.0_224_quant_edgetpu.tflite ${D}${bindir}/${PN}-${PV}/models/
	install -m 0644 ${S}/../imagenet_labels.txt ${D}${bindir}/${PN}-${PV}/models/
	install -m 0644 ${S}/../images/parrot.bmp ${D}${bindir}/${PN}-${PV}/images/
	install -m 0644 ${S}/../images/grace_hopper_224_224.bmp ${D}${bindir}/${PN}-${PV}/images/
	install -m 0555 ${S}/../label_image_tpu ${D}${bindir}/${PN}-${PV}/
	install -m 0555 ${S}/../minimal ${D}${bindir}/${PN}-${PV}/
	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

FILES_${PN} = "\
	${libdir}/libedgetpu.so.1 \
	${libdir}/libedgetpu_direct.so.1 \
	${libdir}/libedgetpu_throttled.so.1 \
"

FILES_${PN}-dev = " \
	${includedir}/${PN}-${PV} \
"

FILES_${PN}-examples = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${PV} \
"

INSANE_SKIP_${PN} = "already-stripped"
