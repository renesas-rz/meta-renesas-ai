FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += " \
	python \
	python-pip \
	python-setuptools \
	python-numpy \
"

SRC_URI += " \
	file://tensorflow-lite-benchmark.cc \
	file://patch/0001-Fix-image-resize-crash-in-certain-caess.patch \
	file://run_TF_measurement.py \
	file://test_file_list_Inception_Net_V3.txt \
	file://test_file_list_Mobile_Net_V2.txt \
	file://test_file_list_Mobile_Net_V1.txt \
	file://test_file_list_Nasnet.txt \
	file://test_file_list_Mnasnet.txt \
	file://test_file_list_Squeezenet.txt \
"

do_compile_append() {
	cp ../tensorflow-lite-benchmark.cc .
	${CC} tensorflow-lite-benchmark.cc tensorflow/lite/examples/label_image/bitmap_helpers.cc \
		-o tensorflow-lite-benchmark \
		-I . -I tensorflow/lite/tools/make/downloads/flatbuffers/include \
		-I tensorflow/lite/tools/make/downloads/gemmlowp \
		-lstdc++ -lpthread -lm -ldl ${LDFLAGS} tensorflow/lite/tools/make/gen/lib/libtensorflow-lite.a
}

do_install_append() {
	install -d ${D}${bindir}/tensorflow-lite-benchmark
	install -m 0555 ${S}/tensorflow-lite-benchmark ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0555 ${S}/../run_TF_measurement.py ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${S}/../test_file_list_Inception_Net_V3.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${S}/../test_file_list_Mobile_Net_V2.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${S}/../test_file_list_Mobile_Net_V1.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${S}/../test_file_list_Nasnet.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${S}/../test_file_list_Mnasnet.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${S}/../test_file_list_Squeezenet.txt ${D}${bindir}/tensorflow-lite-benchmark/
}

FILES_${PN} += "\
	${bindir}/tensorflow-lite-benchmark/* \
"
