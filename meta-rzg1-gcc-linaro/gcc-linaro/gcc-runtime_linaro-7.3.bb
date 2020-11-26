require gcc-linaro/gcc-${PV}.inc
require gcc/gcc-runtime.inc

FILES_libgomp-dev += "\
    ${libdir}/gcc/${TARGET_SYS}/${BINV}/include/openacc.h \
"
