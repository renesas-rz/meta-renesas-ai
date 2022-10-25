DESCRIPTION = "Collection of simple test scripts to verify AI framework \
functionality"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} += " bash"

SRC_URI = "file://scripts/"

do_install() {
	install -d ${D}${bindir}/ai-tests
	install -m 0755 ${WORKDIR}/scripts/* ${D}${bindir}/ai-tests/
}

FILES_${PN} = "${bindir}/ai-tests/*"
