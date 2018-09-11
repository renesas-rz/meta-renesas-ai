DESCRIPTION = "Create swap area to increase available memory for larger AI models"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} += " base-files"

COMPATIBLE_MACHINE = "(iwg20m|iwg21m|iwg22m)"

# Default swap size
SWAP_SIZE ?= "2048"

do_install_append() {
	# Create swap file
	install -d ${D}/mnt
	dd if=/dev/zero of=${D}/mnt/swap bs=1M count=${SWAP_SIZE}
	mkswap ${D}/mnt/swap
	chmod 600 ${D}/mnt/swap
}

FILES_${PN} = "/mnt/swap"
