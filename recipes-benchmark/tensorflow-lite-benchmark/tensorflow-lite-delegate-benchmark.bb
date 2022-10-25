DESCRIPTION = "TensorFlow Lite Delegate C++ Benchmarking tools"
LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI += " \
	file://tfLiteDelegateBenchmark.cpp \
	file://run_Delegate_measurement.py \
	file://test_model_list_delegate.txt \
	file://test_model_list_delegate_low_mem.txt \
"

DEPENDS = " \
	armnn \
	tensorflow-lite \
"

RDEPENDS_${PN} += " \
	armnn \
	models-onnx \
	models-tensorflow-lite \
	python3 \
	python3-numpy \
	python3-pip \
	python3-setuptools \
	tensorflow-lite \
"

LDFLAGS += " \
	${STAGING_DIR_TARGET}/usr/lib64/libtensorflow-lite.a \
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
	${CC} ../tfLiteDelegateBenchmark.cpp \
		${STAGING_DIR_TARGET}/usr/lib64/libtensorflow-lite.a \
		${STAGING_DIR_TARGET}/usr/include/bitmap_helpers.cc \
		-o tfLiteDelegateBenchmark \
		-I ${STAGING_DIR_TARGET}/usr/include/delegate/ \
		-I ${STAGING_DIR_TARGET}/usr/include \
		-larmnn -larmnnDelegate -larmnnUtils \
		-lstdc++ -lm -ldl -lpthread ${LDFLAGS}
}

do_install() {
	install -d ${D}${bindir}/tfLiteDelegateBenchmark
	install -m 0555 \
		${WORKDIR}/${PN}-${PV}/tfLiteDelegateBenchmark \
		${D}${bindir}/tfLiteDelegateBenchmark/

	install -m 0555 \
		${WORKDIR}/run_Delegate_measurement.py \
		${D}${bindir}/tfLiteDelegateBenchmark/

	install -m 0555 \
		${WORKDIR}/test_model_list_delegate.txt \
		${D}${bindir}/tfLiteDelegateBenchmark/

	install -m 0555 \
		${WORKDIR}/test_model_list_delegate_low_mem.txt \
		${D}${bindir}/tfLiteDelegateBenchmark/
}

FILES_${PN} += " \
	${bindir}/tfLiteDelegateBenchmark/tfLiteDelegateBenchmark \
	${bindir}/tfLiteDelegateBenchmark/run_Delegate_measurement.py \
	${bindir}/tfLiteDelegateBenchmark/test_model_list_delegate.txt \
	${bindir}/tfLiteDelegateBenchmark/test_model_list_delegate_low_mem.txt \
"
