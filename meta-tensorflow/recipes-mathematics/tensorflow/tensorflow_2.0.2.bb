DESCRIPTION = "TensorFlow C/C++ Libraries"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=64a34301f8e355f57ec992c2af3e5157"

DEPENDS = "bazel-native util-linux-native python-futures-native"
RDEPENDS_${PN}-dev += "libeigen-dev"
PACKAGES += "${PN}-examples ${PN}-examples-dbg"

S = "${WORKDIR}/git"

SRCREV = "2c2fdd3205a8d31e5f09a71ac7eb52b8c0294a60"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=r2.0 \
	file://0001-Add-Tensorflow-2.0-cross-compile-support.patch \
	file://0001-Support-both-python2-and-python3.patch \
	file://0001-Use-hard-float-point-flag-instead-of-soft-float-poin.patch \
	file://Fix-alignment-issue-in-arm-neon-platform.patch;apply=no \
	file://Patching-nsync-library-on-the-fly-via-bazel.patch \
	file://Remove-python-support-from-label_image-example-applicati.patch \
"

SRC_URI_append_iwg20m-g1m = " \
	file://TensorFlow-crosscompile-arm-a15.patch \
"

SRC_URI_append_iwg21m = " \
	file://TensorFlow-crosscompile-arm-a15.patch \
"

SRC_URI_append_iwg22m = " \
        file://TensorFlow-crosscompile-arm-a7.patch \
"

SRC_URI_append_hihope-rzg2h = " \
        file://TensorFlow-crosscompile-aarch64-a57a53.patch \
"

SRC_URI_append_hihope-rzg2m = " \
        file://TensorFlow-crosscompile-aarch64-a57a53.patch \
"

SRC_URI_append_hihope-rzg2n = " \
        file://TensorFlow-crosscompile-aarch64-a57.patch \
"

SRC_URI_append_ek874 = " \
        file://TensorFlow-crosscompile-aarch64-a53.patch \
"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

export BAZEL_FLAGS="--output_base ${WORKDIR}/output_base"

do_configure () {
	CT_DIR="${STAGING_DIR_NATIVE}"
	CT_NAME=$(echo ${HOST_PREFIX} | rev | cut -c 2- | rev)
	GCC_VERSION=$(${CC} -dumpversion)

	SED_COMMAND="s#%%CT_NAME%%#${CT_NAME}#g"
	SED_COMMAND="${SED_COMMAND}; s#%%CT_ROOT_DIR%%#${CT_DIR}#g"
	SED_COMMAND="${SED_COMMAND}; s#%%CT_GCC_VERSION%%#${GCC_VERSION}#g"
	SED_COMMAND="${SED_COMMAND}; s#%%CT_STAGING_DIR%%#${STAGING_DIR_HOST}#g"

        SED_COMMAND="${SED_COMMAND}; s#%%WORKDIR%%#${WORKDIR}#g"

        sed -i "${SED_COMMAND}" ${S}/BUILD.yocto_compiler \
                                ${S}/third_party/toolchains/yocto/CROSSTOOL.tpl \
                                ${S}/WORKSPACE

	cd ${S}

	unset $(printenv | cut -d "=" -f1 | grep -v '^PATH$')

	mkdir -p ${WORKDIR}/output_base

	# Let zip adjust the entry offsets stored in the
	# archive to take into account the "preamble" data in
	# self-extracting executable archive (bazel)
	zip -A ${STAGING_BINDIR_NATIVE}/bazel

	export JAVA_HOME=${STAGING_BINDIR_NATIVE}/openjdk-1.8-native
	(TF_NEED_JEMALLOC=0 \
	 TF_NEED_GCP=0 \
 	 TF_NEED_CUDA=0 \
 	 TF_NEED_S3=0 \
 	 TF_NEED_HDFS=0 \
 	 TF_NEED_KAFKA=0 \
 	 TF_NEED_OPENCL_SYCL=0 \
 	 TF_NEED_OPENCL=0 \
  	 TF_CUDA_CLANG=0 \
 	 TF_DOWNLOAD_CLANG=0 \
  	 TF_ENABLE_XLA=0 \
 	 TF_NEED_GDR=0 \
 	 TF_NEED_VERBS=0 \
 	 TF_NEED_MPI=0 \
 	 TF_SET_ANDROID_WORKSPACE=0 \
	./configure)

	cp ${WORKDIR}/Fix-alignment-issue-in-arm-neon-platform.patch ${S}/third_party/
}

do_compile_prepend_arm () {
	TF_ARCH="--cpu=armeabi-v7a"
}

