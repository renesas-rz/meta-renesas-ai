DESCRIPTION = "Arm NN is an inference engine for CPUs, GPUs and NPUs. \
It bridges the gap between existing NN frameworks and the underlying IP."
SUMMARY = "Arm Neural Network SDK"
HOMEPAGE = "https://developer.arm.com/products/processors/machine-learning/arm-nn"
LICENSE = "MIT & Apache-2.0"

# Apache-2.0 license applies to mobilenet tarball
LIC_FILES_CHKSUM = "file://LICENSE;md5=3e14a924c16f7d828b8335a59da64074 \
                    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PACKAGES += "${PN}-tensorflow-lite-examples \
             ${PN}-tensorflow-lite-examples-dbg \
             ${PN}-tensorflow-lite \
             ${PN}-tensorflow-lite-dev \
             ${PN}-tensorflow-examples \
             ${PN}-tensorflow-examples-dbg \
             ${PN}-tensorflow \
             ${PN}-tensorflow-dev \
             ${PN}-onnx-examples \
             ${PN}-onnx-examples-dbg \
             ${PN}-onnx \
             ${PN}-onnx-dev \
             ${PN}-examples ${PN}-examples-dbg \
"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

inherit PyHelper

ARM_NN_GIT_BRANCH_VERSION = "${@replaceChar("${PV}",".","_")}"

SRCREV_FORMAT = "armnn"

S = "${WORKDIR}/git"

inherit cmake

SRC_URI = " \
	git://github.com/ARM-software/armnn.git;name=armnn;branch="branches/armnn_${ARM_NN_GIT_BRANCH_VERSION}" \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_224.tgz;name=mobilenet;subdir=${WORKDIR}/tfmodel;destsuffix=tfmodel \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_224_quant.tgz;name=mobilenetQuant;subdir=${WORKDIR}/tflitemodel;destsuffix=tflitemodel \
	https://s3.amazonaws.com/onnx-model-zoo/mobilenet/mobilenetv2-1.0/mobilenetv2-1.0.onnx;name=mobilenetv2;subdir=${WORKDIR}/onnxmodel;destsuffix=onnxmodel \
	https://github.com/tensorflow/tensorflow/raw/master/tensorflow/examples/label_image/data/grace_hopper.jpg;name=grace_hopper;subdir=${WORKDIR}/images;destsuffix=images \
	file://0001-Remove-the-input-tensor-s-dimension-check.patch \
	file://0001-Change-test-image-set-to-grace_hopper.jpg.patch \
	file://0001-Add-generic-Arm-NN-SDK-inference-framework-and-test-.patch \
	file://0001-Do-not-use-the-CMAKE_FIND_ROOT_PATH-variable-when-lo.patch \
	file://files/rsz_grace_hopper.csv \
	git://github.com/tensorflow/tensorflow.git;name=tensorflow;branch=r2.3;subdir=${WORKDIR}/tensorflow;destsuffix=tensorflow \
	gitsm://github.com/onnx/onnx.git;protocol=https;name=onnx;branch=rel-1.6.0;subdir=${WORKDIR}/onnx;destsuffix=onnx \
"

# v20.11
SRCREV_armnn = "fa52dfeebeda690399d1d32fbeca1d9c33994deb"

# v2.3.1
SRCREV_tensorflow = "fcc4b966f1265f466e82617020af93670141b009"

# v1.6.0
SRCREV_onnx = "553df22c67bee5f0fe6599cff60f1afc6748c635"

SRC_URI[mobilenet.md5sum] = "d5f69cef81ad8afb335d9727a17c462a"
SRC_URI[mobilenet.sha256sum] = "1ccb74dbd9c5f7aea879120614e91617db9534bdfaa53dfea54b7c14162e126b"

SRC_URI[mobilenetQuant.md5sum] = "36af340c00e60291931cb30ce32d4e86"
SRC_URI[mobilenetQuant.sha256sum] = "d32432d28673a936b2d6281ab0600c71cf7226dfe4cdcef3012555f691744166"

SRC_URI[mobilenetv2.md5sum] = "1b8a2fd91dc2b6c78f3cfe846cf16c88"
SRC_URI[mobilenetv2.sha256sum] = "c1c513582d56afceff8516c73804e484c81c6a830712ab6d682253f4a3cd042f"

