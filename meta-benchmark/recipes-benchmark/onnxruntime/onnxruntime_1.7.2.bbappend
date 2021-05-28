FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "models-onnx"

SRC_URI += " \
	file://onnxruntime_benchmark.cpp \
	file://test_file_list_models.txt \
	file://onnxruntime_benchmark.sh \
"

do_compile_append() {
	${CXX} -std=c++14 ${S}/../../onnxruntime_benchmark.cpp -DONNX_ML \
		${S}/external/FeaturizersLibrary/src/3rdParty/MurmurHash3.cpp \
		-I ${S}/../onnxruntime \
		-I ${S}/../include/onnxruntime  \
		-I ${S}/../include/onnxruntime/core/session/ \
		-I ${S}/../cmake/external/onnx \
		-I ${S}/../../build \
		${S}/../../build/libonnxruntime_session.a \
		${S}/../../build/libonnxruntime_optimizer.a \
		${S}/../../build/libonnxruntime_providers.a \
		${S}/../../build/libonnxruntime_util.a \
		${S}/../../build/libonnxruntime_flatbuffers.a \
		${S}/../../build/libonnxruntime_framework.a \
		${S}/../../build/libonnxruntime_graph.a \
		${S}/../../build/libonnxruntime_common.a \
		${S}/../../build/libonnxruntime_mlas.a \
		${S}/../../build/external/onnx/libonnx.a \
		${S}/../../build/external/onnx/libonnx_proto.a \
		${S}/../../build/external/protobuf/cmake/libprotobuf-lite.a \
		${S}/../../build/external/nsync/libnsync_cpp.a \
		${S}/../../build/external/FeaturizersLibrary/libFeaturizersCode.a \
		${S}/../../build/external/FeaturizersLibrary/libFeaturizersComponentsCode.a \
		${S}/../../build/external/FeaturizersLibrary/libFeaturizer3rdParty.a \
		${S}/../../build/external/FeaturizersLibrary/3rdParty/re2/libre2.a \
		-lpthread -fopenmp -ldl ${LDFLAGS} -L . -o onnxruntime_benchmark
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
