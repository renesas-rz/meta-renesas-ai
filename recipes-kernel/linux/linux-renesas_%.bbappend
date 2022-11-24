FILESEXTRAPATHS_prepend := "${THISDIR}/linux-renesas:"

SRC_URI_append = " \
	file://swap.cfg \
	file://0001-Revert-arm64-dts-renesas-cat875-Add-EtherAVB-interna.patch \
"
