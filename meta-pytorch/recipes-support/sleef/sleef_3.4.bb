SUMMARY = "Sleef library"
DESCRIPTION = "SLEEF"
HOMEPAGE = "https://sleef.org/"
LICENSE = "Boost-Software-License"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=e4224ccaecb14d942c71d31bef20d78c"

S = "${WORKDIR}/git"
BBCLASSEXTEND = "native"

SRC_URI = "git://github.com/shibatch/sleef;protocol=https"
SRCREV= "7f523de651585fe25cade462efccca647dcc8d02"

SRC_URI += "\
	file://0001-Fix-build-error-due-to-wrong-CFLAGS.patch \
"

inherit cmake pkgconfig

CFLAGS_append_class-native = " --std=gnu99"
CXXFLAGS_append_class-native = " --std=gnu99"

EXTRA_OECMAKE_class-target = "-DCMAKE_BUILD_TYPE=RelWithDebInfo -DNATIVE_BUILD_DIR=${RECIPE_SYSROOT_NATIVE} -DBUILD_DFT=OFF -DUSE_LIB_MPFR=OFF -DUSE_LIBM=OFF"
EXTRA_OECMAKE_class-native = "-DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF"

DEPENDS_class-target += "sleef-native openssl"

do_install_class-native(){
	install -d ${D}/${base_bindir}
	install -m 755 ${B}/bin/* ${D}/${base_bindir}
}