SRC_URI[grace_hopper.md5sum] = "314296a0a5dd3c394e57f4efac733c20"
SRC_URI[grace_hopper.sha256sum] = "a8ca6d734765703b09728ab47fe59f473d93ae3967fc24c7c0288c3c7adb7130"

DEPENDS = " \
	chrpath-replacement-native \
	protobuf-native \
	boost \
	protobuf \
	stb \
	flatbuffers \
	arm-compute-library \
	vim-native \
"

RDEPENDS_${PN} += "arm-compute-library protobuf boost"

EXTRANATIVEPATH += "chrpath-native"

RDEPENDS_${PN}-tensorflow += "${PN}"

RDEPENDS_${PN}-tensorflow-examples += "${PN}-tensorflow"

RDEPENDS_${PN}-tensorflow-examples-dbg += "${PN}-tensorflow"

RDEPENDS_${PN}-tensorflow-dbg += "${PN}-tensorflow"

RDEPENDS_${PN}-tensorflow-dev += "${PN}-tensorflow"

RDEPENDS_${PN}-tensorflow-lite += "${PN}"

RDEPENDS_${PN}-tensorflow-lite-examples += "${PN}-tensorflow-lite"

RDEPENDS_${PN}-tensorflow-lite-examples-dbg += "${PN}-tensorflow-lite"

RDEPENDS_${PN}-tensorflow-lite-dbg += "${PN}-tensorflow-lite"

RDEPENDS_${PN}-tensorflow-lite-dev += "${PN}-tensorflow-lite"

RDEPENDS_${PN}-onnx += "${PN}"

RDEPENDS_${PN}-onnx-examples += "${PN}-onnx"

RDEPENDS_${PN}-onnx-examples-dbg += "${PN}-onnx"

RDEPENDS_${PN}-onnx-dbg += "${PN}-onnx"

RDEPENDS_${PN}-onnx-dev += "${PN}-onnx"

RDEPENDS_${PN}-examples += "${PN}"

RDEPENDS_${PN}-examples-dbg += "${PN}"

EXTRA_OECMAKE=" \
	-DARMCOMPUTE_ROOT=${STAGING_DIR_TARGET}/usr/share/arm-compute-library/ \
	-DTF_GENERATED_SOURCES=${WORKDIR}/tensorflow/ \
	-DONNX_GENERATED_SOURCES=${WORKDIR}/onnx \
	-DTF_LITE_GENERATED_PATH=${WORKDIR}/tensorflow/tensorflow/lite/schema \
	-DFLATBUFFERS_ROOT=${STAGING_DIR_TARGET}/usr/ \
	-DBOOST_ROOT=${STAGING_DIR_TARGET}/usr/ \
	-DFLATC_DIR=${STAGING_DIR_NATIVE}${prefix}/bin/ \
	-DBUILD_TF_PARSER=1 \
	-DBUILD_TF_LITE_PARSER=1 \
	-DBUILD_ONNX_PARSER=1 \
	-DARMCOMPUTENEON=1 \
	-DBUILD_TESTS=1 \
	-DBUILD_SAMPLE_APP=1 \
	-DPROFILING=1 \
	-DTHIRD_PARTY_INCLUDE_DIRS=${STAGING_DIR_HOST}${includedir} \
	-DBUILD_ARMNN_EXAMPLES=1 \
	-DCMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES=${STAGING_INCDIR} \
"

EXTRA_OECMAKE_append_arm=" \
	-DARMCOMPUTE_BUILD_DIR=${STAGING_DIR_TARGET}/usr/lib/ \
	-DFLATBUFFERS_LIBRARY=${STAGING_DIR_TARGET}/usr/lib/libflatbuffers.a \
	-DPROTOBUF_LIBRARY_DEBUG=${STAGING_DIR_TARGET}/usr/lib/libprotobuf.so.23.0.4 \
	-DPROTOBUF_LIBRARY_RELEASE=${STAGING_DIR_TARGET}/usr/lib/libprotobuf.so.23.0.4 \
"

