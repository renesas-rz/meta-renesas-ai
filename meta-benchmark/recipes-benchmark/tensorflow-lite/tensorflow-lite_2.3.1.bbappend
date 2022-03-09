FILESEXTRAPATHS_prepend := "${THISDIR}/tensorflow-lite-benchmark:"

RDEPENDS_${PN} += " \
	models-tensorflow-lite \
	python \
	python-pip \
	python-setuptools \
	python-numpy \
"

# The smarc-rzg2l uses Yocto Dunfell which only provides Python3
RDEPENDS_${PN}_smarc-rzg2l += " \
	models-tensorflow-lite \
	python3 \
	python3-pip \
	python3-setuptools \
	python3-numpy \
"
RDEPENDS_${PN}_smarc-rzg2lc += " \
	models-tensorflow-lite \
	python3 \
	python3-pip \
	python3-setuptools \
	python3-numpy \
"

SRC_URI += " \
	file://tensorflow-lite-benchmark.cc \
	file://patch/0001-Fix-image-resize-crash-in-certain-caess.patch \
	file://run_TF_measurement.py \
	file://test_file_list_Inception_Net_V3.txt \
	file://test_file_list_Inception_Net_V4.txt \
	file://test_file_list_Mobile_Net_V1.txt \
	file://test_file_list_Mobile_Net_V2.txt \
	file://test_file_list_Mobile_Net_V3.txt \
	file://test_file_list_Nasnet.txt \
	file://test_file_list_Mnasnet.txt \
	file://test_file_list_Resnet.txt \
	file://test_file_list_Squeezenet.txt \
"

do_configure_append_smarc-rzg2l() {
	sed -i 's/python2/python3/g' ${WORKDIR}/run_TF_measurement.py
	sed -i 's/stderr=subprocess.STDOUT)/stderr=subprocess.STDOUT, text=True)/g' ${WORKDIR}/run_TF_measurement.py
}

do_configure_append_smarc-rzg2lc() {
	sed -i 's/python2/python3/g' ${WORKDIR}/run_TF_measurement.py
	sed -i 's/stderr=subprocess.STDOUT)/stderr=subprocess.STDOUT, text=True)/g' ${WORKDIR}/run_TF_measurement.py
}

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
	install -m 0555 ${WORKDIR}/run_TF_measurement.py ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Inception_Net_V3.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Inception_Net_V4.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Mobile_Net_V1.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Mobile_Net_V2.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Mobile_Net_V3.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Nasnet.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Mnasnet.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Resnet.txt ${D}${bindir}/tensorflow-lite-benchmark/
	install -m 0644 ${WORKDIR}/test_file_list_Squeezenet.txt ${D}${bindir}/tensorflow-lite-benchmark/
}

FILES_${PN} += "\
	${bindir}/tensorflow-lite-benchmark/* \
"
