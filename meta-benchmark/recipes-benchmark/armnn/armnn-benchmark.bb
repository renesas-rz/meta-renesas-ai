DESCRIPTION = "ArmNN C++ Benchmarking tools"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

RDEPENDS_${PN} = " models-onnx models-tensorflow-lite"
DEPENDS = " armnn"

SRC_URI = "file://armnnBenchmark.cpp"

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

do_compile() {
	${CC} ../armnnBenchmark.cpp \
		${STAGING_DIR_TARGET}/usr/include/armnn/renesas/ImagePreprocessor.cpp.o \
		${STAGING_DIR_TARGET}/usr/include/armnn/renesas/InferenceTestImage.cpp.o \
		-o armnnBenchmark -DARMNN_TF_LITE_PARSER -DARMNN_ONNX_PARSER \
		-I ${STAGING_DIR_TARGET}/usr/include/armnn \
		-I ${STAGING_DIR_TARGET}/usr/include/tests \
		-I ${STAGING_DIR_TARGET}/usr/include/src/armnnUtils \
		-I ${STAGING_DIR_TARGET}/usr/include/profiling/ \
		-I ${STAGING_DIR_TARGET}/usr/include/third-party/ \
		-larmnn -larmnnTfLiteParser -larmnnOnnxParser \
		-lstdc++ -lm -lpthread ${LDFLAGS}
}

do_install() {
	install -d ${D}${bindir}/armnnBenchmark

	install -m 0555 \
		${WORKDIR}/armnn-benchmark-${PV}/armnnBenchmark \
		${D}${bindir}/armnnBenchmark/
}

FILES_${PN} = " ${bindir}/armnnBenchmark/armnnBenchmark"
