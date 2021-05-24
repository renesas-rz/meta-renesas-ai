DESCRIPTION = "Models for Caffe2 benchmarking"
LICENSE = "Apache-2.0"
LICENSE_FLAGS = "commercial"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=a9b73dae4a0b3a752f7eccb813bc2820 \
"

S = "${WORKDIR}"

SRC_URI = " \
        file://license/LICENSES \
        file://license/COPYING \
	https://s3.amazonaws.com/download.caffe2.ai/models/squeezenet/predict_net.pb;name=squeezenet_predict_net_caffe2;subdir=caffe2 \
	https://s3.amazonaws.com/download.caffe2.ai/models/squeezenet/init_net.pb;name=squeezenet_init_net_caffe2;subdir=caffe2 \
	https://github.com/BVLC/caffe/raw/master/python/caffe/imagenet/ilsvrc_2012_mean.npy;name=squeezenet_mean_caffe2;subdir=caffe2 \
"

SRC_URI[squeezenet_predict_net_caffe2.md5sum] = "694bfdd02e9ccb57bfc4acb451fbfb2d"
SRC_URI[squeezenet_predict_net_caffe2.sha256sum] = "d20be00eb448d3952265620357132916aba8744b027937b56c469b001b46472b"
SRC_URI[squeezenet_init_net_caffe2.md5sum] = "a589d31d93c44d353ae2cd92af4d5a3f"
SRC_URI[squeezenet_init_net_caffe2.sha256sum] = "d8115221de899d081a1a83785bf0dbaeea19463cdf7dbddba662cc7abb4f32dc"
SRC_URI[squeezenet_mean_caffe2.md5sum] = "28a998b87558ea0cac23c83e718636b1"
SRC_URI[squeezenet_mean_caffe2.sha256sum] = "97eefba7e046ee097121ad18564329636d2f9c153b748c7313653cae8594a149"

do_install () {
	install -d ${D}/home/root/models/caffe2
	cp -r ${S}/caffe2/* ${D}/home/root/models/caffe2/
}

FILES_${PN} = " \
        /home/root/models/caffe2 \
"
