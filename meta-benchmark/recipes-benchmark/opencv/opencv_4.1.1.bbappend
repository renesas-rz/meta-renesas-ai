FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

SRC_URI += " \
	file://classification.cpp \
	file://opencv-benchmark.sh \
	file://grace_hopper.jpg \
"

SRC_URI[md5sum] = "314296a0a5dd3c394e57f4efac733c20"
SRC_URI[sha256sum] = "a8ca6d734765703b09728ab47fe59f473d93ae3967fc24c7c0288c3c7adb7130"

do_compile_append() {
	cp ../classification.cpp .
        ${CXX} classification.cpp -o opencv-dnn-benchmark \
		-I ${S}/modules/dnn/include -I ${S}/modules/imgproc/include \
		-I ${S}/modules/highgui/include/ -I ${S}/modules/core/include \
		-I ${S}/modules/imgcodecs/include -I ${S}/modules/videoio/include \
		-I .. -I ${S}/../build/ \
		-lpthread -lstdc++ -lm -ldl -lopencv_core \
		-lopencv_imgproc -lopencv_dnn -lopencv_imgcodecs \
		-lopencv_videoio -lopencv_highgui ${LDFLAGS} \
		-L ${S}/../build/lib/
}

do_install_append() {
	install -d ${D}${bindir}/opencvBenchmark
	install -m 0555 ${S}/../build/opencv-dnn-benchmark ${D}${bindir}/opencvBenchmark/
	install -m 0644 ${S}/../grace_hopper.jpg ${D}${bindir}/opencvBenchmark/
	install -m 0555 ${S}/../opencv-benchmark.sh ${D}${bindir}/opencvBenchmark/
}

FILES_${PN} += "\
	${bindir}/opencvBenchmark/* \
"