EXTRA_OECMAKE_append_aarch64=" \
	-DARMCOMPUTE_BUILD_DIR=${STAGING_DIR_TARGET}/usr/lib64/ \
	-DFLATBUFFERS_LIBRARY=${STAGING_DIR_TARGET}/usr/lib64/libflatbuffers.a \
	-DPROTOBUF_LIBRARY_DEBUG=${STAGING_DIR_TARGET}/usr/lib64/libprotobuf.so.23.0.4 \
	-DPROTOBUF_LIBRARY_RELEASE=${STAGING_DIR_TARGET}/usr/lib64/libprotobuf.so.23.0.4 \
"

do_configure_prepend() {
	cd ${WORKDIR}/tensorflow/

	# Convert protobuf sources to C sources and install
	${WORKDIR}/git/scripts/generate_tensorflow_protobuf.sh ${WORKDIR}/tensorflow/ ${STAGING_DIR_NATIVE}${prefix}

	# Install sources + build artifacts as required by Arm NN
	cd ${WORKDIR}/onnx/
	${STAGING_DIR_NATIVE}${prefix}/bin/protoc ${WORKDIR}/onnx/onnx/onnx.proto \
                                                  --proto_path=${WORKDIR}/onnx \
                                                  --proto_path=${STAGING_DIR_NATIVE}${prefix}/include \
                                                  --cpp_out ${WORKDIR}/onnx
	cd ${WORKDIR}/tensorflow/
}

