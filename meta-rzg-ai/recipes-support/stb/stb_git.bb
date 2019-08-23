# This recipe was inspired from:
# https://layers.openembedded.org/layerindex/recipe/87611/
DESCRIPTION = "single-file public domain (or MIT licensed) libraries for C/C++"
SUMMARY = "C/C++ header only utility libraries"
HOMEPAGE = "https://github.com/nothings/stb"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://README.md;md5=42144ce827adcfa5170032f0ea03c227"

SRCREV = "e6afb9cbae4064da8c3e69af3ff5c4629579c1d2"

SRC_URI = " \
    git://github.com/nothings/stb.git;branch=master \
"

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}${includedir}
    for hdr in ${S}/*.h
    do
        install -m 0644 $hdr ${D}${includedir}
    done
}

FILES_${PN} = " \
        ${includedir} \
"
