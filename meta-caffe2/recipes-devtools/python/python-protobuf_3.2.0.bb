# This recipe was insired from:
# https://git.rigado.com/vesta/meta-vesta/blob/master/recipes-devtools/python/python-protobuf_3.2.0.bb
DESCRIPTION = "Protocol Buffers are Google’s data interchange format"
HOMEPAGE = "https://developers.google.com/protocol-buffers/"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://PKG-INFO;md5=e864f26731644725d680798a063b9b78"

SRC_URI[md5sum] = "f1daa5fee5de4e61e757a5f97e6aa7fd"
SRC_URI[sha256sum] = "a48475035c42d13284fd7bf3a2ffa193f8c472ad1e8539c8444ea7e2d25823a1"

inherit pypi

# need to export these variables for python-config to work
export BUILD_SYS
export HOST_SYS
export STAGING_INCDIR
export STAGING_LIBDIR

inherit setuptools