do_install_append() {
	install -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests
	install -d ${D}${bindir}/${PN}-${PV}/examples/SampleApp
	install -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow
	install -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite
	install -d ${D}${bindir}/${PN}-${PV}/examples/onnx
	install -d ${D}${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn
	install -d ${D}${bindir}/${PN}-${PV}/examples/ExecuteNetwork

	install -m 0555 \
		${WORKDIR}/build/samples/SimpleSample \
		${D}${bindir}/${PN}-${PV}/examples/SampleApp/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/SampleApp/*

	install -m 0555 \
		${WORKDIR}/build/tests/TfMobileNet-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow/TfMobileNet-Armnn

	install -m 0555 \
		${WORKDIR}/build/tests/TfLiteMobilenetQuantized-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/TfLiteMobilenetQuantized-Armnn

	install -m 0555 \
		${WORKDIR}/build/tests/OnnxMobileNet-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/onnx/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/onnx/OnnxMobileNet-Armnn

	install -m 0555 \
		${WORKDIR}/build/UnitTests \
		${D}${bindir}/${PN}-${PV}/examples/UnitTests/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/*

	install -m 0555 \
		${WORKDIR}/build/tests/RenesasSample-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn/*

	install -m 0555 \
		${WORKDIR}/build/tests/ExecuteNetwork \
		${D}${bindir}/${PN}-${PV}/examples/ExecuteNetwork/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/ExecuteNetwork/*

	install -d ${D}${includedir}/armnn-tensorflow-lite/schema

	install -m 0644 \
                ${WORKDIR}/tensorflow/tensorflow/lite/schema/schema.fbs \
                ${D}${includedir}/armnn-tensorflow-lite/schema/

	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}

	# Install sample models and images

	install -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow/models
	install -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/models
	install -d ${D}${bindir}/${PN}-${PV}/examples/onnx/models
	install -d ${D}${bindir}/${PN}-${PV}/examples/images

	install -m 0644 \
		${WORKDIR}/images/grace_hopper.jpg \
		${D}${bindir}/${PN}-${PV}/examples/images/

	install -m 0644 \
		${WORKDIR}/files/rsz_grace_hopper.csv \
		${D}${bindir}/${PN}-${PV}/examples/images/

	install -m 0644 \
		${WORKDIR}/tfmodel/mobilenet_v1_1.0_224_frozen.pb \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow/models

	install -m 0644 \
		${WORKDIR}/git/tests/TfMobileNet-Armnn/labels.txt \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow/models

	install -m 0644 \
		${WORKDIR}/onnxmodel/mobilenetv2-1.0.onnx \
		${D}${bindir}/${PN}-${PV}/examples/onnx/models

	install -m 0644 \
		${WORKDIR}/tflitemodel/mobilenet_v1_1.0_224_quant.tflite \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/models

	install -m 0644 \
		${WORKDIR}/git/tests/TfMobileNet-Armnn/labels.txt \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/models

	#Remove Unsupported Caffe Parser files
	rm -rf ${D}/${includedir}/armnnCaffeParser

	#Install backend unit test utilities
	install -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test
        
	install -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic/reference/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/testSharedObject \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/testDynamicBackend \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath1 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath2 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath3 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath5 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath6 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath7 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath9 \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/dynamic/reference/Arm_CpuRef_backend.so \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic/reference/

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/testDynamicBackend/*

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/backendsTestPath5/*

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/backendsTestPath9/*

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/backendsTestPath6/*

	chrpath -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic/reference/*

	# Remove files that are not needed
	find ${D} -iname "*.cmake" -exec rm -f '{}' \;
	rm -rf ${D}${libdir}/cmake/
}

CXXFLAGS += "-fopenmp"
LIBS += "-larmpl_lp64_mp"

FILES_${PN} = " \
	${libdir}/libarmnn.so* \
	${libdir}/libarmnnBasePipeServer.so* \
	${libdir}/libtimelineDecoder.so* \
	${libdir}/libtimelineDecoderJson.so* \
"

FILES_${PN}-dev = " \
	${includedir}/armnn \
	${includedir}/armnnDeserializer \
	${includedir}/armnnSerializer \
	${includedir}/armnnQuantizer \
	${includedir}/armnnUtils \
"

FILES_${PN}-dbg = " \
	${libdir}/.debug \
	${prefix}/src/debug \
"

FILES_${PN}-examples = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${PV}/examples/UnitTests \
	${bindir}/${PN}-${PV}/examples/SampleApp \
	${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn \
	${bindir}/${PN}-${PV}/examples/images \
	${bindir}/${PN}-${PV}/examples/ExecuteNetwork \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic \
"

FILES_${PN}-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/SampleApp/.debug \
	${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn/.debug \
	${bindir}/${PN}-${PV}/examples/UnitTests/.debug \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/testSharedObject/.debug \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/testDynamicBackend/.debug \
"

FILES_${PN}-tensorflow-lite-examples = " \
	${bindir}/${PN}-${PV}/examples/tensorflow-lite \
"

FILES_${PN}-tensorflow-lite-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/tensorflow-lite/.debug \
"

FILES_${PN}-tensorflow-lite = " \
	${libdir}/libarmnnTfLiteParser.so* \
	${includedir}/armnn-tensorflow-lite/schema \
"

FILES_${PN}-tensorflow-lite-dbg = " \
	${libdir}/.debug/libarmnnTfLiteParser.so* \
"

FILES_${PN}-tensorflow-lite-dev = " \
	${includedir}/armnnTfLiteParser \
"

FILES_${PN}-tensorflow-examples = " \
	${bindir}/${PN}-${PV}/examples/tensorflow \
"

FILES_${PN}-tensorflow-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/tensorflow/.debug \
"

FILES_${PN}-tensorflow = " \
	${libdir}/libarmnnTfParser.so* \
"

FILES_${PN}-tensorflow-dbg = " \
	${libdir}/.debug/libarmnnTfParser.so \
"

FILES_${PN}-tensorflow-dev = " \
	${includedir}/armnnTfParser \
"

FILES_${PN}-onnx-examples = " \
	${bindir}/${PN}-${PV}/examples/onnx \
"

FILES_${PN}-onnx-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/onnx/.debug \
"

FILES_${PN}-onnx = " \
	${libdir}/libarmnnOnnxParser.so* \
"

FILES_${PN}-onnx-dbg = " \
	${libdir}/.debug/libarmnnOnnxParser.so \
"

FILES_${PN}-onnx-dev = " \
	${includedir}/armnnOnnxParser \
	${includedir}/armnnOnnxParser/IOnnxParser.hpp \
"

FILES_${PN}-dev += "${libdir}/cmake/*"
INSANE_SKIP_${PN}-dev = "dev-elf"
INSANE_SKIP_${PN} = "dev-deps dev-so"
INSANE_SKIP_${PN}-examples = "dev-so libdir"
INSANE_SKIP_${PN}-examples-dbg = "libdir"
INSANE_SKIP_${PN}-onnx = "dev-so"
INSANE_SKIP_${PN}-tensorflow = "dev-so"
INSANE_SKIP_${PN}-tensorflow-lite = "dev-so"
