SUMMARY = "A New Lightweight, Modular, and Scalable Deep Learning Framework"
DESCRIPTION = "Caffe2 aims to provide an easy and straightforward way for you \
to experiment with deep learning and leverage community contributions of new \
models and algorithms. You can bring your creations to scale using the power \
of GPUs in the cloud or to the masses on mobile with Caffe2's cross-platform \
libraries"
LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=80651d10fcb4d58e5cb4c839df037144"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m)"

S = "${WORKDIR}/git"

SRC_URI = " \
	git://github.com/caffe2/caffe2.git \
	file://0001-Remove-unwind-symbol.patch \
	file://0002-Always-use-third_party-eigen.patch \
	file://0001-Fix-compilation-errors-when-using-GCC-7.2.1.patch \
"

SRCREV = "32f023fe8c0a0327f8f14b1c041536a7c6b1f4ec"

FILES_${PN} += " \
	/usr/caffe/* \
	/usr/caffe2/* \
	${libdir}/*.so \
"

FILES_${PN}-dev = " \
	${includedir} \
"

FILES_${PN}-dbg += " \
	/usr/caffe2/python/.debug/* \
"

DEPENDS += " \
	protobuf \
	protobuf-native \
	python-numpy \
	python-numpy-native \
	opencv \
"

RDEPENDS_${PN} = " \
	python \
	python-pip \
	python-setuptools \
	python-opencv \
	protobuf \
	gflags \
	glog \
	python-protobuf \
	python-future \
	python-six \
	python-numpy \
	libgomp \
"

inherit cmake python-dir

EXTRA_OECMAKE = " \
	-DPYTHON_NUMPY_INCLUDE_DIR=${STAGING_DIR_TARGET}/usr/lib/python2.7/site-packages/numpy/core/include \
	-DPYTHON_EXECUTABLE=${STAGING_BINDIR_NATIVE}/python-native/python2.7 \
	-DBUILD_TEST=OFF \
	-DUSE_NCCL=ON \
	-DCMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES=${STAGING_INCDIR} \
"

addtask do_fetch_fixup after do_unpack before do_patch

# Unfortunately Caffe2 has broken references, and on top of that we better pick
# up more suitable versions for the third party submodules.
do_fetch_fixup () {
	export HTTP_PROXY=${HTTP_PROXY}
	export HTTPS_PROXY=${HTTPS_PROXY}
	cd ${S}
	git submodule deinit -f third_party/NNPACK
	git submodule deinit -f third_party/benchmark
	git submodule deinit -f third_party/eigen
	git submodule deinit -f third_party/gloo
	git submodule deinit -f third_party/googletest
	git submodule deinit -f third_party/ios-cmake
	git submodule deinit -f third_party/nccl
	git submodule deinit -f third_party/protobuf
	git submodule deinit -f third_party/pybind11
	git rm -rf third_party/cub
	git rm -rf third_party/nervanagpu
	sed -i "s|https://github.com/RLovelett/eigen.git|https://github.com/eigenteam/eigen-git-mirror.git|g" .gitmodules
	sed -i '/nervanagpu/d' .gitmodules
	git add .gitmodules
	git commit -m "Fixup for broken dependencies"
	git submodule init
	git submodule update
	cd third_party/NNPACK 		&& git checkout 087269189207a63ab7084e6925ea511d8952fa59 && cd ../..
	cd third_party/benchmark/ 	&& git checkout 491360b833aaab96818dce256a8409f6296dd995 && cd ../..
	cd third_party/eigen/ 		&& git checkout 4e79cb69b9425f5f8c3a84be4350d4ab75b5fd9d && cd ../..
	cd third_party/gloo/ 		&& git checkout 9b2c046e5f7d4a8ec61598d382838a8f6867a1d4 && cd ../..
	cd third_party/googletest/ 	&& git checkout 69e48e92de43960a316a826293510b7b3deb9eca && cd ../..
	cd third_party/ios-cmake/ 	&& git checkout 8abaed637d56f1337d6e1d2c4026e25c1eade724 && cd ../..
	cd third_party/nccl/ 		&& git checkout 03d856977ecbaac87e598c0c4bafca96761b9ac7 && cd ../..
	cd third_party/protobuf/ 	&& git checkout 2761122b810fe8861004ae785cc3ab39f384d342 && cd ../..
	cd third_party/pybind11/ 	&& git checkout add56ccdcac23a6c522a2c1174a866e293c61dab && cd ../..
}
