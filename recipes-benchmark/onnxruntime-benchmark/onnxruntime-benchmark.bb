DESCRIPTION = "Provides an application and test files to measure the \
performance of ONNX Runtime."
SUMMARY = "ONNX Runtime Benchmark application and test files"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} += "models-onnx onnxruntime"
DEPENDS += "stb re2 onnxruntime"

SRC_URI += " \
	file://onnxruntime_benchmark.cpp \
	file://onnxruntime_benchmark.sh \
	file://grace_hopper_224_224.jpg \
	file://synset_words.txt \
	file://test_file_list_models.txt \
"

do_compile() {
	${CXX} -std=c++14 ../onnxruntime_benchmark.cpp \
		-lonnxruntime -fopenmp -ldl ${LDFLAGS} \
		-o ../onnxruntime_benchmark
}

do_install() {
	mkdir -p ${D}${bindir}/onnxruntime_benchmark
	install -d ${D}${bindir}/onnxruntime_benchmark

	install -m 0644 ${WORKDIR}/test_file_list_models.txt ${D}${bindir}/onnxruntime_benchmark/
	install -m 0555 ${WORKDIR}/onnxruntime_benchmark.sh ${D}${bindir}/onnxruntime_benchmark/
	install -m 0555 ${WORKDIR}/onnxruntime_benchmark ${D}${bindir}/onnxruntime_benchmark/

	install -m 0644 \
		${WORKDIR}/synset_words.txt \
		${D}${bindir}/onnxruntime_benchmark/

	install -m 0644 \
		${WORKDIR}/grace_hopper_224_224.jpg \
		${D}${bindir}/onnxruntime_benchmark/
}

FILES_${PN} = "${bindir}/onnxruntime_benchmark/*"
