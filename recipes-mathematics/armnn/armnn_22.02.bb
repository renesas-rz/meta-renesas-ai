DESCRIPTION = "Arm NN is an inference engine for CPUs, GPUs and NPUs. \
It bridges the gap between existing NN frameworks and the underlying IP."
SUMMARY = "Arm Neural Network SDK"
HOMEPAGE = "https://developer.arm.com/products/processors/machine-learning/arm-nn"
LICENSE = "MIT & Apache-2.0"

# Apache-2.0 license applies to mobilenet tarball
LIC_FILES_CHKSUM = "file://LICENSE;md5=3e14a924c16f7d828b8335a59da64074 \
                    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

PACKAGES += " \
	${PN}-tensorflow-lite \
	${PN}-tensorflow-lite-dev \
	${PN}-onnx-examples \
	${PN}-onnx-examples-dbg \
	${PN}-onnx \
	${PN}-onnx-dev \
	${PN}-examples \
	${PN}-examples-dbg \
"

inherit cmake PyHelper

ARM_NN_GIT_BRANCH_VERSION = "${@replaceChar("${PV}",".","_")}"

SRCREV_FORMAT = "armnn"

S = "${WORKDIR}/git"

SRC_URI = " \
	git://github.com/ARM-software/armnn.git;name=armnn;branch="branches/armnn_${ARM_NN_GIT_BRANCH_VERSION}" \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_224_quant.tgz;name=mobilenetQuant;subdir=${WORKDIR}/tflitemodel;destsuffix=tflitemodel \
	https://s3.amazonaws.com/onnx-model-zoo/mobilenet/mobilenetv2-1.0/mobilenetv2-1.0.onnx;name=mobilenetv2;subdir=${WORKDIR}/onnxmodel;destsuffix=onnxmodel \
	https://github.com/tensorflow/tensorflow/raw/master/tensorflow/examples/label_image/data/grace_hopper.jpg;name=grace_hopper;subdir=${WORKDIR}/images;destsuffix=images \
	gitsm://github.com/onnx/onnx.git;protocol=https;name=onnx;branch=rel-1.6.0;subdir=${WORKDIR}/onnx;destsuffix=onnx \
	file://0001-Remove-the-input-tensor-s-dimension-check.patch \
	file://0001-Change-test-image-set-to-grace_hopper.jpg.patch \
	file://0001-Add-generic-Arm-NN-SDK-inference-framework-and-test-.patch \
	file://0001-Do-not-use-the-CMAKE_FIND_ROOT_PATH-variable-when-lo.patch \
	file://rsz_grace_hopper.csv \
"

# v22.02
SRCREV_armnn = "b254731ff27a40f382695d5753e1b537c4736bfa"

# v1.6.0
SRCREV_onnx = "553df22c67bee5f0fe6599cff60f1afc6748c635"

SRC_URI[mobilenetQuant.md5sum] = "36af340c00e60291931cb30ce32d4e86"
SRC_URI[mobilenetQuant.sha256sum] = "d32432d28673a936b2d6281ab0600c71cf7226dfe4cdcef3012555f691744166"

SRC_URI[mobilenetv2.md5sum] = "1b8a2fd91dc2b6c78f3cfe846cf16c88"
SRC_URI[mobilenetv2.sha256sum] = "c1c513582d56afceff8516c73804e484c81c6a830712ab6d682253f4a3cd042f"

SRC_URI[grace_hopper.md5sum] = "314296a0a5dd3c394e57f4efac733c20"
SRC_URI[grace_hopper.sha256sum] = "a8ca6d734765703b09728ab47fe59f473d93ae3967fc24c7c0288c3c7adb7130"

DEPENDS = " \
	arm-compute-library \
	chrpath-replacement-native \
	protobuf-native \
	protobuf \
	stb \
	tensorflow-lite \
	vim-native \
"

RDEPENDS_${PN} += " \
	arm-compute-library \
	protobuf \
	python3-numpy \
"

EXTRANATIVEPATH += "chrpath-native"

# Tensorflow-lite RDEPENDS
RDEPENDS_${PN}-tensorflow-lite += "${PN}"
RDEPENDS_${PN}-tensorflow-lite-dbg += "${PN}-tensorflow-lite"
RDEPENDS_${PN}-tensorflow-lite-dev += "${PN}-tensorflow-lite"
RDEPENDS_${PN}-tensorflow-lite-staticdev += "${PN}-tensorflow-lite"

