DESCRIPTION = "Models for Google Coral benchmarking"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=a9b73dae4a0b3a752f7eccb813bc2820 \
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
SRC_URI[mobilenet_v1_1.0_224_quant_edgetpu.md5sum] = "27298f96d32c0ec68194b8cb9e125e51"
SRC_URI[mobilenet_v1_1.0_224_quant_edgetpu.sha256sum] = "393e2c16cc2f560685e1d39ceba638d16497baf43049a61131bb0fa16381a02e"
SRC_URI[mobilenet_v2_1.0_224_quant_edgetpu.md5sum] = "57ba2a496f1c9ba2620e5f42491717af"
SRC_URI[mobilenet_v2_1.0_224_quant_edgetpu.sha256sum] = "93f21e950980fe452c7e9e108744d1a2e423a2cfd166235078400f88c758ea67"
SRC_URI[mobilenet_v2_1.0_224_inat_insect_quant_edgetpu.md5sum] = "0a76479617d3ef08ca20a1832017e608"
SRC_URI[mobilenet_v2_1.0_224_inat_insect_quant_edgetpu.sha256sum] = "5b837d744e2439faacd1992cad09f4743108024cd0c9f9a68f9659c1de7120a0"
SRC_URI[inat_insect_labels.md5sum] = "0f348cbce21cccb44f14716d6fcd5376"
SRC_URI[inat_insect_labels.sha256sum] = "4912a91e047f17e4af9cea410f5a7c55680cbdb8cebc7a3c67d4a3f236b365ea"
SRC_URI[mobilenet_v2_1.0_224_inat_plant_quant_edgetpu.md5sum] = "63a83dd30dede473826502a1c8ae84be"
SRC_URI[mobilenet_v2_1.0_224_inat_plant_quant_edgetpu.sha256sum] = "56b7c8784492595ec37e5ea7c0d595e537e0ac063d954c93a3af4bd906169aa7"
SRC_URI[inat_plant_labels.md5sum] = "d992885b9d4ee31649a9fcbf514518a4"
SRC_URI[inat_plant_labels.sha256sum] = "c3d744325edcf1e325637518be3103f63f7a63fd6fdc7f95e7ce6221ab97aaf5"
SRC_URI[mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.md5sum] = "3286aeff45bbfad202801385d2560e9e"
SRC_URI[mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.sha256sum] = "8bcc4b9ec9c417835f7c63c995705b535dc56245deb42830ef71ed2e8ef18928"
SRC_URI[inat_bird_labels.md5sum] = "5432df2f330e7ac478ef1940349831aa"
SRC_URI[inat_bird_labels.sha256sum] = "f6eeb8056e52fe72a878c0f84ef7c9c8a393841e7d8f0800f257646e6a96c527"
SRC_URI[inception_v1_224_quant_edgetpu.md5sum] = "64e65792b164e59f3b875d4e83a77289"
SRC_URI[inception_v1_224_quant_edgetpu.sha256sum] = "0afb8d72feb09d49f76dc64b466d530aaf980f1c88a34be88460f0b92187304d"
SRC_URI[inception_v2_224_quant_edgetpu.md5sum] = "0e2a691bfb0644c7c9fb098a9591ea25"
SRC_URI[inception_v2_224_quant_edgetpu.sha256sum] = "74576c8a528796eff0f766331c6e3da801250ba7514a166c5db217936f9804d5"
SRC_URI[inception_v3_299_quant_edgetpu.md5sum] = "0474951e74400bda2bdc39be1c313d2f"
SRC_URI[inception_v3_299_quant_edgetpu.sha256sum] = "28bccce03dc60632f34e167cd5ad5c6b2d8f0ff0d7a853ed1008a9f1555b8add"
SRC_URI[inception_v4_299_quant_edgetpu.md5sum] = "14bad888f29645701ab500f2e36c3b07"
SRC_URI[inception_v4_299_quant_edgetpu.sha256sum] = "8c7c1dd5245a07d6a2c7229c04801cdad88e6b6bbb0d87adf6ae80218efcd0c2"
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
