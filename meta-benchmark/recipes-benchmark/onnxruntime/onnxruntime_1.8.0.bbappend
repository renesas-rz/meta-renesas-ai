FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "models-onnx"

SRC_URI += " \
	file://onnxruntime_benchmark.cpp \
	file://test_file_list_models.txt \
	file://onnxruntime_benchmark.sh \
	https://s3.amazonaws.com/download.onnx/models/opset_9/squeezenet.tar.gz;name=onnx-squeezenet;subdir=${WORKDIR}/onnx-squeezenet \
"

SRC_URI[onnx-squeezenet.md5sum] = "92e240a948f9bbc92534d752eb465317"
SRC_URI[onnx-squeezenet.sha256sum] = "f4c9a2906a949f089bee5ef1bf9ea1c0dc1b49d5abeb1874fff3d206751d0f3b"

do_compile_append() {
	${CXX} -std=c++14 ${WORKDIR}/onnxruntime_benchmark.cpp -DONNX_ML \
		-I ${S}/onnxruntime \
		-I ${S}/include/onnxruntime  \
		-I ${S}/include/onnxruntime/core/session/ \
		-I ${S}/cmake/external/onnx \
		-I ${B} \
		${B}/libonnxruntime_session.a \
		${B}/libonnxruntime_optimizer.a \
		${B}/libonnxruntime_providers.a \
		${B}/libonnxruntime_util.a \
		${B}/libonnxruntime_flatbuffers.a \
		${B}/libonnxruntime_framework.a \
		${B}/libonnxruntime_graph.a \
		${B}/libonnxruntime_common.a \
		${B}/libonnxruntime_mlas.a \
		${B}/external/onnx/libonnx.a \
		${B}/external/onnx/libonnx_proto.a \
		${B}/external/protobuf/cmake/libprotobuf-lite.a \
		${B}/external/nsync/libnsync_cpp.a \
		-lre2 -lpthread -fopenmp -ldl ${LDFLAGS} -L . -o onnxruntime_benchmark
}

do_install_append() {
	install -d ${D}${bindir}/onnxruntime_benchmark

	install -m 0644 ${WORKDIR}/test_file_list_models.txt ${D}${bindir}/onnxruntime_benchmark/

	install -m 0555 ${WORKDIR}/onnxruntime_benchmark.sh ${D}${bindir}/onnxruntime_benchmark/

	install -m 0555 ${B}/onnxruntime_benchmark ${D}${bindir}/onnxruntime_benchmark/

	cp -r \
		${WORKDIR}/onnx-squeezenet/squeezenet \
		${D}${bindir}/${PN}-${PV}/examples/unittest
}

FILES_${PN} += "\
	${bindir}/onnxruntime_benchmark/* \
"
