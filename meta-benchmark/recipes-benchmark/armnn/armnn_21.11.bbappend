FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += " \
	models-onnx \
	models-tensorflow-lite \
"

SRC_URI += " \
	file://armnnBenchmark.cpp \
	file://armnnTFLiteDelegateBenchmark.cpp \
	file://run_Delegate_measurement.py \
	file://test_model_list_armnnDelegate.txt \
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
"

do_configure_append_smarc-rzg2l() {
	sed -i 's/python2/python3/g' ${WORKDIR}/run_Delegate_measurement.py
	sed -i 's/stderr=subprocess.STDOUT)/stderr=subprocess.STDOUT, text=True)/g' ${WORKDIR}/run_Delegate_measurement.py
}

do_configure_append_smarc-rzg2lc() {
	sed -i 's/python2/python3/g' ${WORKDIR}/run_Delegate_measurement.py
	sed -i 's/stderr=subprocess.STDOUT)/stderr=subprocess.STDOUT, text=True)/g' ${WORKDIR}/run_Delegate_measurement.py
}

do_compile_append() {
	${CC} ../armnnBenchmark.cpp \
		${WORKDIR}/build/tests/CMakeFiles/RenesasSample-Armnn.dir/ImagePreprocessor.cpp.o \
		${WORKDIR}/build/tests/CMakeFiles/RenesasSample-Armnn.dir/InferenceTestImage.cpp.o \
		-o armnnBenchmark -DARMNN_TF_LITE_PARSER -DARMNN_ONNX_PARSER \
		-I ${S}/include -I ${S}/tests -I ${S}/src/armnnUtils \
		-I ${S}/src/armnn/ \
		-I ${S}/profiling/ \
		-I ${S}/third-party/ \
		-I ${S}/include/armnn/ \
		-L ${WORKDIR}/build/ \
		-larmnn -larmnnTfLiteParser -larmnnOnnxParser \
		-lstdc++ -lm -lpthread ${LDFLAGS}

	${CC} ../armnnTFLiteDelegateBenchmark.cpp \
		${STAGING_DIR_TARGET}/usr/include/bitmap_helpers.cc \
		-o armnnTFLiteDelegateBenchmark \
		-DDUNFELL_XNNPACK \
		-I ${S}/include/armnn/ \
		-I ${S}/include/ \
		-I ${S}/profiling/ -I ${S}/src/armnnUtils \
		-I ${S}/src/backends/ \
		-I ${STAGING_DIR_TARGET}/usr/include \
		-L ${WORKDIR}/build/ \
		-L ${WORKDIR}/build/delegate \
		-L ${STAGING_DIR_TARGET}/usr/lib64/ \
		-larmnn -larmnnDelegate -larmnnUtils \
		-lstdc++ -lm -ldl -lpthread ${LDFLAGS}
}

do_install_append() {
	install -d ${D}${bindir}/armnnBenchmark
	install -m 0555 \
		${WORKDIR}/build/armnnBenchmark \
		${D}${bindir}/armnnBenchmark/

	install -d ${D}${bindir}/armnnDelegateBenchmark
	install -m 0555 \
		${WORKDIR}/build/armnnTFLiteDelegateBenchmark \
		${D}${bindir}/armnnDelegateBenchmark/

	install -m 0555 \
		${WORKDIR}/run_Delegate_measurement.py \
		${D}${bindir}/armnnDelegateBenchmark/

	install -m 0555 \
		${WORKDIR}/test_model_list_armnnDelegate.txt \
		${D}${bindir}/armnnDelegateBenchmark/
}

FILES_${PN} += "\
	${bindir}/armnnBenchmark/armnnBenchmark \
	${bindir}/armnnDelegateBenchmark/armnnTFLiteDelegateBenchmark \
	${bindir}/armnnDelegateBenchmark/run_Delegate_measurement.py \
	${bindir}/armnnDelegateBenchmark/test_model_list_armnnDelegate.txt \
"
