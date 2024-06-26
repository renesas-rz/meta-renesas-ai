DESCRIPTION = "The Compute Library contains a comprehensive collection of \
software functions implemented for the Arm Cortex-A family of CPU \
processors and the Arm Mali family of GPUs. It is a convenient repository \
of low-level optimized functions that developers can source individually \
or use as part of complex pipelines in order to accelerate their algorithms \
and applications."
SUMMARY = "Arm Compute Library"
HOMEPAGE = "https://developer.arm.com/technologies/compute-library"
DESCRIPTION = "Arm Compute Library"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=44ab5c3155cc6931b2798b49c354b7bd"

# Tag v24.06
SRCREV = "505adb91d40e05b3f80a075a4467a78a253395e1"

SRC_URI = " \
	git://github.com/ARM-software/ComputeLibrary.git;branch=main;protocol=https \
	file://0001-Add-support-for-building-aarch64-CL-with-Scons.patch \
"

COMPATIBLE_MACHINE = "(hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874|smarc-rzg2l|smarc-rzg2lc|smarc-rzg2ul|smarc-rzv2l)"

S = "${WORKDIR}/git"

PR = "r0"

inherit scons

OESCONS_COMMON_FLAG = " extra_cxx_flags="${TOOLCHAIN_OPTIONS} -Wno-error=noexcept -O" benchmark_tests=1 \
			validation_tests=0 neon=1 openmp=1 opencl=0 set_soname=1"

EXTRA_OESCONS_aarch64 = "arch=arm64-v8a${OESCONS_COMMON_FLAG}"

# Override the platform generic opencl flag for RZ/G2L, RZ/G2LC and RZ/V2L
OESCONS_COMMON_FLAG_append_smarc-rzg2l  = " opencl=1 embed_kernels=1 arch=armv8.2-a"
OESCONS_COMMON_FLAG_append_smarc-rzg2lc = " opencl=1 embed_kernels=1 arch=armv8.2-a"
OESCONS_COMMON_FLAG_append_smarc-rzg2ul  = " arch=armv8.2-a"
OESCONS_COMMON_FLAG_append_smarc-rzv2l = " opencl=1 embed_kernels=1 arch=armv8.2-a"

do_install() {
	CP_ARGS="-Prf --preserve=mode,timestamps --no-preserve=ownership"

	install -d ${D}${libdir}
	for lib in ${S}/build/*.so*
	do
		cp $CP_ARGS $lib ${D}${libdir}
	done

	for lib in ${S}/build/*.a
	do
		cp $CP_ARGS $lib ${D}${libdir}
	done

	install -d ${D}${datadir}/${BPN}

	cp $CP_ARGS ${S}/arm_compute ${D}${datadir}/${BPN}/.
	cp $CP_ARGS ${S}/include ${D}${datadir}/${BPN}/.
	cp $CP_ARGS ${S}/support ${D}${datadir}/${BPN}/.
}

FILES_${PN} = " \
               ${libdir}/libarm_compute_graph.so.38.0.0 \
               ${libdir}/libarm_compute.so.38.0.0 \
"

#Symlink .so files should go into the -dev package
FILES_${PN}-dev = "${datadir}/arm-compute-library \
                   ${libdir}/libarm_compute_graph.so.38 \
                   ${libdir}/libarm_compute.so.38 \
                   ${libdir}/libarm_compute.so \
                   ${libdir}/libarm_compute_graph.so \
"

FILES_${PN}-dbg = "${libdir}/.debug"

FILES_${PN}-staticdev = "${libdir}/*.a"

INSANE_SKIP_${PN}-dev = "ldflags"

INSANE_SKIP_${PN} = "ldflags"
