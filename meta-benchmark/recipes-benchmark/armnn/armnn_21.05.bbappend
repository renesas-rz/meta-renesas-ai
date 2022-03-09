FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += " \
	models-onnx \
	models-tensorflow-lite \
"

SRC_URI += "file://armnnBenchmark.cpp"

do_compile_append() {
	${CC} ../armnnBenchmark.cpp \
		${WORKDIR}/build/tests/CMakeFiles/RenesasSample-Armnn.dir/ImagePreprocessor.cpp.o \
		${WORKDIR}/build/tests/CMakeFiles/RenesasSample-Armnn.dir/InferenceTestImage.cpp.o \
		-o armnnBenchmark -DARMNN_TF_LITE_PARSER -DARMNN_ONNX_PARSER \
		-I ${S}/include -I ${S}/tests -I ${S}/src/armnnUtils \
		-I ${S}/src/armnn/ \
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

        install -m 0555 \
                ${WORKDIR}/tensorflow/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp \
                ${D}${bindir}/${PN}-${PV}/examples
}

FILES_${PN} += "\
	${bindir}/armnnBenchmark/armnnBenchmark \
	${bindir}/${PN}-${PV}/examples/grace_hopper.bmp \
"
