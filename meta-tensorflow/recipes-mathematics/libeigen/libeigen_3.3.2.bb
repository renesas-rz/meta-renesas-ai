DESCRIPTION = "Eigen is a C++ template library for linear algebra: matrices, \
vectors, numerical solvers, and related algorithms."
AUTHOR = "Benoît Jacob and Gaël Guennebaud and others"
HOMEPAGE = "http://eigen.tuxfamily.org/"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://COPYING.MPL2;md5=815ca599c9df247a0c7f619bab123dad"

SRC_URI = " \
	https://gitlab.com/libeigen/eigen/-/archive/${PV}/eigen-${PV}.tar.bz2 \
	file://0001-CMakeLists.txt-install-FindEigen3.cmake-script.patch \
	file://0002-neon-jacobiRotation.patch \
"

SRC_URI[md5sum] = "b4af1024a8a2a33f6fb3358c6a2dd3d7"
SRC_URI[sha256sum] = "a530aa818520bb4e9f36e099696ca1a087e6d8e564f7e50abb544f5ac91d519f"

S = "${WORKDIR}/eigen-${PV}"

inherit cmake

EXTRA_OECMAKE += "-Dpkg_config_libdir=${libdir}"

FILES_${PN} = " \
	${libdir} \
"
FILES_${PN}-dev = " \
	${includedir} \
	usr/share/* \
	${datadir}/cmake/Modules \
"
RDEPENDS_${PN}-dev = ""
RRECOMMENDS_${PN}-dbg = "${PN}-dev (= ${EXTENDPKGV})"
