IMAGE_INSTALL_append = " htop"
IMAGE_FSTYPES_append = " wic.gz"
WKS_FILE = "sdimage-rootfs.wks"

# Remove lttng as it's failing to compile with the RZ/G v3.0.0 BSP when
# CIP_CORE=0 is set.
IMAGE_INSTALL_remove = " \
	lttng-modules \
	lttng-tools \
	lttng-ust \
"