# ONNX RDEPENDS
RDEPENDS_${PN}-onnx += "${PN}"
RDEPENDS_${PN}-onnx-examples += "${PN}-onnx"
RDEPENDS_${PN}-onnx-examples-dbg += "${PN}-onnx"
RDEPENDS_${PN}-onnx-dbg += "${PN}-onnx"
RDEPENDS_${PN}-onnx-dev += "${PN}-onnx"

# ArmNN RDEPENDS
RDEPENDS_${PN}-examples += "${PN}"
RDEPENDS_${PN}-examples-dbg += "${PN}"

EXTRA_OECMAKE= " \
	-DARMCOMPUTE_ROOT=${STAGING_DIR_TARGET}/usr/share/arm-compute-library/ \
	-DONNX_GENERATED_SOURCES=${WORKDIR}/onnx \
	-DTF_LITE_GENERATED_PATH=${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/schema/ \
	-DFLATBUFFERS_ROOT=${STAGING_DIR_TARGET}/usr/ \
	-DFLATC_DIR=${STAGING_DIR_NATIVE}${prefix}/bin/ \
	-DBUILD_TF_LITE_PARSER=1 \
	-DBUILD_ONNX_PARSER=1 \
	-DARMCOMPUTENEON=1 \
	-DBUILD_TESTS=1 \
	-DBUILD_SAMPLE_APP=1 \
	-DPROFILING=1 \
	-DTHIRD_PARTY_INCLUDE_DIRS=${STAGING_DIR_HOST}${includedir} \
	-DBUILD_ARMNN_EXAMPLES=1 \
	-DCMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES=${STAGING_INCDIR} \
	-DBUILD_ARMNN_TFLITE_DELEGATE=1 \
	-DTfLite_INCLUDE_DIR=${STAGING_DIR_TARGET}/usr/include/tensorflow_lite/ \
	-DTfLite_Schema_INCLUDE_PATH=${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/schema/ \
	-DTFLITE_LIB_ROOT=${STAGING_DIR_TARGET}/usr/include/tensorflow/lite/ \
	-DCMAKE_SYSROOT=${STAGING_DIR_TARGET} \
	-DARMCOMPUTE_BUILD_DIR=${STAGING_DIR_TARGET}/usr/lib64/ \
	-DTfLite_LIB=${STAGING_DIR_TARGET}/usr/lib64/libtensorflow-lite.a \
	-DFLATBUFFERS_LIBRARY=${STAGING_DIR_TARGET}/usr/lib64/libflatbuffers.a \
	-DPROTOBUF_LIBRARY_DEBUG=${STAGING_DIR_TARGET}/usr/lib64/libprotobuf.so.23.0.4 \
	-DPROTOBUF_LIBRARY_RELEASE=${STAGING_DIR_TARGET}/usr/lib64/libprotobuf.so.23.0.4 \
	-DCMAKE_CXX_STANDARD_LIBRARIES="-ldl -fopenmp \
	${STAGING_DIR_TARGET}/usr/lib64/libtensorflow-lite.a \
	${STAGING_DIR_TARGET}/usr/lib64/libXNNPACK.a \
	${STAGING_DIR_TARGET}/usr/lib64/libcpuinfo.a \
	${STAGING_DIR_TARGET}/usr/lib64/libclog.a \
	${STAGING_DIR_TARGET}/usr/lib64/libpthreadpool.a" \
"

EXTRA_OECMAKE_append_smarc-rzg2l  = "-DARMCOMPUTECL=1"
EXTRA_OECMAKE_append_smarc-rzg2lc = "-DARMCOMPUTECL=1"
EXTRA_OECMAKE_append_smarc-rzv2l = "-DARMCOMPUTECL=1"

do_configure_prepend() {
	# Install sources + build artifacts as required by Arm NN
	cd ${WORKDIR}/onnx/
	${STAGING_DIR_NATIVE}${prefix}/bin/protoc ${WORKDIR}/onnx/onnx/onnx.proto \
                                                  --proto_path=${WORKDIR}/onnx \
                                                  --proto_path=${STAGING_DIR_NATIVE}${prefix}/include \
                                                  --cpp_out ${WORKDIR}/onnx
}

