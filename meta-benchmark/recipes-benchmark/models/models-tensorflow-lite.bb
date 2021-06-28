DESCRIPTION = "Models for TensorFlow Lite benchmarking"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
        file://license/COPYING;md5=c4e89413e9e0e6a372520647a3fae1ae \
        file://license/LICENSES;md5=e9e2202f0c8b59b3e76488106226194f \
"

S = "${WORKDIR}"

SRC_URI = " \
        file://models/tensorflowlite \
        file://license/LICENSES \
        file://license/COPYING \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_224.tgz;name=mobilenet_v1_1_0_224;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_192.tgz;name=mobilenet_v1_1_0_192;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_160.tgz;name=mobilenet_v1_1_0_160;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_128.tgz;name=mobilenet_v1_1_0_128;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.75_224.tgz;name=mobilenet_v1_0_75_224;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.75_192.tgz;name=mobilenet_v1_0_75_192;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.75_160.tgz;name=mobilenet_v1_0_75_160;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.75_128.tgz;name=mobilenet_v1_0_75_128;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.5_224.tgz;name=mobilenet_v1_0_50_224;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.5_192.tgz;name=mobilenet_v1_0_50_192;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.5_160.tgz;name=mobilenet_v1_0_50_160;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.5_128.tgz;name=mobilenet_v1_0_50_128;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.25_224.tgz;name=mobilenet_v1_0_25_224;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.25_192.tgz;name=mobilenet_v1_0_25_192;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.25_160.tgz;name=mobilenet_v1_0_25_160;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_0.25_128.tgz;name=mobilenet_v1_0_25_128;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_224_quant.tgz;name=mobilenet_v1_1_0_224_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_192_quant.tgz;name=mobilenet_v1_1_0_192_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_160_quant.tgz;name=mobilenet_v1_1_0_160_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_128_quant.tgz;name=mobilenet_v1_1_0_128_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.75_224_quant.tgz;name=mobilenet_v1_0_75_224_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.75_192_quant.tgz;name=mobilenet_v1_0_75_192_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.75_160_quant.tgz;name=mobilenet_v1_0_75_160_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.75_128_quant.tgz;name=mobilenet_v1_0_75_128_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.5_224_quant.tgz;name=mobilenet_v1_0_50_224_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.5_192_quant.tgz;name=mobilenet_v1_0_50_192_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.5_160_quant.tgz;name=mobilenet_v1_0_50_160_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.5_128_quant.tgz;name=mobilenet_v1_0_50_128_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.25_224_quant.tgz;name=mobilenet_v1_0_25_224_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.25_192_quant.tgz;name=mobilenet_v1_0_25_192_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.25_160_quant.tgz;name=mobilenet_v1_0_25_160_quant;subdir=tflite \
	http://download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_0.25_128_quant.tgz;name=mobilenet_v1_0_25_128_quant;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.4_224.tgz;name=mobilenet_v2_1_4_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.3_224.tgz;name=mobilenet_v2_1_3_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.0_224.tgz;name=mobilenet_v2_1_0_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.0_192.tgz;name=mobilenet_v2_1_0_192;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.0_160.tgz;name=mobilenet_v2_1_0_160;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.0_128.tgz;name=mobilenet_v2_1_0_128;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.0_96.tgz;name=mobilenet_v2_1_0_96;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.75_224.tgz;name=mobilenet_v2_0_75_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.75_192.tgz;name=mobilenet_v2_0_75_192;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.75_160.tgz;name=mobilenet_v2_0_75_160;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.75_128.tgz;name=mobilenet_v2_0_75_128;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.75_96.tgz;name=mobilenet_v2_0_75_96;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.5_224.tgz;name=mobilenet_v2_0_5_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.5_192.tgz;name=mobilenet_v2_0_5_192;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.5_160.tgz;name=mobilenet_v2_0_5_160;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.5_128.tgz;name=mobilenet_v2_0_5_128;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.5_96.tgz;name=mobilenet_v2_0_5_96;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.35_224.tgz;name=mobilenet_v2_0_35_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.35_192.tgz;name=mobilenet_v2_0_35_192;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.35_160.tgz;name=mobilenet_v2_0_35_160;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.35_128.tgz;name=mobilenet_v2_0_35_128;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_0.35_96.tgz;name=mobilenet_v2_0_35_96;subdir=tflite \
	http://download.tensorflow.org/models/tflite_11_05_08/mobilenet_v2_1.0_224_quant.tgz;name=mobilenet_v2_1.0_224_quant;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v3/checkpoints/v3-large_224_1.0_float.tgz;name=mobilenet_v3_large_1.0_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v3/checkpoints/v3-large_224_1.0_uint8.tgz;name=mobilenet_v3_large_1.0_224_quant;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v3/checkpoints/v3-large_224_0.75_float.tgz;name=mobilenet_v3_large_0.75_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v3/checkpoints/v3-small_224_1.0_float.tgz;name=mobilenet_v3_small_1.0_224;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v3/checkpoints/v3-small_224_1.0_uint8.tgz;name=mobilenet_v3_small_1.0_224_quant;subdir=tflite \
	https://storage.googleapis.com/mobilenet_v3/checkpoints/v3-small_224_0.75_float.tgz;name=mobilenet_v3_small_0.75_224;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/nasnet_mobile_2018_04_27.tgz;name=nasnet_mobile_2018_04_27;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_224_android_quant_2017_11_08.zip;name=android_quant_label;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz;name=inception_v3;subdir=tflite \
	https://download.tensorflow.org/models/tflite_11_05_08/inception_v3_quant.tgz;name=inception_v3_lite_quant;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/inception_v3_2018_04_27.tgz;name=inception_v3_lite;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/squeezenet_2018_04_27.tgz;name=squeezenet_lite;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/inception_v4_2018_04_27.tgz;name=inception_v4_float;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/inception_v4_299_quant_20181026.tgz;name=inception_v4_quant;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite_11_05_08/resnet_v2_101.tgz;name=resnet_v2_101_float;subdir=tflite \
	https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/inception_resnet_v2_2018_04_27.tgz;name=inception_resnet_v2_float;subdir=tflite \
"

