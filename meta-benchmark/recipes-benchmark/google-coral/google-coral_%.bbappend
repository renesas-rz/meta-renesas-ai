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
	file://test_file_list_MobileNet.txt \
	file://test_file_list_Inception.txt \
	file://test_file_list_EfficientNet.txt \
	file://run_TPU_measurement.py \
"

do_compile_append() {
	${CXX} -std=c++11 ${S}/../google-coral-benchmark/label_image.cc \
		${S}/../google-coral-benchmark/bitmap_helpers.cc \
		-o ${S}/../google-coral-tpu-benchmark \
		-I . -I ${S}/tflite/public/ \
		-I ${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/tools/make/downloads/flatbuffers/include \
		-lstdc++ -lpthread -lm -ldl ${STAGING_DIR_TARGET}/usr/${TFLITE_LIB_DIR_ARCH}/libtensorflow-lite.a \
		-L ${WORKDIR}/${TPU_LIB_DIR_ARCH}/${GOOGLE_CORAL_SPEED}/ -l:libedgetpu.so.1.0 ${LDFLAGS} 
}

do_install_append() {
	install -d ${D}${bindir}/google-coral-benchmark
	install -m 0555 ${S}/../google-coral-tpu-benchmark ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../labels.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../test_file_list_Resnet.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../test_file_list_MobileNet.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../test_file_list_Inception.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0644 ${S}/../test_file_list_EfficientNet.txt ${D}${bindir}/google-coral-benchmark/
	install -m 0555 ${S}/../run_TPU_measurement.py ${D}${bindir}/google-coral-benchmark/
}

FILES_${PN} += "\
	${bindir}/google-coral-benchmark/* \
"
