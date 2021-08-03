# Disable ifuncs for libatomic on arm conflicts -march/-mcpu
EXTRA_OECONF_append_aarch64 = " libat_cv_have_ifunc=no "
