# Recipe from:
# https://github.com/intel/luv-yocto/blob/master/meta-oe/recipes-devtools/lapack/lapack_3.8.0.bb

SUMMARY = "Linear Algebra PACKage"
URL = "http://www.netlib.org/lapack"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=930f8aa500a47c7dab0f8efb5a1c9a40"

DEPENDS = " libgfortran "

PV = "3.8.0"

SRC_URI = "http://www.netlib.org/lapack/lapack-${PV}.tar.gz"
SRC_URI[md5sum] = "96591affdbf58c450d45c1daa540dbd2"
SRC_URI[sha256sum] = "deb22cc4a6120bff72621155a9917f485f96ef8319ac074a7afbc68aab88bcf6"

EXTRA_OECMAKE = " -DBUILD_SHARED_LIBS=ON -DCBLAS=ON "

inherit cmake pkgconfig

FILES_${PN}-dev +=" \
	${libdir}/cmake \
	${libdir}/cmake/lapack-3.8.0 \
	${libdir}/cmake/lapack-3.8.0/lapack-targets.cmake \
	${libdir}/cmake/lapack-3.8.0/lapack-targets-release.cmake \
	${libdir}/cmake/lapack-3.8.0/lapack-config.cmake \
	${libdir}/cmake/lapack-3.8.0/lapack-config-version.cmake \
"
