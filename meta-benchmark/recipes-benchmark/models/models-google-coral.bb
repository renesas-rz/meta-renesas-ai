DESCRIPTION = "Models for Google Coral benchmarking"
LICENSE = "Apache-2.0"
LICENSE_FLAGS = "commercial"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=0f9c4279e815df1af25972361d78cb4a \
"

S = "${WORKDIR}"

SRC_URI = " \
        file://models/google-coral \
        file://license/LICENSES \
        file://license/COPYING \
	https://github.com/google-coral/test_data/raw/master/efficientnet-edgetpu-S_quant_edgetpu.tflite;name=efficientnet-edgetpu-S_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/efficientnet-edgetpu-M_quant_edgetpu.tflite;name=efficientnet-edgetpu-M_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/efficientnet-edgetpu-L_quant_edgetpu.tflite;name=efficientnet-edgetpu-L_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/mobilenet_v1_1.0_224_quant_edgetpu.tflite;name=mobilenet_v1_1.0_224_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/mobilenet_v2_1.0_224_quant_edgetpu.tflite;name=mobilenet_v2_1.0_224_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/mobilenet_v2_1.0_224_inat_insect_quant_edgetpu.tflite;name=mobilenet_v2_1.0_224_inat_insect_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inat_insect_labels.txt;name=inat_insect_labels;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/mobilenet_v2_1.0_224_inat_plant_quant_edgetpu.tflite;name=mobilenet_v2_1.0_224_inat_plant_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inat_plant_labels.txt;name=inat_plant_labels;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.tflite;name=mobilenet_v2_1.0_224_inat_bird_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inat_bird_labels.txt;name=inat_bird_labels;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inception_v1_224_quant_edgetpu.tflite;name=inception_v1_224_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inception_v2_224_quant_edgetpu.tflite;name=inception_v2_224_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inception_v3_299_quant_edgetpu.tflite;name=inception_v3_299_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/inception_v4_299_quant_edgetpu.tflite;name=inception_v4_299_quant_edgetpu;subdir=tpu \
	https://github.com/google-coral/test_data/raw/master/imagenet_labels.txt;name=imagenet_labels;subdir=tpu \
"