do_install_append() {
	install -d ${D}${bindir}/${PN}-${PV}/examples/DelegateUnitTests
	install -d ${D}${bindir}/${PN}-${PV}/examples/ExecuteNetwork
	install -d ${D}${bindir}/${PN}-${PV}/examples/onnx
	install -d ${D}${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn
	install -d ${D}${bindir}/${PN}-${PV}/examples/SampleApp
	install -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite
	install -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests

	install -m 0555 \
		${WORKDIR}/build/samples/SimpleSample \
		${D}${bindir}/${PN}-${PV}/examples/SampleApp/

	install -m 0555 \
		${WORKDIR}/build/tests/TfLiteMobilenetQuantized-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/

	install -m 0555 \
		${WORKDIR}/build/tests/OnnxMobileNet-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/onnx/

	install -m 0555 \
		${WORKDIR}/build/UnitTests \
		${D}${bindir}/${PN}-${PV}/examples/UnitTests/

	install -m 0555 \
		${WORKDIR}/build/delegate/DelegateUnitTests \
		${D}${bindir}/${PN}-${PV}/examples/DelegateUnitTests/

	install -d ${D}${includedir}/delegate/
	install -m 0555 \
		${S}/delegate/include/* \
		${D}${includedir}/delegate/

	install -m 0555 \
		${WORKDIR}/build/tests/RenesasSample-Armnn \
		${D}${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn/

	install -m 0555 \
		${WORKDIR}/build/tests/ExecuteNetwork \
		${D}${bindir}/${PN}-${PV}/examples/ExecuteNetwork/

	install -d ${D}${includedir}/armnn/renesas
	install -d ${D}${includedir}/tests
	install -d ${D}${includedir}/profiling/common/include/*
	install -d ${D}${includedir}/third-party/mapbox
	install -d ${D}${includedir}/third-party/ghc
	install -d ${D}${includedir}/third-party/fmt
	install -d ${D}${includedir}/third-party/cxxopts

	install -m 0555 ${S}/src/armnn/*.hpp ${D}${includedir}/armnn/
	install -m 0555 ${S}/tests/*.hpp ${D}${includedir}/tests/
	install -m 0555 ${S}/tests/*.inl ${D}${includedir}/tests/
	install -m 0555 ${S}/profiling/common/include/* ${D}${includedir}/profiling/common/include
	install -m 0555 ${S}/third-party/mapbox/* ${D}${includedir}/third-party/mapbox
	install -m 0555 ${S}/third-party/ghc/* ${D}${includedir}/third-party/ghc
	install -m 0555 ${S}/third-party/fmt/*.h ${D}${includedir}/third-party/fmt
	install -m 0555 ${S}/third-party/cxxopts/*.h* ${D}${includedir}/third-party/cxxopts
	install -m 0555 ${S}/src/armnnUtils/*.hpp ${D}${includedir}/armnn

	cp -Ravp ${WORKDIR}/build/tests/CMakeFiles/RenesasSample-Armnn.dir/*.cpp.o \
		 ${D}${includedir}/armnn/renesas

	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}

	# Install sample models and images
	install -d ${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/models
	install -d ${D}${bindir}/${PN}-${PV}/examples/onnx/models
	install -d ${D}${bindir}/${PN}-${PV}/examples/images

	install -m 0644 \
		${WORKDIR}/images/grace_hopper.jpg \
		${D}${bindir}/${PN}-${PV}/examples/images/

	install -m 0644 \
		${WORKDIR}/rsz_grace_hopper.csv \
		${D}${bindir}/${PN}-${PV}/examples/images/

	install -m 0644 \
		${WORKDIR}/onnxmodel/mobilenetv2-1.0.onnx \
		${D}${bindir}/${PN}-${PV}/examples/onnx/models

	install -m 0644 \
		${WORKDIR}/tflitemodel/mobilenet_v1_1.0_224_quant.tflite \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/models

	install -m 0644 \
		${WORKDIR}/git/tests/TfLiteMobilenetQuantized-Armnn/labels.txt \
		${D}${bindir}/${PN}-${PV}/examples/tensorflow-lite/models

	# Install backend unit test utilities
	install -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test

	install -d ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic/reference/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/testSharedObject \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/testDynamicBackend \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	cp -Pr ${WORKDIR}/build/src/backends/backendsCommon/test/backendsTestPath* \
	       ${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/

	install ${WORKDIR}/build/src/backends/dynamic/reference/Arm_CpuRef_backend.so \
		${D}${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic/reference/

	# Remove files that are not needed
	find ${D} -iname "*.cmake" -exec rm -f '{}' \;
	rm -rf ${D}${libdir}/cmake/
}

CXXFLAGS += "-fopenmp"
LIBS += "-larmpl_lp64_mp"

FILES_${PN} = " \
	${libdir}/libarmnn.so* \
	${libdir}/libarmnnBasePipeServer.so* \
	${libdir}/libarmnnDelegate.so* \
	${libdir}/libarmnnTestUtils.so \
	${libdir}/libtimelineDecoder.so* \
	${libdir}/libtimelineDecoderJson.so* \
	${includedir}/tests/* \
	${includedir}/third-party/mapbox/* \
	${includedir}/third-party/ghc/* \
	${includedir}/third-party/fmt/* \
	${includedir}/third-party/cxxopts/* \
	${includedir}/profiling/common/include/* \
	${includedir}/armnn/* \
	${includedir}/armnn/renesas/* \
"

FILES_${PN}-dev = " \
	${includedir}/armnn \
	${includedir}/armnnDeserializer \
	${includedir}/armnnSerializer \
	${includedir}/armnnTestUtils \
	${includedir}/armnnUtils \
	${includedir}/delegate \
"

FILES_${PN}-dbg = " \
	${libdir}/.debug \
	${prefix}/src/debug \
"

FILES_${PN}-examples = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${PV}/examples/DelegateUnitTests \
	${bindir}/${PN}-${PV}/examples/ExecuteNetwork \
	${bindir}/${PN}-${PV}/examples/images \
	${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn \
	${bindir}/${PN}-${PV}/examples/SampleApp \
	${bindir}/${PN}-${PV}/examples/UnitTests \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/dynamic \
"

FILES_${PN}-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/RenesasSample-Armnn/.debug \
	${bindir}/${PN}-${PV}/examples/SampleApp/.debug \
	${bindir}/${PN}-${PV}/examples/UnitTests/.debug \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/testSharedObject/.debug \
	${bindir}/${PN}-${PV}/examples/UnitTests/src/backends/backendsCommon/test/testDynamicBackend/.debug \
"

# Tensorflow-lite files
FILES_${PN}-tensorflow-lite = " \
	${libdir}/libarmnnTfLiteParser.so* \
	${includedir}/armnn-tensorflow-lite/schema \
	${bindir}/${PN}-${PV}/examples/tensorflow-lite \
"
FILES_${PN}-tensorflow-lite-dbg = "${libdir}/.debug/libarmnnTfLiteParser.so*"
FILES_${PN}-tensorflow-lite-dev = " \
	${includedir}/armnnTfLiteParser \
	${bindir}/${PN}-${PV}/examples/tensorflow-lite/.debug \
"

# ONNX files
FILES_${PN}-onnx = "${libdir}/libarmnnOnnxParser.so*"
FILES_${PN}-onnx-dbg = "${libdir}/.debug/libarmnnOnnxParser.so"
FILES_${PN}-onnx-dev = " \
	${includedir}/armnnOnnxParser \
	${includedir}/armnnOnnxParser/IOnnxParser.hpp \
"
FILES_${PN}-onnx-examples = "${bindir}/${PN}-${PV}/examples/onnx"
FILES_${PN}-onnx-examples-dbg = "${bindir}/${PN}-${PV}/examples/onnx/.debug"

# ArmNN files
FILES_${PN}-dev += "${libdir}/cmake/*"


INSANE_SKIP_${PN} = "dev-deps dev-so"
INSANE_SKIP_${PN}-dev = "dev-elf"
INSANE_SKIP_${PN}-examples = "dev-so libdir"
INSANE_SKIP_${PN}-examples-dbg = "libdir"
INSANE_SKIP_${PN}-onnx = "dev-so"
INSANE_SKIP_${PN}-tensorflow-lite = "dev-so"
