DESCRIPTION = "TensorFlow C/C++ Libraries"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e74df23890b9521cc481e3348863e45d"

DEPENDS = "bazel-native"
RDEPENDS_${PN}-dev += "libeigen-dev protobuf-dev"
PACKAGES += "${PN}-examples ${PN}-examples-dbg"

S = "${WORKDIR}/git"

SRCREV = "12f033df4c8fa3feb88ce936eb1581eaa92b303e"

SRC_URI = " \
	git://github.com/tensorflow/tensorflow.git;branch=master \
	file://TensorFlow-common-platform.patch \
	file://TensorFlow-crosscompile-arm.patch \
	file://TensorFlow-neon-eigen.patch \
	file://TensorFlow-neon-alignment.patch \
"

COMPATIBLE_MACHINE = "(iwg20m|iwg21m|iwg22m)"

export BAZEL_FLAGS="--output_base ${WORKDIR}/output_base"

do_configure () {
	CT_DIR="${STAGING_DIR_NATIVE}"
	CT_NAME=$(echo ${HOST_PREFIX} | rev | cut -c 2- | rev)
	GCC_VERSION=$(${CC} -dumpversion)

	SED_COMMAND="s#%%CT_NAME%%#${CT_NAME}#g"
	SED_COMMAND="${SED_COMMAND}; s#%%CT_ROOT_DIR%%#${CT_DIR}#g"
	SED_COMMAND="${SED_COMMAND}; s#%%CT_GCC_VERSION%%#${GCC_VERSION}#g"
	SED_COMMAND="${SED_COMMAND}; s#%%CT_STAGING_DIR%%#${STAGING_DIR_HOST}#g"

	cd ${S}
	find . -type f -exec sed -i "${SED_COMMAND}" '{}' \;

	unset $(printenv | cut -d "=" -f1 | grep -v '^PATH$')

	mkdir -p ${WORKDIR}/output_base

	export JAVA_HOME=${STAGING_BINDIR_NATIVE}/openjdk-1.8-native
	yes ''| ./configure
}

do_compile () {
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}

	unset $(printenv | cut -d "=" -f1 | grep -Ev '^PATH$|^BAZEL_FLAGS$|^HTTP_PROXY$|^HTTPS_PROXY$')

	export JAVA_HOME=${STAGING_BINDIR_NATIVE}/openjdk-1.8-native

	bazel $BAZEL_FLAGS build \
		-c opt \
		tensorflow:libtensorflow.so \
		--cpu=armeabi-v7a \
		--crosstool_top=//tools/arm_compiler:toolchain \
		--verbose_failures

	bazel $BAZEL_FLAGS build \
		-c opt \
		tensorflow:libtensorflow_cc.so \
		--cpu=armeabi-v7a \
		--crosstool_top=//tools/arm_compiler:toolchain \
		--verbose_failures

        bazel $BAZEL_FLAGS build \
		tensorflow/examples/label_image/... \
		-c opt \
		--cpu=armeabi-v7a \
		--crosstool_top=//tools/arm_compiler:toolchain \
		--verbose_failures
}

do_install () {
	install -d ${D}${libdir}
	install -m 0555 \
		${S}/bazel-out/${HOST_PREFIX}opt/bin/tensorflow/libtensorflow*.so \
		${D}${libdir}

	install -d ${D}${includedir}/tensorflow
	cd ${S}/bazel-out/${HOST_PREFIX}opt/genfiles/tensorflow
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
		${S}/bazel-out/${HOST_PREFIX}opt/bin/tensorflow/examples/label_image/label_image \
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
	${libdir} \
"

FILES_${PN}-dev = " \
	${includedir} \
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
