# This recipe was insired from:
# https://github.com/openembedded/meta-openembedded/blob/master/meta-python/recipes-devtools/python/python-protobuf_3.6.0.bb
DESCRIPTION = "Protocol Buffers are Google’s data interchange format"
HOMEPAGE = "https://developers.google.com/protocol-buffers/"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI[md5sum] = "074abcceee0d795ba34ad6430f71d0e8"
SRC_URI[sha256sum] = "a37836aa47d1b81c2db1a6b7a5e79926062b5d76bd962115a0e615551be2b48d"

inherit pypi

# need to export these variables for python-config to work
export BUILD_SYS
export HOST_SYS
export STAGING_INCDIR
export STAGING_LIBDIR

inherit setuptools

# http://errors.yoctoproject.org/Errors/Details/184715/
# Can't find required file: ../src/google/protobuf/descriptor.proto
CLEANBROKEN = "1"
