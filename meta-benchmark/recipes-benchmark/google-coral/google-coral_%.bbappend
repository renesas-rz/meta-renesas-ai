FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += " \
	python \
	python-pip \
	python-setuptools \
	python-numpy \
"

SRC_URI += " \
	file://google-coral-benchmark \
	file://labels.txt \
	file://test_file_list_Resnet.txt \
	file://run_TPU_measurement.py \
"

do_compile_append() {
        ${CXX} -std=c++11 ${S}/../google-coral-benchmark/label_image.cc \
                ${S}/../google-coral-benchmark/bitmap_helpers.cc \
                -o ${S}/../google-coral-tpu-benchmark \
                -I . -I edgetpu -I libedgetpu/  \
                -I ${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/tools/make/downloads/flatbuffers/include \
                -lstdc++ -lpthread -lm -ldl ${STAGING_DIR_TARGET}/usr/${TFLITE_LIB_DIR_ARCH}/libtensorflow-lite.a \
                -l:libedgetpu.so.1.0 -L libedgetpu/${GOOGLE_CORAL_SPEED}/${TPU_LIB_DIR_ARCH} ${LDFLAGS}
}

do_install_append() {
	install -d ${D}${bindir}/google-coral-benchmark
	install -m 0555 ${S}/../google-coral-tpu-benchmark ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../labels.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../test_file_list_Resnet.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0555 ${S}/../run_TPU_measurement.py ${D}${bindir}/google-coral-benchmark/
}

FILES_${PN} += "\
	${bindir}/google-coral-benchmark/* \
"
