FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "models-armnn"

SRC_URI += " \
	file://armnnBenchmark.cpp \
	file://armnnTFLiteDelegateBenchmark.cpp \
	file://run_Delegate_measurement.py \
	file://test_model_list_armnnDelegate.txt \
"

do_compile_append() {
	${CC} ../armnnBenchmark.cpp \
		${WORKDIR}/build/tests/CMakeFiles/TfInceptionV3-Armnn.dir/ImagePreprocessor.cpp.o \
		${WORKDIR}/build/tests/CMakeFiles/inferenceTest.dir/InferenceTestImage.cpp.o \
		-o armnnBenchmark -DARMNN_TF_PARSER -DARMNN_TF_LITE_PARSER -DARMNN_ONNX_PARSER \
		-I ${S}/include -I ${S}/tests -I ${S}/src/armnnUtils \
		-I ${S}/src/backends/ -I ${S}/src/armnn/ \
		-I ${STAGING_DIR_TARGET}/usr/include \
		-I ${S}/third-party/ \
		-I ${S}/include/armnn/ \
		-L ${WORKDIR}/build/ \
		-larmnn -larmnnTfLiteParser -larmnnOnnxParser -larmnnTfParser \
		-L ${STAGING_DIR_TARGET}/usr/lib/ -lstdc++ -lm -lpthread ${LDFLAGS}
}

do_compile_append_aarch64() {
	${CC} ../armnnTFLiteDelegateBenchmark.cpp \
		${WORKDIR}/tensorflow/tensorflow/lite/examples/label_image/bitmap_helpers.cc \
		-o armnnTFLiteDelegateBenchmark \
		-I ${S}/include/armnn/ \
		-I ${S}/include -I ${S}/src/armnnUtils \
		-I ${S}/src/backends/ \
		-I ${STAGING_DIR_TARGET}/usr/include \
		-L ${WORKDIR}/build/ \
		-L ${WORKDIR}/build/delegate \
		-L ${STAGING_DIR_TARGET}/usr/lib64/ \
		-larmnn -larmnnDelegate -larmnnUtils \
		-lstdc++ -lm -ldl -lpthread ${LDFLAGS} ${WORKDIR}/recipe-sysroot/usr/lib64/libtensorflow-lite.a
}

do_compile_append_arm() {
	${CC} ../armnnTFLiteDelegateBenchmark.cpp \
		${WORKDIR}/tensorflow/tensorflow/lite/examples/label_image/bitmap_helpers.cc \
		-o armnnTFLiteDelegateBenchmark \
		-I ${S}/include/armnn/ \
		-I ${S}/include -I ${S}/src/armnnUtils \
		-I ${S}/src/backends/ \
		-I ${STAGING_DIR_TARGET}/usr/include \
		-L ${WORKDIR}/build/ \
		-L ${WORKDIR}/build/delegate \
		-L ${STAGING_DIR_TARGET}/usr/lib/ \
		-larmnn -larmnnDelegate -larmnnUtils \
		-lstdc++ -lm -ldl -lpthread ${LDFLAGS} ${WORKDIR}/recipe-sysroot/usr/lib/libtensorflow-lite.a
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

        install -m 0555 \
                ${WORKDIR}/tensorflow/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp \
                ${D}${bindir}/${PN}-${PV}/examples
}

FILES_${PN} += "\
	${bindir}/armnnBenchmark/armnnBenchmark \
	${bindir}/armnnDelegateBenchmark/armnnTFLiteDelegateBenchmark \
	${bindir}/armnnDelegateBenchmark/run_Delegate_measurement.py \
	${bindir}/armnnDelegateBenchmark/test_model_list_armnnDelegate.txt \
	${bindir}/${PN}-${PV}/examples/grace_hopper.bmp \
"
