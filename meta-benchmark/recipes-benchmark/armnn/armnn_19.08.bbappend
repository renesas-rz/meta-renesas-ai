FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "models-armnn"

SRC_URI += " \
	file://armnnBenchmark.cpp \
"

do_compile_append() {
	${CC} ../armnnBenchmark.cpp \
		${WORKDIR}/build/tests/CMakeFiles/TfInceptionV3-Armnn.dir/ImagePreprocessor.cpp.o \
		${WORKDIR}/build/tests/CMakeFiles/inferenceTest.dir/InferenceTestImage.cpp.o \
		-o armnnBenchmark -DARMNN_TF_PARSER -DARMNN_TF_LITE_PARSER -DARMNN_ONNX_PARSER \
		-I ${S}/include -I ${S}/tests -I ${S}/src/armnnUtils \
		-I ${S}/src/backends/ -I ${S}/src/armnn/ \
		-I ${STAGING_DIR_TARGET}/usr/include \
		-L ${WORKDIR}/build \
		-larmnn -larmnnTfLiteParser -larmnnOnnxParser -larmnnTfParser \
		-L ${STAGING_DIR_TARGET}/usr/lib/ -lstdc++ -lm -lpthread ${LDFLAGS}
}

do_install_append() {
	install -d ${D}${bindir}/armnnBenchmark
	install -m 0555 \
		${WORKDIR}/build/armnnBenchmark \
		${D}${bindir}/armnnBenchmark/
}

FILES_${PN} += "\
	${bindir}/armnnBenchmark/armnnBenchmark \
"
