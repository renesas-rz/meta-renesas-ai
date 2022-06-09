DESCRIPTION = "TensorFlow Lite C++ Library"
LICENSE = "Apache-2.0 & MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=5131e32d71a4eb06326ea1772d0de6fd"

# tag v2.5.3
SRCREV = "959e9b2a0c06df945f9fb66bd367af8832ca0d28"
TFL_VER = "2.5.3"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=r2.5 \
	file://0001-Remove-GPU-and-NNAPI.patch \
	file://0001-Use-wget-instead-of-curl-to-fetch-https-source.patch \
	file://0001-tensorflow-lite-Do-not-build-XNNPack-into-library-ou.patch \
"

S = "${WORKDIR}/git"

inherit cmake

# TensorFlow Lite CMake based build system does not generate a .so file,
# this statement makes sure package -staticdev goes where package -dev goes,
# as package -staticdev contains the .a file.
RDEPENDS_${PN}-dev += "${PN}-staticdev"

DEPENDS = "unzip-native cmake-native"

do_configure() {
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}
	export http_proxy=${HTTP_PROXY}
	export https_proxy=${HTTPS_PROXY}

	${S}/tensorflow/lite/tools/make/download_dependencies.sh
}

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
"

do_compile() {
	# Tensorflow-lite does not compile unless built out of tree
	mkdir -p ${WORKDIR}/build
	cd ${WORKDIR}/build

	# Run CMake with the configuration for the minimal example
	# which includes the Tensorflow-lite library configuration
	# before running the needed build steps.
	cmake ${S}/tensorflow/lite/examples/minimal ${EXTRA_OECMAKE}
	cmake --build . -j
	cmake --build . -t label_image -j
	cmake --build . -t benchmark_model -j
}

do_install_append() {
	install -d ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/tensorflow-lite/libtensorflow-lite.a ${D}${libdir}

	install -d ${D}${includedir}/flatbuffers
	install -m 0644 ${WORKDIR}/build/flatbuffers/include/flatbuffers/* ${D}${includedir}/flatbuffers
	install -m 0644 ${WORKDIR}/build/_deps/flatbuffers-build/libflatbuffers.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/ruy-build/libruy.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/xnnpack-build/libXNNPACK.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/fft2d-build/libfft2d_fftsg2d.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/fft2d-build/libfft2d_fftsg.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/farmhash-build/libfarmhash.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/_deps/abseil-cpp-build/absl/strings/libabsl_strings.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/pthreadpool/libpthreadpool.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/cpuinfo/libcpuinfo.a ${D}${libdir}
	install -m 0644 ${WORKDIR}/build/clog/libclog.a ${D}${libdir}

	cd ${S}
	find tensorflow/lite -name "*.h" | cpio -pdm ${D}${includedir}/
	find tensorflow/core -name "*.h" | cpio -pdm ${D}${includedir}/
	find tensorflow/lite -name "*.inc" | cpio -pdm ${D}${includedir}/
	find tensorflow/lite -name "*.fbs" | cpio -pdm ${D}${includedir}/
	install -m 0555 ${S}/tensorflow/lite/examples/label_image/bitmap_helpers.cc ${D}${includedir}

	install -d ${D}${bindir}/${PN}-${TFL_VER}/examples
	install -m 0555 ${WORKDIR}/build/tensorflow-lite/examples/label_image/label_image \
		${D}${bindir}/${PN}-${TFL_VER}/examples
	install -m 0555 \
		${S}/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp \
		${D}${bindir}/${PN}-${TFL_VER}/examples
	install -m 0555 \
                ${WORKDIR}/build/minimal \
                ${D}${bindir}/${PN}-${TFL_VER}/examples
        install -m 0555 \
		${WORKDIR}/build/tensorflow-lite/tools/benchmark/benchmark_model \
		${D}${bindir}/${PN}-${TFL_VER}/examples

	cd ${D}${bindir}
	ln -sf ${PN}-${TFL_VER} ${PN}
}

FILES_${PN} += " \
	${bindir}/${PN}-${TFL_VER}/examples/label_image \
	${bindir}/${PN}-${TFL_VER}/examples/grace_hopper.bmp \
	${bindir}/${PN}-${TFL_VER}/examples/minimal \
	${bindir}/${PN}-${TFL_VER}/examples/benchmark_model \
"

FILES_${PN} += "${bindir}/${PN}-${TFL_VER}/examples/*"