SRC_URI[mobilenet_v1_1_0_224.md5sum] = "d5f69cef81ad8afb335d9727a17c462a"
SRC_URI[mobilenet_v1_1_0_224.sha256sum] = "1ccb74dbd9c5f7aea879120614e91617db9534bdfaa53dfea54b7c14162e126b"
SRC_URI[mobilenet_v1_1_0_192.md5sum] = "200ad001119a08a272d8916567cdee35"
SRC_URI[mobilenet_v1_1_0_192.sha256sum] = "ad683fb270cd1b0f49c820c4acf5fcbbfa546ae354b1345a4fff5f19f99d7c44"
SRC_URI[mobilenet_v1_1_0_160.md5sum] = "a49ea56233f1a8fde49cfe641680fe22"
SRC_URI[mobilenet_v1_1_0_160.sha256sum] = "1f612ebeda0e7e149897273c445b790ca8924a8a1488e6a61d36166a562fd89c"
SRC_URI[mobilenet_v1_1_0_128.md5sum] = "89864db0adadf8e76feb70d03febcb54"
SRC_URI[mobilenet_v1_1_0_128.sha256sum] = "d16f3102c1cb087eacf94c6a5abf0477767158fb891b2710409472bca4d988a8"
SRC_URI[mobilenet_v1_0_75_224.md5sum] = "09298fd0fdce1cbe2f29843ad29fb899"
SRC_URI[mobilenet_v1_0_75_224.sha256sum] = "bf61b3ce7ca2d045bb35fa6ab9a68732e3531291266db4a8c7715227d7425657"
SRC_URI[mobilenet_v1_0_75_192.md5sum] = "7816d346b3595cfca38a4cd6e5f6744e"
SRC_URI[mobilenet_v1_0_75_192.sha256sum] = "3d91d279cd06c055500aabdff8dfbd51a63797c7bb6b3f9a39e243f7c13997e9"
SRC_URI[mobilenet_v1_0_75_160.md5sum] = "f4789ff886c4b4d199af9e8b1a9ea92f"
SRC_URI[mobilenet_v1_0_75_160.sha256sum] = "90b3f26406a89df489373358aa89d9db7bcb66d2400160f16f3687f79e4f66b2"
SRC_URI[mobilenet_v1_0_75_128.md5sum] = "b8ebdbead55e28c9c2a7f8480a0698af"
SRC_URI[mobilenet_v1_0_75_128.sha256sum] = "54a28065f6f230d0b71cf8fbbc50bbb89b4fdfada8e7e2a622da68b971d5ab97"
SRC_URI[mobilenet_v1_0_50_224.md5sum] = "d051d0cc0beb03bafad514d50df01584"
SRC_URI[mobilenet_v1_0_50_224.sha256sum] = "0eb9be8d18dcf9466a2a2d2157e71c83cd70dc168255d76d72bfe965318db725"
SRC_URI[mobilenet_v1_0_50_192.md5sum] = "178ec09b296431d168e5396b50104193"
SRC_URI[mobilenet_v1_0_50_192.sha256sum] = "57c81cc48349d1079377f8cdeed3f017500aeb98a12f16c6ed2086a50848ecb6"
SRC_URI[mobilenet_v1_0_50_160.md5sum] = "ddba7fbb954f50cdb3556cc8f4a712a3"
SRC_URI[mobilenet_v1_0_50_160.sha256sum] = "fb01b76ca1fb053e5f98d297e21c6c53d0d9f6a8b02ad2e88ac22b33b2adf729"
SRC_URI[mobilenet_v1_0_50_128.md5sum] = "1950d02e12e2c85613c6f973b1213d1b"
SRC_URI[mobilenet_v1_0_50_128.sha256sum] = "5a0def0d844327526385b110cdcaa6428d0828ff6d07515ef25bf3976e049d88"
SRC_URI[mobilenet_v1_0_25_224.md5sum] = "b21d34a0b1c86118d9ce20ae5f5a0cc3"
SRC_URI[mobilenet_v1_0_25_224.sha256sum] = "eee166d4d1de004e2ee5de19a4f5045574d764ef59569dc284545f805a295074"
SRC_URI[mobilenet_v1_0_25_192.md5sum] = "9fffc16855328309ca541e69b5c2175b"
SRC_URI[mobilenet_v1_0_25_192.sha256sum] = "4889d7afabc31011f5218f6111532947ff7d5b6b9368afe1f152c67c6f30ea73"
SRC_URI[mobilenet_v1_0_25_160.md5sum] = "288bf081d11d999536672f8c96471472"
SRC_URI[mobilenet_v1_0_25_160.sha256sum] = "8eb4540af0227e5e59849c41ca6da6f07e257cca887ec0f8cd33aeb46f1405cf"
SRC_URI[mobilenet_v1_0_25_128.md5sum] = "3d99f64a0b61394984d52ae9527cfea6"
SRC_URI[mobilenet_v1_0_25_128.sha256sum] = "34c52de7562259f66399993ef5ea222cc625d2e6f6f886a01fdc6cc99a0c7ee6"
SRC_URI[mobilenet_v1_1_0_224_quant.md5sum] = "36af340c00e60291931cb30ce32d4e86"
SRC_URI[mobilenet_v1_1_0_224_quant.sha256sum] = "d32432d28673a936b2d6281ab0600c71cf7226dfe4cdcef3012555f691744166"
SRC_URI[mobilenet_v1_1_0_192_quant.md5sum] = "5afac0ff77dd96c4629e67eed4f530f3"
SRC_URI[mobilenet_v1_1_0_192_quant.sha256sum] = "b87b20c784e756fb52e265cc31fbea5b3236c9a001205bc24ed27985875b4559"
SRC_URI[mobilenet_v1_1_0_160_quant.md5sum] = "095cdb2d648f36490a374837552b76cf"
SRC_URI[mobilenet_v1_1_0_160_quant.sha256sum] = "b5c9da0d5215a1c1faab313f88ba0a900ac199c7af45f559ab65c63b0649bee1"
SRC_URI[mobilenet_v1_1_0_128_quant.md5sum] = "2055a82e4a7339b8f3bbf3b6c6a53921"
SRC_URI[mobilenet_v1_1_0_128_quant.sha256sum] = "29aec24c721329b83ff667195431ff9151362ba1854dfc8852d03aef5ac40def"
SRC_URI[mobilenet_v1_0_75_224_quant.md5sum] = "2f809f0ee6e09409b65c8fd87034c245"
SRC_URI[mobilenet_v1_0_75_224_quant.sha256sum] = "6c40604a53edb295e6fd72ead340759db63a2e4d930593610f4d09efe17aa9b7"
SRC_URI[mobilenet_v1_0_50_192_quant.md5sum] = "997399d60a87a1877475973fec03153b"
SRC_URI[mobilenet_v1_0_50_192_quant.sha256sum] = "b3b7aca2599c9a09f7ebeb3f624fc51bc4897b9356950b67a5f11c65666dab3d"
SRC_URI[mobilenet_v1_0_75_160_quant.md5sum] = "3d7c9aceadbc262abda3d7827da8a9d3"
SRC_URI[mobilenet_v1_0_75_160_quant.sha256sum] = "ed023a21c1fbb062a4777056f79910aab6137c9a83655317020faed6ad0ca738"
SRC_URI[mobilenet_v1_0_75_128_quant.md5sum] = "33b8c9e0a2f3378660675468eb50bdaa"
SRC_URI[mobilenet_v1_0_75_128_quant.sha256sum] = "14cd0b9c5cde26272c68ecc50de054979663e28fb1fd0348166d408a8b45538f"
SRC_URI[mobilenet_v1_0_75_192_quant.md5sum] = "3279a583c3db6ff40a3673eb6163a9e4"
SRC_URI[mobilenet_v1_0_75_192_quant.sha256sum] = "8dc64937bd9f35dcf8d3baa16b8eda47e2473c3af51641bf309d1ed2b1a355af"
SRC_URI[mobilenet_v1_0_50_224_quant.md5sum] = "3a12c2a5e3c1c836f1d00ee03c759c89"
SRC_URI[mobilenet_v1_0_50_224_quant.sha256sum] = "f61c28ab322a3ef441341431d33732ef79dfbf03ebc00769c12e5843573b2e9c"
SRC_URI[mobilenet_v1_0_50_192_quant.md5sum] = "997399d60a87a1877475973fec03153b"
SRC_URI[mobilenet_v1_0_50_192_quant.sha256sum] = "b3b7aca2599c9a09f7ebeb3f624fc51bc4897b9356950b67a5f11c65666dab3d"
SRC_URI[mobilenet_v1_0_50_160_quant.md5sum] = "e3b83009a9dd9052223feaf743e32ec0"
SRC_URI[mobilenet_v1_0_50_160_quant.sha256sum] = "036ff1a53180f844ee629ae5846c2b18dfa94371c51c44016c70dc9688a34d31"
SRC_URI[mobilenet_v1_0_50_128_quant.md5sum] = "5cc8484cf04a407fc90993296f3f02db"
SRC_URI[mobilenet_v1_0_50_128_quant.sha256sum] = "0a5b18571d3df4d85a5ac6cb5be829d141dd5855243ea04422ca7d19f730a506"
SRC_URI[mobilenet_v1_0_25_224_quant.md5sum] = "52fa23a37a02f8fd76ec979afca3b26a"
SRC_URI[mobilenet_v1_0_25_224_quant.sha256sum] = "be8131a23c93a83d7d0b1875ac34aa2e06319aef377f89dc6be2e8f10a0589ca"
SRC_URI[mobilenet_v1_0_25_192_quant.md5sum] = "f91c8e43586cbece48b6d100696ede78"
SRC_URI[mobilenet_v1_0_25_192_quant.sha256sum] = "33f4ca5c5c7fb70f81a23ec06a884482ddcf5d26e32e4211781e110afb7a0877"
SRC_URI[mobilenet_v1_0_25_160_quant.md5sum] = "55ae29a6849a9595893ca2bdfd5dfc1e"
SRC_URI[mobilenet_v1_0_25_160_quant.sha256sum] = "8aba0b905df472d994c1d923efa743c7dfe182df579e0440b8e78c8f714ddc98"
SRC_URI[mobilenet_v1_0_25_128_quant.md5sum] = "39f06514361a7612a7e092cc7fbf9d8a"
SRC_URI[mobilenet_v1_0_25_128_quant.sha256sum] = "40230cd1a429a20cfd648f08f72b6d554ca8f4bff838341cb8210bd167962c0e"
SRC_URI[mobilenet_v2_1_4_224.md5sum] = "a0e9cfd929dcdce2795a377ab9456364"
SRC_URI[mobilenet_v2_1_4_224.sha256sum] = "a20d0c8d698502dc6a620528871c97a588885df7737556243a3412b39fce85e0"
SRC_URI[mobilenet_v2_1_3_224.md5sum] = "0d0de8e26335e2e7848adf0b43057a2e"
SRC_URI[mobilenet_v2_1_3_224.sha256sum] = "b04129d44a46e0eb409c1a2bc255472ebdd57f9c091812e7866d79d0cc7fecaa"
SRC_URI[mobilenet_v2_1_0_224.md5sum] = "519bba7052fd279c66d2a28dc3f51f46"
SRC_URI[mobilenet_v2_1_0_224.sha256sum] = "318084bc1b63d6d7b854553e09cdf77078b1c0168be27c59a0d44253b5ed49dc"
SRC_URI[mobilenet_v2_1_0_192.md5sum] = "8268d358d74335ca28fcf3bd2c9569e7"
SRC_URI[mobilenet_v2_1_0_192.sha256sum] = "e8d9cd7c571f375c80945b5f889705ae412db32d3419d747e796429e39132f48"
SRC_URI[mobilenet_v2_1_0_160.md5sum] = "cbc05803a710b8a5c4771a2418399e8a"
SRC_URI[mobilenet_v2_1_0_160.sha256sum] = "e374bc70066dde0c3af6cb4c98ecd8707800d71d11353c4cc359b3069415f23e"
SRC_URI[mobilenet_v2_1_0_128.md5sum] = "54a62717fa1fdab9a003160e10bd906d"
SRC_URI[mobilenet_v2_1_0_128.sha256sum] = "f692e341cf1529df4f7e68ed13d0284ad8796ade1108f802eec135abc1fc1b83"
SRC_URI[mobilenet_v2_1_0_96.md5sum] = "05d0269ff958f60093e45d1b286887c9"
SRC_URI[mobilenet_v2_1_0_96.sha256sum] = "8f0377b71d79f5626c5198f248b476d2604b3e4e596ca4076e1b1f8fcd3f3844"
SRC_URI[mobilenet_v2_0_75_224.md5sum] = "7340869db06c13d4c2dcafba7422e7b6"
SRC_URI[mobilenet_v2_0_75_224.sha256sum] = "335cd22c7e1c5e80205dedd6e2ff5d1d8af5c29074496eb047fd621349e10cc5"
SRC_URI[mobilenet_v2_0_75_192.md5sum] = "69548a316b07363a1228c43116cecbb0"
SRC_URI[mobilenet_v2_0_75_192.sha256sum] = "40efef9324376d47b872d1cd6e4de8ba7c9323b6203252aa66dc2b2413e0dc8d"
SRC_URI[mobilenet_v2_0_75_160.md5sum] = "e1faa2e1fb0234a2891fbcee4aba9d1f"
SRC_URI[mobilenet_v2_0_75_160.sha256sum] = "904d1a1f84c329ad766464d132f697e96814685853c45c6ee4dd21877ada36bc"
SRC_URI[mobilenet_v2_0_75_128.md5sum] = "4e44488b2d39028f8291784940a96a97"
SRC_URI[mobilenet_v2_0_75_128.sha256sum] = "9ac932679a9fb1304bc1435bb7fa30e1b2fcaa7f49e0902da24d154ec83f9302"
SRC_URI[mobilenet_v2_0_75_96.md5sum] = "736db1e56eb7ef01cee2538faa95c9a5"
SRC_URI[mobilenet_v2_0_75_96.sha256sum] = "bdf06eec5478dbb1bb9e01648637d8acd4cc500f72e1a3dad01ba45642e31e6f"
SRC_URI[mobilenet_v2_0_5_224.md5sum] = "e1b979df3d33151383e8807db9c9842e"
SRC_URI[mobilenet_v2_0_5_224.sha256sum] = "813febbdbe2a7a50055ee2f6b374938aed03e2f607f63f3479622aefc4e12b00"
SRC_URI[mobilenet_v2_0_5_192.md5sum] = "54cb66c102743931a0b380968a79c99d"
SRC_URI[mobilenet_v2_0_5_192.sha256sum] = "5a344ed91cded5d420b6c65d47343ee60b43b570953b0feed4ee95451a679dd5"
SRC_URI[mobilenet_v2_0_5_160.md5sum] = "abb2397e27ae7642a10ca2a6cdbc5bbe"
SRC_URI[mobilenet_v2_0_5_160.sha256sum] = "f89c879b1a45c5d677ad7fe499f08a7854ef1772f0f5ae5d606afaaa87218e45"
SRC_URI[mobilenet_v2_0_5_128.md5sum] = "7f6aadca635b511747f559668493c709"
SRC_URI[mobilenet_v2_0_5_128.sha256sum] = "ba078efd101c2308fb978467084f0ec12485ed8bfbb7695e477587b3272a1d66"
SRC_URI[mobilenet_v2_0_5_96.md5sum] = "3296faa9e613693861e1da473cadda7f"
SRC_URI[mobilenet_v2_0_5_96.sha256sum] = "71a814047d7729bad711ae3e7db30e6c32999a1189f88d328b73939f7aa80d62"
SRC_URI[mobilenet_v2_0_35_224.md5sum] = "f156373ba8e267406612b1840d9f908c"
SRC_URI[mobilenet_v2_0_35_224.sha256sum] = "efcc34277c52f7dd4b0b26c2f52686793f4ea5fdddc899ac5aac9eb8d5861550"
SRC_URI[mobilenet_v2_0_35_192.md5sum] = "59e403ce85f4e7735e485d9119ec3ec5"
SRC_URI[mobilenet_v2_0_35_192.sha256sum] = "5dec603e2714a780c3cfc0656dac51bf2f4b354c4f7acda879ad5b6017f3f55b"
SRC_URI[mobilenet_v2_0_35_160.md5sum] = "13cfc1572991aa1b76049ab8f12eeb73"
SRC_URI[mobilenet_v2_0_35_160.sha256sum] = "e579b5b50f47e88dc0c4390d20a396658b97457182f83905154a8a687ba15fa7"
SRC_URI[mobilenet_v2_0_35_128.md5sum] = "efc7ea5ab4f79de31839e9e6e3e7f7d6"
SRC_URI[mobilenet_v2_0_35_128.sha256sum] = "c21a8f89e2e1a49e9002b1e1b871f3c92695ccb0cd64e7e7a21b71f2820beddb"
SRC_URI[mobilenet_v2_0_35_96.md5sum] = "febca108cd0b73a5fd5f584a6fc95939"
SRC_URI[mobilenet_v2_0_35_96.sha256sum] = "282996bca7d799d0172ce5d34ac59dea497c4c75f069a8b466bb944c6f843353"
SRC_URI[mobilenet_v2_1.0_224_quant.md5sum] = "04b4cc2536e1a51b9d29e98921b4970b"
SRC_URI[mobilenet_v2_1.0_224_quant.sha256sum] = "d6a04d780f76f656c902413be432eb349ec4a458240e3739119eb44977f77a79"
SRC_URI[mobilenet_v3_large_1.0_224.md5sum] = "539c3186043d5725ef01d5bc6dd1d8a4"
SRC_URI[mobilenet_v3_large_1.0_224.sha256sum] = "9be8563f92022f412c82f2811d670888d6db998e2da9af3e71415fdde2f4f504"
SRC_URI[mobilenet_v3_large_1.0_224_quant.md5sum] = "c72724f7067091c6a02f04923d0bb66c"
SRC_URI[mobilenet_v3_large_1.0_224_quant.sha256sum] = "42cfd69fb70c48dde56dc3f2c872bdeb4fdc9beb3105e4b164dde7c49b7a2702"
SRC_URI[mobilenet_v3_large_0.75_224.md5sum] = "fe46e947f5136fc478708a387bddff74"
SRC_URI[mobilenet_v3_large_0.75_224.sha256sum] = "4346e7893769d3f8ac79e28e7924b351bf8348a8a4d5e7a606260003e706aea5"
SRC_URI[mobilenet_v3_small_1.0_224.md5sum] = "9d59adb54114287e5ee7015e7ce96dc1"
SRC_URI[mobilenet_v3_small_1.0_224.sha256sum] = "e60ad9f450f892ae56f8b9122ffc750d88940d9e6b63f6dc70649179fb3a9065"
SRC_URI[mobilenet_v3_small_1.0_224_quant.md5sum] = "357be4891027d76e731afe3a813cac28"
SRC_URI[mobilenet_v3_small_1.0_224_quant.sha256sum] = "58ecd8c4c5b0a330f1d72c0a3d7bc6073ff771e14b052da336691246ee8e178f"
SRC_URI[mobilenet_v3_small_0.75_224.md5sum] = "237ae52459ba3ff111184f2fb3824520"
SRC_URI[mobilenet_v3_small_0.75_224.sha256sum] = "fffd2e437434f319623ecf26cdbebdb933dcd753afa38e7c2f78cb59c6fc470f"
SRC_URI[nasnet_mobile_2018_04_27.md5sum] = "398345d7af082c173d90989d44d856db"
SRC_URI[nasnet_mobile_2018_04_27.sha256sum] = "b3a3c5471f23f165e49fe0c2e56a3c503eeaa6f85d97f22369e3c36088e127c5"
SRC_URI[inception_v3_lite_quant.md5sum] = "793957d66db09148bc2b11a4b6358b02"
SRC_URI[inception_v3_lite_quant.sha256sum] = "d75a319eaef4d34b985bc319db260197a464893a9380f8167432ad2492e1995e"
SRC_URI[inception_v3_lite.md5sum] = "0385eb7934873208a7a381e5a026e7f1"
SRC_URI[inception_v3_lite.sha256sum] = "b1a1f91276e48a9ddf0cb0d854f044ebfbf985dc2c2cedceb52b3d668894299a"
SRC_URI[squeezenet_lite.md5sum] = "8effe92b879970cad0953868401cb2b2"
SRC_URI[squeezenet_lite.sha256sum] = "75fc495b2792db6edccdc3a6f1bced19622b59dcc8835f386ab39f481ca1db9c"
SRC_URI[android_quant_label.md5sum] = "ad2ba2089114cf03a5b8189bc4c09c59"
SRC_URI[android_quant_label.sha256sum] = "23f814d1c076bdf03715dfb6cab3713aa4fbdf040fd5448c43196bd2e97a4c1b"
SRC_URI[inception_v3.md5sum] = "a904ddf15593d03c7dd786d552e22d73"
SRC_URI[inception_v3.sha256sum] = "7045b72a954af4dce36346f478610acdccbf149168fa25c78e54e32f0c723d6d"
SRC_URI[inception_v4_float.md5sum] = "97da95494e4a4d755cf79d636c726bcb"
SRC_URI[inception_v4_float.sha256sum] = "305e45035c690f7a064b5babe27ea68a4e6da5819147c7c94319963c6f256467"
SRC_URI[inception_v4_quant.md5sum] = "2dff9819d610b98768927530f57a25d3"
SRC_URI[inception_v4_quant.sha256sum] = "e26c7fc6928efe9c63642eec0a72f8ae3fd9e12c04b25845c50ac4b8828e18f7"
SRC_URI[resnet_v2_101_float.md5sum] = "e85b06c92f547108397650318c9f556a"
SRC_URI[resnet_v2_101_float.sha256sum] = "c624931eed69e4a6c5d7b67e76d0303f6d868cefc4c9f5108619c1fc1ce2eb89"
SRC_URI[inception_resnet_v2_float.md5sum] = "59d4080bd81c1b675d2124672d8afe4c"
SRC_URI[inception_resnet_v2_float.sha256sum] = "fb16b93ff2b2bcda0da5cdfd25a8d5b8b74438943dae738db659bad0d3d48ff1"

