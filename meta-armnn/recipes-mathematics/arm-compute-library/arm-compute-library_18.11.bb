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

LIC_FILES_CHKSUM = "file://LICENSE;md5=762a7ba8d2ddc3b38d88742fbaf0b62d"

SRCREV = "b9abeae0897bef74553ba9800c4ff5f74131c5b4"

SRC_URI = " \
	git://github.com/ARM-software/ComputeLibrary.git \
	file://0001-Adding-support-for-building-Arm-CL-with-Scons.patch \
"

COMPATIBLE_MACHINE = "(iwg20m|iwg21m|iwg22m)"

S = "${WORKDIR}/git"

PR = "r0"

inherit scons

EXTRA_OESCONS = "arch=armv7a extra_cxx_flags="${TOOLCHAIN_OPTIONS}" benchmark_tests=1 \
		 validation_tests=0 neon=1 openmp=1 opencl=0 set_soname=1"

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

FILES_${PN} = "${libdir}/libarm_compute_core.so.13.0.0 \
               ${libdir}/libarm_compute_graph.so.13.0.0 \
               ${libdir}/libarm_compute.so.13.0.0 \
"

#Symlink .so files should go into the -dev package
FILES_${PN}-dev = "${datadir}/arm-compute-library \
                   ${libdir}/libarm_compute_graph.so.13 \
                   ${libdir}/libarm_compute.so.13 \
                   ${libdir}/libarm_compute.so \
                   ${libdir}/libarm_compute_core.so.13 \
                   ${libdir}/libarm_compute_core.so \
                   ${libdir}/libarm_compute_graph.so \
"

FILES_${PN}-dbg = "${libdir}/.debug"

FILES_${PN}-staticdev = "${libdir}/*.a"

INSANE_SKIP_${PN}-dev = "ldflags"

INSANE_SKIP_${PN} = "ldflags"
