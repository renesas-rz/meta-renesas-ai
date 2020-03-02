# From:
# http://cgit.openembedded.org/openembedded-core/commit/?id=2c2f20a9756eccafac776e45e319af7666e6da96

do_configure () {
	for target in libbacktrace libgfortran
	do
		rm -rf ${B}/${TARGET_SYS}/$target/
		mkdir -p ${B}/${TARGET_SYS}/$target/
		cd ${B}/${TARGET_SYS}/$target/
		chmod a+x ${S}/$target/configure
		relpath=${@os.path.relpath("${S}", "${B}/${TARGET_SYS}")}
		../$relpath/$target/configure ${CONFIGUREOPTS} ${EXTRA_OECONF}
		# Easiest way to stop bad RPATHs getting into the library since we have a
		# broken libtool here
		sed -i -e 's/hardcode_into_libs=yes/hardcode_into_libs=no/' ${B}/${TARGET_SYS}/$target/libtool
	done
}

do_compile () {
	for target in libbacktrace libgfortran
	do
		cd ${B}/${TARGET_SYS}/$target/
		oe_runmake MULTIBUILDTOP=${B}/${TARGET_SYS}/$target/
	done
}

do_install () {
	cd ${B}/${TARGET_SYS}/libgfortran/
	oe_runmake 'DESTDIR=${D}' MULTIBUILDTOP=${B}/${TARGET_SYS}/libgfortran/ install
	if [ -d ${D}${libdir}/gcc/${TARGET_SYS}/${BINV}/finclude ]; then
		rmdir --ignore-fail-on-non-empty -p ${D}${libdir}/gcc/${TARGET_SYS}/${BINV}/finclude
	fi
	if [ -d ${D}${infodir} ]; then
		rmdir --ignore-fail-on-non-empty -p ${D}${infodir}
	fi
}
