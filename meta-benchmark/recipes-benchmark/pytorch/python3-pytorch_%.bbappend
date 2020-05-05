FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# imagenet_classes.txt contains 1000 of ImageNet's classes, image-net.org
# grace_hopper.jpg is from the US NHHC, www.history.navy.mil
# pytorch models are from pytorch.org

SRC_URI += " \
	file://python-scripts \
	file://pytorch-benchmark.sh \
	file://imagenet_classes.txt \
	file://grace_hopper.jpg \
	https://download.pytorch.org/models/alexnet-owt-4df8aa71.pth;name=alexnet-owt-4df8aa71 \
	https://download.pytorch.org/models/inception_v3_google-1a9a5a14.pth;name=inception_v3_google-1a9a5a14 \
	https://download.pytorch.org/models/mnasnet1.0_top1_73.512-f206786ef8.pth;name=mnasnet1.0_top1_73.512-f206786ef8 \
	https://download.pytorch.org/models/mobilenet_v2-b0353104.pth;name=mobilenet_v2-b0353104 \
	https://download.pytorch.org/models/resnet152-b121ed2d.pth;name=resnet152-b121ed2d \
"

SRC_URI[alexnet-owt-4df8aa71.md5sum] = "aed0662f397a0507305ac94ea5519309"
SRC_URI[alexnet-owt-4df8aa71.sha256sum] = "4df8aa717fd11ab2d34e9483c5984ef7cdbefd732366a836076020db08909c9a"
SRC_URI[inception_v3_google-1a9a5a14.md5sum] = "961cad7697695cca7d9ca4814b17a88d"
SRC_URI[inception_v3_google-1a9a5a14.sha256sum] = "1a9a5a14f40645a370184bd54f4e8e631351e71399112b43ad0294a79da290c8"
SRC_URI[mnasnet1.0_top1_73.512-f206786ef8.md5sum] = "02d9eb9b304e14cfe0e7ea057be465f0"
SRC_URI[mnasnet1.0_top1_73.512-f206786ef8.sha256sum] = "f206786ef8a6d33af1091698bd667528dd506020f45e65bc4d4f00ce4e9990f0"
SRC_URI[mobilenet_v2-b0353104.md5sum] = "f20b50b44fdef367a225d41f747a0963"
SRC_URI[mobilenet_v2-b0353104.sha256sum] = "b03531047ffacf1e2488318dcd2aba1126cde36e3bfe1aa5cb07700aeeee9889"
SRC_URI[resnet152-b121ed2d.md5sum] = "d3ddb494358a7e95e49187829ec97395"
SRC_URI[resnet152-b121ed2d.sha256sum] = "b121ed2db97ec7e9f55a91300ceaf85a326de955e8a4ae09e3a0c8170d27f14f"

RDEPENDS_${PN} += " \
	python3-torchvision \
"

do_install_append() {
	install -d ${D}${bindir}/pytorch-benchmark
	install -m 0555 ${WORKDIR}/python-scripts/* ${D}${bindir}/pytorch-benchmark
	install -m 0555 ${WORKDIR}/pytorch-benchmark.sh ${D}${bindir}/pytorch-benchmark
	install -m 0644 ${WORKDIR}/*.pth ${D}${bindir}/pytorch-benchmark
	install -m 0644 ${WORKDIR}/grace_hopper.jpg ${D}${bindir}/pytorch-benchmark
	install -m 0644 ${WORKDIR}/imagenet_classes.txt ${D}${bindir}/pytorch-benchmark
}

FILES_${PN} += "\
	${bindir}/pytorch-benchmark/* \
"

