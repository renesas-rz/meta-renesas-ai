# Recipe from:
# https://github.com/gpanders/meta-scipy/blob/master/recipes-devtools/python/python3-scipy_1.3.3.bb

SUMMARY = "SciPy: Scientific Library for Python"
HOMEPAGE = "https://www.scipy.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=be4a7946a904c1b639bcfe4da4f795b8"

SRC_URI = "https://files.pythonhosted.org/packages/62/4f/7e95c5000c411164d5ca6f55ac54cda5d200a3b6719dafd215ee0bd61578/scipy-1.2.3.tar.gz"

SRC_URI[md5sum] = "43b42a507472dfa1dff4c91d58a6543f"
SRC_URI[sha256sum] = "ecbe6413ca90b8e19f8475bfa303ac001e81b04ec600d17fa7f816271f7cca57"

S = "${WORKDIR}/scipy-${PV}"

DEPENDS = "python3-numpy python3-numpy-native lapack"
RDEPENDS_${PN} = "python3-numpy python3-multiprocessing lapack"

CLEANBROKEN = "1"

inherit setuptools3

export LAPACK = "${STAGING_LIBDIR}"
export BLAS = "${STAGING_LIBDIR}"

export F90 = "${TARGET_PREFIX}gfortran ${HOST_CC_ARCH}"
export F77 = "${TARGET_PREFIX}gfortran ${HOST_CC_ARCH}"

# Numpy expects the LDSHARED env variable to point to a single
# executable, but OE sets it to include some flags as well. So we split
# the existing LDSHARED variable into the base executable and flags, and
# prepend the flags into LDFLAGS
LDFLAGS_prepend := "${@" ".join(d.getVar('LDSHARED', True).split()[1:])} "
export LDSHARED := "${@d.getVar('LDSHARED', True).split()[0]}"

# Tell Numpy to look in target sysroot site-packages directory for libraries
LDFLAGS_append = " -L${STAGING_LIBDIR}/${PYTHON_DIR}/site-packages/numpy/core/lib"
