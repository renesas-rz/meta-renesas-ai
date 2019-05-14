FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://onnxruntime_benchmark.cpp \
	file://test_file_list_models.txt \
	file://onnxruntime_benchmark.sh \
"

do_compile_append() {
	${CXX} -std=c++14 ${S}/../../onnxruntime_benchmark.cpp -DONNX_ML -I ${S}/../include/onnxruntime/core/session/ \
		-I ${S}/../cmake/external/onnx/ ${S}/../../build/libonnxruntime_session.a \
		${S}/../../build/libonnxruntime_providers.a ${S}/../../build/libonnxruntime_framework.a \
		${S}/../../build/libonnxruntime_optimizer.a ${S}/../../build/libonnxruntime_graph.a \
		${S}/../../build/libonnxruntime_common.a  ${S}/../../build/onnx/libonnx_proto.a \
		${S}/../../build/external/protobuf/cmake/libprotobuf.a ${S}/../../build//external/re2/libre2.a \
		${S}/../../build/libonnxruntime_util.a ${S}/../../build/libonnxruntime_mlas.a \
		${S}/../../build/onnx/libonnx.a  -lpthread -fopenmp -ldl ${LDFLAGS} -L . -o onnxruntime_benchmark
}

do_install_append() {
	install -d ${D}${bindir}/onnxruntime_benchmark

	install -m 0644 ${S}/../../test_file_list_models.txt ${D}${bindir}/onnxruntime_benchmark/

	install -m 0555 ${S}/../../onnxruntime_benchmark.sh ${D}${bindir}/onnxruntime_benchmark/

	install -m 0555 ${WORKDIR}/build/onnxruntime_benchmark ${D}${bindir}/onnxruntime_benchmark/
}

FILES_${PN} += "\
	${bindir}/onnxruntime_benchmark/* \
"
