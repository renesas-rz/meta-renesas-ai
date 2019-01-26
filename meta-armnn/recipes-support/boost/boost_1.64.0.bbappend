BJAM_TOOLS = "--ignore-site-config \
		'-sTOOLS=gcc' \
		'-sGCC=${CC} '${BJAM_CONF} \
		'-sGXX=${CXX} '${BJAM_CONF} \
		cxxflags=-fPIC cflags=-fPIC \
		'-sGCC_INCLUDE_DIRECTORY=${STAGING_INCDIR}' \
		'-sGCC_STDLIB_DIRECTORY=${STAGING_LIBDIR}' \
		'-sBUILD=release <optimization>space <threading>multi <inlining>on <debug-symbols>off' \
		'-sPYTHON_ROOT=${PYTHON_ROOT}' \
		'--layout=system' \
		"

BJAM_OPTS = '${BOOST_PARALLEL_MAKE} -d+2 -q \
		${BJAM_TOOLS} \
		-sBOOST_BUILD_USER_CONFIG=${WORKDIR}/user-config.jam \
		--build-dir=${S}/${TARGET_SYS} \
		--disable-icu \
		${BJAM_EXTRA}'

do_compile_append() {
	rm -rf ${S}/${TARGET_SYS}
	bjam ${BJAM_OPTS} --prefix=${prefix} \
		--exec-prefix=${exec_prefix} \
		--libdir=${libdir} \
		--includedir=${includedir} \
		--debug-configuration
}