do_compile_prepend_aarch64 () {
	TF_ARCH="--cpu=arm64-v8a"
}

do_compile () {
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}
	export http_proxy=${HTTP_PROXY}
	export https_proxy=${HTTPS_PROXY}

	unset $(printenv | cut -d "=" -f1 | grep -Ev '^PATH$|^BAZEL_FLAGS$|^HTTP_PROXY$|^HTTPS_PROXY$')

	export JAVA_HOME=${STAGING_BINDIR_NATIVE}/openjdk-1.8-native

	bazel $BAZEL_FLAGS build \
		--config=monolithic \
		--config=noaws \
		--define=build_with_mkl=false \
		--define=enable_mkl=false \
		--define=build_with_mkl_dnn_only=false \
		--define=build_with_mkl_dnn_v1_only=false \
		--define=tensorflow_mkldnn_contraction_kernel=0 \
		--define=using_clang=false \
		-c opt \
		--copt=-DARM_NON_MOBILE \
		${TF_ARCH} \
		--crosstool_top=@local_config_yocto_compiler//:toolchain \
		--verbose_failures \
		//tensorflow:libtensorflow.so \
		//tensorflow:libtensorflow_framework.so

	bazel $BAZEL_FLAGS build \
		--config=monolithic \
		--config=noaws \
		--define=build_with_mkl=false \
		--define=enable_mkl=false \
		--define=build_with_mkl_dnn_only=false \
		--define=build_with_mkl_dnn_v1_only=false \
		--define=tensorflow_mkldnn_contraction_kernel=0 \
		--define=using_clang=false \
		-c opt \
		--copt=-DARM_NON_MOBILE \
		${TF_ARCH} \
		--crosstool_top=@local_config_yocto_compiler//:toolchain \
		--verbose_failures \
		//tensorflow:libtensorflow_cc.so

	bazel $BAZEL_FLAGS build \
		--config=monolithic \
		--config=noaws \
		--define=build_with_mkl=false \
		--define=enable_mkl=false \
		--define=build_with_mkl_dnn_only=false \
		--define=build_with_mkl_dnn_v1_only=false \
		--define=tensorflow_mkldnn_contraction_kernel=0 \
		--define=using_clang=false \
		-c opt \
		--copt=-DARM_NON_MOBILE \
		${TF_ARCH} \
		--crosstool_top=@local_config_yocto_compiler//:toolchain \
		--verbose_failures \
		tensorflow/examples/label_image/...
}

do_install () {
	install -d ${D}${libdir}
	oe_soinstall \
		${S}/bazel-bin/tensorflow/libtensorflow.so.${PV} \
		${D}${libdir}
	oe_soinstall \
		${S}/bazel-bin/tensorflow/libtensorflow_cc.so.${PV} \
		${D}${libdir}
	oe_soinstall \
		${S}/bazel-bin/tensorflow/libtensorflow_framework.so.${PV} \
		${D}${libdir}

	install -d ${D}${includedir}/tensorflow
	cd ${S}/bazel-genfiles/tensorflow
	cp --parents \
		$(find . -name "*.h*") \
		${D}${includedir}/tensorflow
	rm -rf \
		${D}${includedir}/tensorflow/core/example

	install -d ${D}/usr/src/debug/tensorflow
	cp --parents \
		$(find . -type f \( -iname \*.c* -o -iname \*.h* \) ) \
		${D}/usr/src/debug/tensorflow

	install -d ${D}${bindir}/${PN}-${PV}/examples

	install -m 0555 \
		${S}/bazel-bin/tensorflow/examples/label_image/label_image \
		${D}${bindir}/${PN}-${PV}/examples

	install -m 0644 \
		${S}/tensorflow/examples/label_image/data/grace_hopper.jpg \
		${D}${bindir}/${PN}-${PV}/examples
	cd ${D}${bindir}
	ln -sf ${PN}-${PV} ${PN}
}

INSANE_SKIP_${PN} += " \
	already-stripped \
"

FILES_${PN} = " \
	${libdir}/lib*${SOLIBS} \
"

FILES_${PN}-dev = " \
	${includedir} \
	${libdir}/lib*${SOLIBSDEV} \
"

FILES_${PN}-dbg = " \
	${libdir}/.debug \
	/usr/src/debug/tensorflow \
"

FILES_${PN}-examples = " \
	${bindir}/${PN} \
	${bindir}/${PN}-${PV}/examples/label_image \
	${bindir}/${PN}-${PV}/examples/grace_hopper.jpg \
"

FILES_${PN}-examples-dbg = " \
	${bindir}/${PN}-${PV}/examples/.debug \
"
