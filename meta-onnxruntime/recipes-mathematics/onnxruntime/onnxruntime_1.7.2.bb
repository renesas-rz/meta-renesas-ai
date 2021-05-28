DESCRIPTION = "ONNX Runtime is an open-source scoring engine for Open Neural \
Network Exchange (ONNX) models. ONNX Runtime has an open architecture that \
is continually evolving to address the newest developments and challenges \
in AI and Deep Learning."
SUMMARY = "ONNX Runtime"
HOMEPAGE = "https://github.com/microsoft/onnxruntime"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${S}/../LICENSE;md5=0f7e3b1308cb5c00b372a6e78835732d"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

PACKAGES += "${PN}-examples ${PN}-examples-dbg"

SRCREV_FORMAT = "onnxruntime"

SRCREV_onnxruntime ="5bc92dff16b0ddd5063b717fb8522ca2ad023cb0"

S = "${WORKDIR}/git/cmake"

inherit cmake

#synset_words.txt is inspired from https://github.com/HoldenCaulfieldRye/caffe/blob/master/data/ilsvrc12/synset_words.txt
#grace_hopper_224_224.jpg is inspired from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/label_image/data/grace_hopper.jpg

SRC_URI = " \
	gitsm://github.com/microsoft/onnxruntime.git;protocol=git;branch=rel-1.7.2;name=onnxruntime \
	file://patches/0001-Fix-no-test-cases-are-loaded-in-onnxruntime-test-cod.patch;patchdir=${WORKDIR}/git \
	file://patches/0001-Work-around-featurizers_ops-test-build-failure.patch;patchdir=${WORKDIR}/git \
	file://files/onnxruntime_inference_example.cpp \
	file://files/grace_hopper_224_224.jpg \
	file://files/synset_words.txt \
	https://s3.amazonaws.com/download.onnx/models/opset_9/squeezenet.tar.gz;name=onnx-squeezenet;subdir=${WORKDIR}/onnx-squeezenet \
	https://s3.amazonaws.com/onnx-model-zoo/mobilenet/mobilenetv2-1.0/mobilenetv2-1.0.onnx;name=mobilenetv2;subdir=${WORKDIR}/onnxmodel;destsuffix=onnxmodel \
"

SRC_URI[onnx-squeezenet.md5sum] = "92e240a948f9bbc92534d752eb465317"
SRC_URI[onnx-squeezenet.sha256sum] = "f4c9a2906a949f089bee5ef1bf9ea1c0dc1b49d5abeb1874fff3d206751d0f3b"

SRC_URI[grace_hopper.md5sum] = "314296a0a5dd3c394e57f4efac733c20"
SRC_URI[grace_hopper.sha256sum] = "a8ca6d734765703b09728ab47fe59f473d93ae3967fc24c7c0288c3c7adb7130"

SRC_URI[mobilenetv2.md5sum] = "1b8a2fd91dc2b6c78f3cfe846cf16c88"
SRC_URI[mobilenetv2.sha256sum] = "c1c513582d56afceff8516c73804e484c81c6a830712ab6d682253f4a3cd042f"

DEPENDS = " \
	cmake-native \
	protobuf3.11.3-native \
	stb \
	zlib \
"

EXTRA_OECMAKE=" \
	-DCMAKE_SYSTEM_NAME=Linux \
	-DCMAKE_SYSTEM_PROCESSOR=arm \
	-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
	-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
	-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
	-DONNX_CUSTOM_PROTOC_EXECUTABLE=${STAGING_DIR_NATIVE}${prefix}/bin/protoc \
	-Donnxruntime_USE_OPENMP=ON \
	-Donnxruntime_USE_FEATURIZERS=ON \
"

# Allow cmake to find binaries on the host
OECMAKE_FIND_ROOT_PATH_MODE_PROGRAM = "BOTH"

do_compile_append() {
	${CXX} -std=c++14 ${S}/../../files/onnxruntime_inference_example.cpp -DONNX_ML \
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
		-lpthread -fopenmp -ldl ${LDFLAGS} -o onnxruntime_inference_example
}

do_install() {
	install -d ${D}${includedir}/onnxruntime

	install -d ${D}${libdir}

	cp --parents \
		$(find . -name "*.a") \
		${D}/${libdir}

	install -d ${D}${bindir}/${PN}-${PV}/examples

	install -d ${D}${bindir}/${PN}-${PV}/examples/unitest

	install -d ${D}${bindir}/${PN}-${PV}/examples/inference

	install -d ${D}${bindir}/${PN}-${PV}/examples/images

	cp -r \
		${WORKDIR}/onnx-squeezenet/squeezenet \
		${D}${bindir}/${PN}-${PV}/examples/unitest

	install -m 0555 \
		${WORKDIR}/build/onnx_test_runner \
		${D}${bindir}/${PN}-${PV}/examples/unitest

	install -m 0644 \
		${WORKDIR}/onnxmodel/mobilenetv2-1.0.onnx \
		${D}${bindir}/${PN}-${PV}/examples/inference

	install -m 0644 \
		${WORKDIR}/files/synset_words.txt \
		${D}${bindir}/${PN}-${PV}/examples/inference

	install -m 0555 \
		${WORKDIR}/build/onnxruntime_inference_example \
		${D}${bindir}/${PN}-${PV}/examples/inference

	install -m 0644 \
		${WORKDIR}/files/grace_hopper_224_224.jpg \
		${D}${bindir}/${PN}-${PV}/examples/images/

	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

CXXFLAGS += "-fopenmp"

ALLOW_EMPTY_${PN} = "1"

FILES_${PN} = ""

FILES_${PN}-dev = " \
	${includedir} \
"

FILES_${PN}-staticdev = " \
	${libdir} \
"

FILES_${PN}-examples = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${PV}/examples/inference \
	${bindir}/${PN}-${PV}/examples/unitest \
	${bindir}/${PN}-${PV}/examples/images \
"

FILES_${PN}-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/unitest/.debug \
	${bindir}/${PN}-${PV}/examples/inference/.debug \
"
