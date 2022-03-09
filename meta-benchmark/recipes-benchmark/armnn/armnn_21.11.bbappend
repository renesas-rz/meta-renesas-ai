FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += " \
	models-onnx \
	models-tensorflow-lite \
"

SRC_URI += "file://armnnBenchmark.cpp"

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
}

do_install_append() {
	install -d ${D}${bindir}/armnnBenchmark
	install -m 0555 \
		${WORKDIR}/build/armnnBenchmark \
		${D}${bindir}/armnnBenchmark/
}

FILES_${PN} += " \
	${bindir}/armnnBenchmark/armnnBenchmark \
"
