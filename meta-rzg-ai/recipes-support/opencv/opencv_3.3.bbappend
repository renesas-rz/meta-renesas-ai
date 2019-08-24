DEPENDS_append = " python-native python"

PACKAGECONFIG = "python2 eigen jpeg png tiff v4l libv4l gstreamer samples tbb gphoto2 \
    ${@bb.utils.contains("DISTRO_FEATURES", "x11", "gtk", "", d)} \
    ${@bb.utils.contains("LICENSE_FLAGS_WHITELIST", "commercial", "libav", "", d)}"

inherit pythonnative

FILES_${PN}-staticdev_aarch64 += "${datadir}/OpenCV/3rdparty/lib64/*.a"
