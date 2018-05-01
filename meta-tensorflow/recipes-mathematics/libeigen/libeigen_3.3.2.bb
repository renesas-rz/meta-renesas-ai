DESCRIPTION = "Eigen is a C++ template library for linear algebra: matrices, \
vectors, numerical solvers, and related algorithms."
AUTHOR = "Benoît Jacob and Gaël Guennebaud and others"
HOMEPAGE = "http://eigen.tuxfamily.org/"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://COPYING.MPL2;md5=815ca599c9df247a0c7f619bab123dad"

SRC_URI = " \
	http://bitbucket.org/eigen/eigen/get/${PV}.tar.bz2 \
	file://0001-CMakeLists.txt-install-FindEigen3.cmake-script.patch \
	file://0002-neon-jacobiRotation.patch \
"

SRC_URI[md5sum] = "7a94c3280ae1961bc8df5e3bd304013a"
SRC_URI[sha256sum] = "3e1fa6e8c45635938193f84fee6c35a87fac26ee7c39c68c230e5080c4a8fe98"

S = "${WORKDIR}/eigen-eigen-da9b4e14c255"

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
