DESCRIPTION = "ONNX Runtime is an open-source scoring engine for Open Neural \
Network Exchange (ONNX) models. ONNX Runtime has an open architecture that \
is continually evolving to address the newest developments and challenges \
in AI and Deep Learning."
SUMMARY = "ONNX Runtime"
HOMEPAGE = "https://github.com/microsoft/onnxruntime"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${S}/../LICENSE;md5=980784f0a7f667becbed133924b263bf"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2m|hihope-rzg2n|ek874)"

PACKAGES += "${PN}-examples ${PN}-examples-dbg"

SRCREV_FORMAT = "onnxruntime"

SRCREV_onnxruntime ="a8efa42d6885212627f0e4e3bd251caedc6a8d7c"

S = "${WORKDIR}/git/cmake"

inherit cmake

#synset_words.txt is inspired from https://github.com/HoldenCaulfieldRye/caffe/blob/master/data/ilsvrc12/synset_words.txt
#grace_hopper_224_224.jpg is inspired from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/label_image/data/grace_hopper.jpg

SRC_URI = " \
	gitsm://github.com/microsoft/onnxruntime.git;protocol=git;branch=rel-1.1.2;name=onnxruntime \
	file://patches/0001-Fix-no-test-cases-are-loaded-in-onnxruntime-test-cod.patch;patchdir=${WORKDIR}/git \
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
	protobuf3.6.1-native \
	stb \
	zlib \
"

EXTRA_OECMAKE=" \
	-Donnxruntime_USE_OPENMP=ON \
	-DONNX_CUSTOM_PROTOC_EXECUTABLE=${STAGING_DIR_NATIVE}${prefix}/bin/protoc \
	-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
	-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
	-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
	-DCMAKE_SYSTEM_PROCESSOR=arm \
"

do_compile_append() {
	${CXX} -std=c++14 ${S}/../../files/onnxruntime_inference_example.cpp -DONNX_ML \
		-I ${S}/../include/onnxruntime/core/session/ \
		-I ${S}/../cmake/external/onnx/ ${S}/../../build/libonnxruntime_session.a \
		${S}/../../build/libonnxruntime_providers.a ${S}/../../build/libonnxruntime_framework.a \
		${S}/../../build/libonnxruntime_optimizer.a ${S}/../../build/libonnxruntime_graph.a \
		${S}/../../build/libonnxruntime_common.a  ${S}/../../build/onnx/libonnx_proto.a \
		${S}/../../build/libautoml_featurizers.a \
		${S}/../../build/external/protobuf/cmake/libprotobuf.a ${S}/../../build//external/re2/libre2.a \
		${S}/../../build/libonnxruntime_util.a ${S}/../../build/libonnxruntime_mlas.a \
		${S}/../../build/onnx/libonnx.a  -lpthread -fopenmp -ldl ${LDFLAGS} -o onnxruntime_inference_example
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
