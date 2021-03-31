FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "libeigen"
RDEPENDS_${PN} += "models-tensorflow"

#tensorflowBenchmark.cc is originally from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/label_image/main.cc
#at branch r1.10, commit sha 656e7a2b347c3c6eb76a6c130ed4b1def567b6c1

SRC_URI += " \
	file://tensorflowBenchmark.cc \
"

do_compile_append() {

	if [ "${MACHINE}" = "iwg20m-g1m" ] ; then
		OPT_DIR="armeabi-v7a-a15"
	fi
	if [ "${MACHINE}" = "iwg22m" ] ; then
		OPT_DIR="armeabi-v7a-a7"
	fi
	if [ "${MACHINE}" = "iwg21m" ] ; then
		OPT_DIR="armeabi-v7a-a7-a15"
	fi
	if [ "${MACHINE}" = "hihope-rzg2h" ] || [ "${MACHINE}" = "hihope-rzg2m" ] ; then
		OPT_DIR="arm64-v8a-a57-a53"
	fi
	if [ "${MACHINE}" = "hihope-rzg2n" ] ; then
		OPT_DIR="arm64-v8a-a57"
	fi
	if [ "${MACHINE}" = "ek874" ] ; then
		OPT_DIR="arm64-v8a-a53"
	fi

	${CXX} -std=c++11 ../tensorflowBenchmark.cc -o tensorflowBenchmark \
		-I . -I ./bazel-genfiles -I ${STAGING_DIR_TARGET}/usr/include/eigen3 \
		-I ${STAGING_DIR_TARGET}/usr/include -L ${WORKDIR}/git/bazel-bin/tensorflow/ \
		-I ${WORKDIR}/output_base/external/com_google_absl/ \
		-I ${WORKDIR}/output_base/external/com_google_protobuf/src/ \
		-I ${WORKDIR}/output_base/execroot/org_tensorflow/bazel-out/${OPT_DIR}-opt/bin/ \
		-ltensorflow_cc -lstdc++ -lm ${LDFLAGS}
}

do_install_append() {
	install -d ${D}${bindir}/tensorflowBenchmark
	install -m 0555 ${S}/tensorflowBenchmark ${D}${bindir}/tensorflowBenchmark/
}

FILES_${PN} += "\
	${bindir}/tensorflowBenchmark/tensorflowBenchmark \
"
