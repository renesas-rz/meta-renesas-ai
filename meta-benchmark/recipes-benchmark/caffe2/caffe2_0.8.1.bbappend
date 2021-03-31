FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "models-caffe2"

SRC_URI += " \
	file://alexnet_codes \
	file://caffe2_Benchmark.sh \
	file://caffe2_Benchmark.py \
	file://grace_hopper.jpg \
	file://models \
"

do_install_append() {
	install -d ${D}${bindir}/caffe2Benchmark
	install -m 0644 ${S}/../alexnet_codes ${D}${bindir}/caffe2Benchmark/
	install -m 0555 ${S}/../caffe2_Benchmark.sh ${D}${bindir}/caffe2Benchmark/
	install -m 0555 ${S}/../caffe2_Benchmark.py ${D}${bindir}/caffe2Benchmark/
	install -m 0644 ${S}/../grace_hopper.jpg ${D}${bindir}/caffe2Benchmark/
	cp -r ${S}/../models ${D}${bindir}/caffe2Benchmark/
}

FILES_${PN} += "\
	${bindir}/caffe2Benchmark/* \
"
