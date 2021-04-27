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

LIC_FILES_CHKSUM = "file://LICENSE;md5=9598101cf48c5f479cfda9f3fc6fc566"

# Tag v21.02
SRCREV = "7dcb9fadb98cad05fca72de3273311d570d98b4e"

SRC_URI = " \
	git://github.com/ARM-software/ComputeLibrary.git \
	file://0001-Add-support-for-building-arm-and-aarch64-CL-with-Sco.patch \
"

COMPATIBLE_MACHINE = "(iwg20m-g1m|iwg21m|iwg22m|hihope-rzg2h|hihope-rzg2m|hihope-rzg2n|ek874)"

S = "${WORKDIR}/git"

PR = "r0"

inherit scons

OESCONS_COMMON_FLAG = " extra_cxx_flags="${TOOLCHAIN_OPTIONS}" benchmark_tests=1 \
			validation_tests=0 neon=1 openmp=1 opencl=0 set_soname=1"

EXTRA_OESCONS_arm = "arch=armv7a${OESCONS_COMMON_FLAG}"
EXTRA_OESCONS_aarch64 = "arch=arm64-v8a${OESCONS_COMMON_FLAG}"

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

FILES_${PN} = "${libdir}/libarm_compute_core.so.22.0.0 \
               ${libdir}/libarm_compute_graph.so.22.0.0 \
               ${libdir}/libarm_compute.so.22.0.0 \
"

#Symlink .so files should go into the -dev package
FILES_${PN}-dev = "${datadir}/arm-compute-library \
                   ${libdir}/libarm_compute_graph.so.22 \
                   ${libdir}/libarm_compute.so.22 \
                   ${libdir}/libarm_compute.so \
                   ${libdir}/libarm_compute_core.so.22 \
                   ${libdir}/libarm_compute_core.so \
                   ${libdir}/libarm_compute_graph.so \
"

FILES_${PN}-dbg = "${libdir}/.debug"

FILES_${PN}-staticdev = "${libdir}/*.a"

INSANE_SKIP_${PN}-dev = "ldflags"

INSANE_SKIP_${PN} = "ldflags"