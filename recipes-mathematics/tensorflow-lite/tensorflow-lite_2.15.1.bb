DESCRIPTION = "TensorFlow Lite C++ Library and Python module"
LICENSE = "Apache-2.0 & MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=4158a261ca7f2525513e31ba9c50ae98"

# tag v2.15.1
SRCREV = "63f5a65c7cd7b6241bede8d2e0082058566ea364"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=r2.15;protocol=https \
	file://label_image.py \
	file://0001-tensorflow-lite-Do-not-build-XNNPack-into-library-ou.patch \
	file://0001-build_pip_package_with_cmake-Make-compatible-with-yo.patch \
"

S = "${WORKDIR}/git"

inherit cmake python3native python3-dir

COMPATIBLE_MACHINE = "^(aarch64)$"

# TensorFlow Lite CMake based build system does not generate a .so file,
# this statement makes sure package -staticdev goes where package -dev goes,
# as package -staticdev contains the .a file.
RDEPENDS_${PN}-dev += "${PN}-staticdev"

DEPENDS = " \
	cmake-native \
	unzip-native \
"

# DEPENDS also includes the runtime dependencies in the image here.
DEPENDS_aarch64 = " \
	python3-numpy-native \
	python3-pillow \
	python3-pybind11-native \
	python3-wheel-native \
"

PACKAGES += "${PN}-python"

do_configure[noexec] = "1"

EXTRA_OECMAKE_aarch64 = " \
	-DTFLITE_ENABLE_RUY=ON \
	-DTFLITE_ENABLE_XNNPACK=ON \
	-DCMAKE_SYSTEM_NAME=Linux \
	-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
	-DCMAKE_SYSROOT=${STAGING_DIR_TARGET} \
	-DCMAKE_C_COMPILER=${STAGING_DIR_NATIVE}/usr/bin/aarch64-poky-linux/aarch64-poky-linux-gcc \
	-DCMAKE_CXX_COMPILER=${STAGING_DIR_NATIVE}/usr/bin/aarch64-poky-linux/aarch64-poky-linux-g++ \
	-DCMAKE_CXX_FLAGS="-flax-vector-conversions" \
	-DCMAKE_C_FLAGS="-flax-vector-conversions" \
	-DABSL_PROPAGATE_CXX_STD=1 \
	-DXNNPACK_ENABLE_ARM_I8MM=OFF \
"

do_compile() {
	# Tensorflow-lite does not compile unless built out of tree
	mkdir -p ${WORKDIR}/build
	cd ${WORKDIR}/build

	# Build system does not contain a fortran compiler
	unset FC

	# Run CMake with the configuration for the minimal example
	# which includes the Tensorflow-lite library configuration
	# before running the needed build steps.
	cmake ${S}/tensorflow/lite/examples/minimal ${EXTRA_OECMAKE}
	cmake --build . -j ${PARALLEL_MAKE}
	cmake --build . -t label_image -j ${PARALLEL_MAKE}
	cmake --build . -t benchmark_model -j ${PARALLEL_MAKE}
}

do_compile_append_aarch64() {
	# Compile and add python support
	cd ${S}
	PYTHON_INCLUDES=" \
		-I${STAGING_DIR_NATIVE}/usr/include/${PYTHON_DIR}/ \
		-I${STAGING_DIR_TARGET}/usr/lib64/${PYTHON_DIR}/site-packages/numpy/core/include/ \
		-I${STAGING_LIBDIR_TARGET}/${PYTHON_DIR}/site-packages/pybind11/include/ \
		-I${STAGING_DIR_NATIVE}/usr/include/tirpc/ \
	"

	PYTHON=python3 ARMCC_FLAGS="${PYTHON_INCLUDES}" \
	ARMCC_PREFIX="${TARGET_ARCH}-poky-linux-" POKY_SYSROOT="${STAGING_DIR_TARGET}" \
	tensorflow/lite/tools/pip_package/build_pip_package_with_cmake.sh ${TARGET_ARCH}

	mkdir -p ${WORKDIR}/build/python/
	cp tensorflow/lite/tools/pip_package/gen/tflite_pip/python3/tflite_runtime/* \
		${WORKDIR}/build/python
}

do_install_append() {
	install -d ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/tensorflow-lite/libtensorflow-lite.a ${D}${libdir}

	# Install TensorFlow Lite dependencies and associated header files required for building,
	# and compiling other AI frameworks and applications
	install -d ${D}${includedir}/flatbuffers
	install -m 0644 ${WORKDIR}/build/flatbuffers/include/flatbuffers/*.h ${D}${includedir}/flatbuffers
	install -d ${D}${includedir}/flatbuffers/pch
	install -m 0644 ${WORKDIR}/build/flatbuffers/include/flatbuffers/pch/*.h ${D}${includedir}/flatbuffers/pch
	install -m 0644 ${WORKDIR}/build/_deps/flatbuffers-build/libflatbuffers.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/ruy-build/ruy/libruy*.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/xnnpack-build/libXNNPACK.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/fft2d-build/libfft2d_fftsg2d.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/fft2d-build/libfft2d_fftsg.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/farmhash-build/libfarmhash.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/abseil-cpp-build/absl/strings/libabsl_strings.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/pthreadpool/libpthreadpool.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/cpuinfo-build/libcpuinfo.a ${D}${libdir}

	cd ${S}
	find tensorflow/lite -name "*.h" | cpio -pdm ${D}${includedir}/
	find tensorflow/core -name "*.h" | cpio -pdm ${D}${includedir}/
	find tensorflow/lite -name "*.inc" | cpio -pdm ${D}${includedir}/
	find tensorflow/lite -name "*.fbs" | cpio -pdm ${D}${includedir}/
	install -m 0555 ${S}/tensorflow/lite/examples/label_image/bitmap_helpers.cc ${D}${includedir}

	install -d ${D}${includedir}/tsl/platform
	install -m 0644 ${S}/third_party/xla/third_party/tsl/tsl/platform/*.h ${D}${includedir}/tsl/platform

	install -d ${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 ${WORKDIR}/build/tensorflow-lite/examples/label_image/label_image \
		${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
		${S}/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp \
		${D}${bindir}/${PN}-${PV}/examples
	install -m 0555 \
                ${WORKDIR}/build/minimal \
                ${D}${bindir}/${PN}-${PV}/examples
        install -m 0555 \
		${WORKDIR}/build/tensorflow-lite/tools/benchmark/benchmark_model \
		${D}${bindir}/${PN}-${PV}/examples

	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

do_install_append_aarch64() {
	install -m 0555 \
		${WORKDIR}/label_image.py \
		${D}${bindir}/${PN}-${PV}/examples

	install -d ${D}${libdir}/${PYTHON_DIR}/site-packages/tflite_runtime/
	install -m 0555 \
		${WORKDIR}/build/python/* \
		${D}${libdir}/${PYTHON_DIR}/site-packages/tflite_runtime/
}

FILES_${PN} += " \
	${bindir}/${PN}-${PV}/examples/label_image \
	${bindir}/${PN}-${PV}/examples/grace_hopper.bmp \
	${bindir}/${PN}-${PV}/examples/minimal \
	${bindir}/${PN}-${PV}/examples/benchmark_model \
"

FILES_${PN}-python += " \
	${bindir}/${PN}-${PV}/examples/label_image.py \
	${libdir}/${PYTHON_DIR}/site-packages/tflite_runtime/* \
"
