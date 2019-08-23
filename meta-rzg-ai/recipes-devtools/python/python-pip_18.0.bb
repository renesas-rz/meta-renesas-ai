# This recipe was insired from:
# http://cgit.openembedded.org/meta-openembedded/commit/?id=0ec21b6a50058d703f40f77e1845bf8df637e7bd
SUMMARY = "PIP is a tool for installing and managing Python packages"
LICENSE = "MIT & LGPL-2.1"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=593c6cd9d639307226978cbcae61ad4b"

SRC_URI = "https://pypi.python.org/packages/source/p/pip/pip-${PV}.tar.gz"

SRC_URI[md5sum] = "52f75ceb21e96c258f289859a2996b60"
SRC_URI[sha256sum] = "a0e11645ee37c90b40c46d607070c4fd583e2cd46231b1c06e389c5e814eed76"

S = "${WORKDIR}/pip-${PV}"

inherit setuptools

# Since PIP is like CPAN for PERL we need to drag in all python modules to ensure everything works
RDEPENDS_${PN} = "python-modules python-distribute"