SRC_URI[efficientnet-edgetpu-S_quant_edgetpu.md5sum] = "c7d6ce02623c51d83c4f2053493fa950"
SRC_URI[efficientnet-edgetpu-S_quant_edgetpu.sha256sum] = "a7fe60d5e50c4baac6df1d7c042e81f5af0d9a4462ec6b62402858178f1236a0"
SRC_URI[efficientnet-edgetpu-M_quant_edgetpu.md5sum] = "59a18c6a982ada33832ca7334ed76a1f"
SRC_URI[efficientnet-edgetpu-M_quant_edgetpu.sha256sum] = "fa624d4bd90f1a9c4b205fa876876c9c51f217ac3cd6f6b67e05b71cebe38ce5"
SRC_URI[efficientnet-edgetpu-L_quant_edgetpu.md5sum] = "dadc7531f3a3902e31b4fca2b2b78b6b"
SRC_URI[efficientnet-edgetpu-L_quant_edgetpu.sha256sum] = "834eafb26b31dfe1c2b9ddf4f5bc3096491c32861ffbd787959e4c603dac3f2a"
SRC_URI[mobilenet_v1_1.0_224_quant_edgetpu.md5sum] = "69290271b2c3ec8be9006836a66d2248"
SRC_URI[mobilenet_v1_1.0_224_quant_edgetpu.sha256sum] = "15eba6787496c09d181791303572e051cc2e60547cad2a9e22c40409453ee0b0"
SRC_URI[mobilenet_v2_1.0_224_quant_edgetpu.md5sum] = "15d70bb6904ecc9c509faeb2ec867f9f"
SRC_URI[mobilenet_v2_1.0_224_quant_edgetpu.sha256sum] = "245767c007ee553bb2d3e4f23330dc05d284f0ea4b515caf9e9ba4a326dfb69c"
SRC_URI[mobilenet_v2_1.0_224_inat_insect_quant_edgetpu.md5sum] = "388d6f79aaa34965f8ae6b776c884079"
SRC_URI[mobilenet_v2_1.0_224_inat_insect_quant_edgetpu.sha256sum] = "03e08e9e6839995a170a4643d2ffcfeffc4fedba440c0f7e0d464ef092e86f93"
SRC_URI[inat_insect_labels.md5sum] = "0f348cbce21cccb44f14716d6fcd5376"
SRC_URI[inat_insect_labels.sha256sum] = "4912a91e047f17e4af9cea410f5a7c55680cbdb8cebc7a3c67d4a3f236b365ea"
SRC_URI[mobilenet_v2_1.0_224_inat_plant_quant_edgetpu.md5sum] = "f7887574dc1d9829e1995e7ae5ec4e18"
SRC_URI[mobilenet_v2_1.0_224_inat_plant_quant_edgetpu.sha256sum] = "d78329df56978bb81fc06a34b985ed43bed90705809e8ea2319ea9394755086a"
SRC_URI[inat_plant_labels.md5sum] = "d992885b9d4ee31649a9fcbf514518a4"
SRC_URI[inat_plant_labels.sha256sum] = "c3d744325edcf1e325637518be3103f63f7a63fd6fdc7f95e7ce6221ab97aaf5"
SRC_URI[mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.md5sum] = "975bd188c72acd0b6dfa2570c25a78f0"
SRC_URI[mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.sha256sum] = "0400fbd9c119fe74540e6e37d145b86391bc9a2a3e354c376de28f5aaf045d43"
SRC_URI[inat_bird_labels.md5sum] = "5432df2f330e7ac478ef1940349831aa"
SRC_URI[inat_bird_labels.sha256sum] = "f6eeb8056e52fe72a878c0f84ef7c9c8a393841e7d8f0800f257646e6a96c527"
SRC_URI[inception_v1_224_quant_edgetpu.md5sum] = "4ab4a45b6dbd4fa92397c341b1ee58a9"
SRC_URI[inception_v1_224_quant_edgetpu.sha256sum] = "1bf69c82819ee7f21a57096ac0a3a5968ded3cb148ba49b65b27390e48182e57"
SRC_URI[inception_v2_224_quant_edgetpu.md5sum] = "35a77705f23f24f19147d1d818b4827d"
SRC_URI[inception_v2_224_quant_edgetpu.sha256sum] = "917262345d35051fab5f8473e38aeb5d41b61f7734f83569d72f5c396b5a6268"
SRC_URI[inception_v3_299_quant_edgetpu.md5sum] = "bfd1a10275dcfdadc857e5891d5af38b"
SRC_URI[inception_v3_299_quant_edgetpu.sha256sum] = "aff3432403df57b3f0172f8553f9cf29b41fb7ee2391d1b0e9f740c261c13399"
SRC_URI[inception_v4_299_quant_edgetpu.md5sum] = "e3317f8aec7cc60deb37fa61ee7360c0"
SRC_URI[inception_v4_299_quant_edgetpu.sha256sum] = "bd1926ed63ff1f6c961823d3f96dc31dfe0ad87c6d439bb013e81898c9e42bd8"
SRC_URI[imagenet_labels.md5sum] = "e5a9c11845b354d8514554a8fe1444e1"
SRC_URI[imagenet_labels.sha256sum] = "50f42753c6c6a76d4257b5f72cb506e6b8f7266cf8819edf7d3812cf549c4d41"

do_install () {
	install -d ${D}/home/root/models/google-coral/Resnet
	install -d ${D}/home/root/models/google-coral/Efficient_Net_Model
	install -d ${D}/home/root/models/google-coral/Mobile_Net_Model
	install -d ${D}/home/root/models/google-coral/Inception_Model
	install -m 0644 ${S}/tpu/efficientnet*edgetpu.tflite ${D}/home/root/models/google-coral/Efficient_Net_Model/
	install -m 0644 ${S}/tpu/mobilenet*edgetpu.tflite ${D}/home/root/models/google-coral/Mobile_Net_Model/
	install -m 0644 ${S}/tpu/inception*edgetpu.tflite ${D}/home/root/models/google-coral/Inception_Model/
	install -m 0644 ${S}/tpu/imagenet_labels.txt ${D}/home/root/models/google-coral/Resnet/labels.txt
	install -m 0644 ${S}/tpu/imagenet_labels.txt ${D}/home/root/models/google-coral/Efficient_Net_Model/labels.txt
	install -m 0644 ${S}/tpu/imagenet_labels.txt ${D}/home/root/models/google-coral/Mobile_Net_Model/labels.txt
	install -m 0644 ${S}/tpu/inat*labels.txt ${D}/home/root/models/google-coral/Mobile_Net_Model/
	install -m 0644 ${S}/tpu/imagenet_labels.txt ${D}/home/root/models/google-coral/Inception_Model/labels.txt
	cp -r ${S}/models/google-coral/* ${D}/home/root/models/google-coral/
}

FILES_${PN} = " \
        /home/root/models/google-coral \
"
