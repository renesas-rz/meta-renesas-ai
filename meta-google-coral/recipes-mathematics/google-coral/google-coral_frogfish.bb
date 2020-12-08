DESCRIPTION = "A USB accessory featuring Google's Edge TPU that brings ML \
inferencing to existing systems."
SUMMARY = "Google Coral USB TPU Accelerator"
HOMEPAGE = "https://github.com/google-coral"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

PACKAGES += "${PN}-examples"

SRC_URI += " \
	git://github.com/google-coral/libedgetpu.git;protocol=https;name=libedgetpu \
	https://dl.google.com/coral/canned_models/mobilenet_v2_1.0_224_quant_edgetpu.tflite;name=mobilenet_tpu \
	https://dl.google.com/coral/canned_models/imagenet_labels.txt;name=label_tpu \
	git://github.com/google/benchmark.git;protocol=https;name=benchmark;subdir=${WORKDIR}/benchmark;destsuffix=benchmark \
	file://label_image/ \
	file://images/ \
	file://armv7a/ \
	file://aarch64/ \
	file://0001-Select-Tensorflow-v2.3.1.patch \
"

S = "${WORKDIR}/git"

SRCREV_libedgetpu = "14eee1a076aa1af7ec1ae3c752be79ae2604a708"

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
		-I . -I ${S}/tflite/public/ \
		-I ${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/tools/make/downloads/flatbuffers/include \
		-lstdc++ -lpthread -lm -ldl ${STAGING_DIR_TARGET}/usr/${TFLITE_LIB_DIR_ARCH}/libtensorflow-lite.a \
		-L ${WORKDIR}/${TPU_LIB_DIR_ARCH}/${GOOGLE_CORAL_SPEED}/ -l:libedgetpu.so.1.0 ${LDFLAGS}
}

do_install_append_arm () {
	# Install "maximum" and "throttled" libraries in case user wants to switch at run time
	install -m 0555 ${WORKDIR}/armv7a/direct/libedgetpu.so.1.0 ${D}${libdir}/libedgetpu_direct.so.1
	install -m 0555 ${WORKDIR}/armv7a/throttled/libedgetpu.so.1.0 ${D}${libdir}/libedgetpu_throttled.so.1

	ln -rsf ${D}${libdir}/libedgetpu_${GOOGLE_CORAL_SPEED}.so.1 ${D}${libdir}/libedgetpu.so.1.0
	ln -rsf ${D}${libdir}/libedgetpu.so.1.0 ${D}${libdir}/libedgetpu.so.1
}

do_install_append_aarch64 () {
	# Install "maximum" and "throttled" libraries in case user wants to switch at run time
	install -m 0555 ${WORKDIR}/aarch64/direct/libedgetpu.so.1.0 ${D}${libdir}/libedgetpu_direct.so.1
	install -m 0555 ${WORKDIR}/aarch64/throttled/libedgetpu.so.1.0 ${D}${libdir}/libedgetpu_throttled.so.1

	ln -rsf ${D}${libdir}/libedgetpu_${GOOGLE_CORAL_SPEED}.so.1 ${D}${libdir}/libedgetpu.so.1.0
	ln -rsf ${D}${libdir}/libedgetpu.so.1.0 ${D}${libdir}/libedgetpu.so.1
}

do_install() {
	# Install header files
	install -d ${D}${libdir}
	install -d ${D}${includedir}/${PN}-${PV}
	install -m 0555 ${S}/tflite/public/edgetpu_c.h ${D}${includedir}/${PN}-${PV}/
	install -m 0555 ${S}/tflite/public/edgetpu.h ${D}${includedir}/${PN}-${PV}/

	# Install example code
	install -d ${D}${bindir}/${PN}-${PV}/models
	install -d ${D}${bindir}/${PN}-${PV}/images
	install -m 0644 ${S}/../mobilenet_v2_1.0_224_quant_edgetpu.tflite ${D}${bindir}/${PN}-${PV}/models/
	install -m 0644 ${S}/../imagenet_labels.txt ${D}${bindir}/${PN}-${PV}/models/
	install -m 0644 ${S}/../images/parrot.bmp ${D}${bindir}/${PN}-${PV}/images/
	install -m 0644 ${S}/../images/grace_hopper_224_224.bmp ${D}${bindir}/${PN}-${PV}/images/
	install -m 0555 ${S}/../label_image_tpu ${D}${bindir}/${PN}-${PV}/
	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

FILES_${PN} = "\
	${libdir}/libedgetpu.so.1 \
	${libdir}/libedgetpu.so.1.0 \
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