do_install () {
	install -d ${D}/home/root/models/tensorflowlite/Mobile_Net_V1_Model
	install -d ${D}/home/root/models/tensorflowlite/Mobile_Net_V2_Model
	install -d ${D}/home/root/models/tensorflowlite/Mobile_Net_V3_Model
	install -d ${D}/home/root/models/tensorflowlite/NasNet
	install -d ${D}/home/root/models/tensorflowlite/Mobile_InceptionV3
	install -d ${D}/home/root/models/tensorflowlite/Mobile_InceptionV4
	install -d ${D}/home/root/models/tensorflowlite/Squeezenet
	install -d ${D}/home/root/models/tensorflowlite/MnasNet
	install -d ${D}/home/root/models/tensorflowlite/Resnet
	install -m 0644 ${S}/tflite/mobilenet_v1*.tflite ${D}/home/root/models/tensorflowlite/Mobile_Net_V1_Model/
	install -m 0644 ${S}/tflite/mobilenet_v2*.tflite ${D}/home/root/models/tensorflowlite/Mobile_Net_V2_Model/
	install -m 0644 ${S}/tflite/v3*/v3*.tflite ${D}/home/root/models/tensorflowlite/Mobile_Net_V3_Model/
	install -m 0644 ${S}/tflite/nasnet*.tflite ${D}/home/root/models/tensorflowlite/NasNet/
	install -m 0644 ${S}/tflite/squeezenet*.tflite ${D}/home/root/models/tensorflowlite/Squeezenet/
	install -m 0644 ${S}/tflite/inception_resnet_v2.tflite ${D}/home/root/models/tensorflowlite/Resnet/
	install -m 0644 ${S}/tflite/resnet_v2_101_299.tflite ${D}/home/root/models/tensorflowlite/Resnet/
	install -m 0644 ${S}/tflite/labels.txt ${D}/home/root/models/tensorflowlite/Mobile_Net_V1_Model/
	install -m 0644 ${S}/tflite/labels.txt ${D}/home/root/models/tensorflowlite/Mobile_Net_V2_Model/
	install -m 0644 ${S}/tflite/labels.txt ${D}/home/root/models/tensorflowlite/Mobile_Net_V3_Model/
	install -m 0644 ${S}/tflite/labels.txt ${D}/home/root/models/tensorflowlite/NasNet/
	install -m 0644 ${S}/tflite/labels.txt ${D}/home/root/models/tensorflowlite/Squeezenet/
	install -m 0644 ${S}/tflite/labels.txt ${D}/home/root/models/tensorflowlite/Resnet/
	install -m 0644 ${S}/tflite/imagenet_slim_labels.txt ${D}/home/root/models/tensorflowlite/Mobile_InceptionV3/labels.txt
	install -m 0644 ${S}/tflite/inception_v3*.tflite ${D}/home/root/models/tensorflowlite/Mobile_InceptionV3/
	install -m 0644 ${S}/tflite/imagenet_slim_labels.txt ${D}/home/root/models/tensorflowlite/Mobile_InceptionV4/labels.txt
	install -m 0644 ${S}/tflite/inception_v4*.tflite ${D}/home/root/models/tensorflowlite/Mobile_InceptionV4/
	cp -r ${S}/models/tensorflowlite/* ${D}/home/root/models/tensorflowlite/
}

FILES_${PN} = " \
        /home/root/models/tensorflowlite \
"
