FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "libeigen"

#tensorflowBenchmark.cc is originally from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/label_image/main.cc
#at branch r1.10, commit sha 656e7a2b347c3c6eb76a6c130ed4b1def567b6c1

SRC_URI += " \
	file://tensorflowBenchmark.cc \
"

do_compile_append() {
	${CXX} -std=c++11 ../tensorflowBenchmark.cc -o tensorflowBenchmark \
		-I . -I ./bazel-genfiles -I ${STAGING_DIR_TARGET}/usr/include/eigen3 \
		-I ${STAGING_DIR_TARGET}/usr/include -L ./bazel-bin/tensorflow/ \
		-I ${WORKDIR}/output_base/external/com_google_absl/ \
		-I ${WORKDIR}/output_base/external/com_google_protobuf/src/ \
		-ltensorflow_cc -lstdc++ -lm ${LDFLAGS}
}

do_install_append() {
	install -d ${D}${bindir}/tensorflowBenchmark
	install -m 0555 ${S}/tensorflowBenchmark ${D}${bindir}/tensorflowBenchmark/ 
}

FILES_${PN} += "\
	${bindir}/tensorflowBenchmark/tensorflowBenchmark \
"
