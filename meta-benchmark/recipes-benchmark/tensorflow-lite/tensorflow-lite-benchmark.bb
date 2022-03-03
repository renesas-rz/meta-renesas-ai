DESCRIPTION = "TensorFlow Lite C++ Benchmarking tools"
LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

RDEPENDS_${PN} += " \
	tensorflow-lite \
	models-tensorflow-lite \
	python \
	python-pip \
	python-setuptools \
	python-numpy \
"

# The smarc-rzg2l uses Yocto Dunfell which only provides Python3
RDEPENDS_${PN}_smarc-rzg2l += " \
	tensorflow-lite \
	models-tensorflow-lite \
	python3 \
	python3-pip \
	python3-setuptools \
	python3-numpy \
"
RDEPENDS_${PN}_smarc-rzg2lc += " \
	tensorflow-lite \
	models-tensorflow-lite \
	python3 \
	python3-pip \
	python3-setuptools \
	python3-numpy \
"

DEPENDS = "tensorflow-lite"

SRC_URI += " \
	file://tensorflow-lite-benchmark.cc \
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

# The smarc-rzg2l and smarc-rzg2lc uses Yocto Dunfell
# which only provides Python3 so the test script added
# to the RFS must be modified to reflect the Python version.
do_configure_append_smarc-rzg2l() {
	sed -i 's/python2/python3/g' ${WORKDIR}/run_TF_measurement.py
	sed -i 's/stderr=subprocess.STDOUT)/stderr=subprocess.STDOUT, text=True)/g' ${WORKDIR}/run_TF_measurement.py
}

do_configure_append_smarc-rzg2lc() {
	sed -i 's/python2/python3/g' ${WORKDIR}/run_TF_measurement.py
	sed -i 's/stderr=subprocess.STDOUT)/stderr=subprocess.STDOUT, text=True)/g' ${WORKDIR}/run_TF_measurement.py
}

LDFLAGS_smarc-rzg2l += " \
		${STAGING_DIR_TARGET}/usr/lib64/libflatbuffers.a \
		${STAGING_DIR_TARGET}/usr/lib64/libfft2d_fftsg2d.a \
		${STAGING_DIR_TARGET}/usr/lib64/libruy.a \
		${STAGING_DIR_TARGET}/usr/lib64/libXNNPACK.a \
		${STAGING_DIR_TARGET}/usr/lib64/libpthreadpool.a \
		${STAGING_DIR_TARGET}/usr/lib64/libcpuinfo.a \
		${STAGING_DIR_TARGET}/usr/lib64/libclog.a \
		${STAGING_DIR_TARGET}/usr/lib64/libfft2d_fftsg.a \
		${STAGING_DIR_TARGET}/usr/lib64/libfarmhash.a \
		-DDUNFELL_XNNPACK \
"

LDFLAGS_smarc-rzg2lc += " \
		${STAGING_DIR_TARGET}/usr/lib64/libflatbuffers.a \
		${STAGING_DIR_TARGET}/usr/lib64/libfft2d_fftsg2d.a \
		${STAGING_DIR_TARGET}/usr/lib64/libruy.a \
		${STAGING_DIR_TARGET}/usr/lib64/libXNNPACK.a \
		${STAGING_DIR_TARGET}/usr/lib64/libpthreadpool.a \
		${STAGING_DIR_TARGET}/usr/lib64/libcpuinfo.a \
		${STAGING_DIR_TARGET}/usr/lib64/libclog.a \
		${STAGING_DIR_TARGET}/usr/lib64/libfft2d_fftsg.a \
		${STAGING_DIR_TARGET}/usr/lib64/libfarmhash.a \
		-DDUNFELL_XNNPACK \
"

do_compile() {
	cp ../tensorflow-lite-benchmark.cc .
	${CC} tensorflow-lite-benchmark.cc ${STAGING_DIR_TARGET}/usr/include/bitmap_helpers.cc \
		${STAGING_DIR_TARGET}/usr/lib64/libtensorflow-lite.a \
		-o tensorflow-lite-benchmark \
		-lstdc++ -lpthread -lm -ldl ${LDFLAGS}
}

do_install() {
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

FILES_${PN} += "${bindir}/tensorflow-lite-benchmark/*"
