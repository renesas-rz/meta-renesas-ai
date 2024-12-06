#!/bin/bash
#
# Simple script to build the RZ/G AI BSP: https://github.com/renesas-rz/meta-renesas-ai
# The script supports building for the following devices:
#   RZ/G2: hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874
#   RZ/G2L: smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul
#   RZ/V2L: smarc-rzv2l
#
# This script has been tested on Ubuntu 20.04.
#
# SPDX-License-Identifier: MIT
# Copyright (C) 2022 Renesas Electronics Corp.

set -e

################################################################################
# Global parameters
RZG_AI_BSP_URL="${CI_REPOSITORY_URL:-https://github.com/renesas-rz/meta-renesas-ai.git}"
RZG_AI_BSP_VER="${CI_COMMIT_REF_NAME:-master}"
RZG_BSP_VER="BSP-3.0.6-update3"
WORK_DIR="${PWD}"
COMMAND_NAME="$0"
INSTALL_DEPENDENCIES=false
PLATFORM=""
FRAMEWORK="armnn"
BENCHMARK=false
PROP_DIR=""
PROP_LIBS_EXTRACTED=false
BUILD=true
OUTPUT_DIR="${WORK_DIR}/output"
FAMILY=""
BUILD_SDK=false
YOCTO_DL_DIR=""
YOCTO_SSTATE_DIR=""
THREADS=$(nproc)

################################################################################
# Helpers

print_help () {
        cat<<-EOF

	 This script will build the RZ/G AI BSP for the specified platform.
	 It will install all dependencies and download all source code,
	 apart from the proprietary libraries.

	 USAGE: ${COMMAND_NAME} -p <platform> -l <prop lib dir> [-b] [-c] \\
	                    [-d] [-e] [-f <framework>] [-j <dir>] [-k <dir>] \\
	                    [-n <threads>] [-o <output dir>] [-t] [-T] [-h]

	 OPTIONS:
	 -h                 Print this help and exit.
	 -b                 Enable benchmarking.
	 -c                 Only perform checkout, proprietary library
	                    extraction and configuration. Don't start the build.
	 -d                 Install OS dependencies before starting build.
	 -e                 Marks that proprietary libraries have already been
	                    extracted to the directory specified by -l.
	                    For the RZ/G2L BSP the directory should contain the
	                    contents of the meta-rz-features layer.
	 -f <framework>     Select which AI framework to include in the
	                    filesystem.
	                    Choose from:
                                armnn (default)
                                onnxruntime
                                tensorflow-lite
	 -j <dir>           Set directory to use for the Yocto DL_DIR variable.
	 -k <dir>           Set directory to use for the Yocto SSTATE_DIR
	                    variable.
	 -l <prop lib dir>  Location when proprietary libraries have been
	                    downloaded to. This is not needed for smarc-rzg2ul.
	 -n <threads>       Number of threads to be used for the build. This
	                    will be set for PARALLEL_MAKE and BB_NUMBER_THREADS.
	                    By default these settings will be set to the number
	                    of CPU cores on the build host (nproc).
	 -o <output dir>    Location to copy binaries to when build is complete.
	                    By default ${OUTPUT_DIR} will be used.
	 -p <platform>      Platform to build for. Choose from:
	                    hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874,
	                    smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul,
	                    smarc-rzv2l.
	 -t                 Build toolchain/SDK once main build has completed.
	 -T                 Only build toolchain/SDK.

	EOF
}

################################################################################
# Options parsing

while getopts ":bcdef:j:k:l:n:o:p:tTh" opt; do
	case $opt in
	b)
		BENCHMARK=true
		;;
	c)	BUILD=false
		;;
	d)
		INSTALL_DEPENDENCIES=true
		;;
	e)
		PROP_LIBS_EXTRACTED=true
		;;
	f)
		case "${OPTARG}" in
			"armnn" | "onnxruntime" | "tensorflow-lite")
			FRAMEWORK="${OPTARG}"
			;;

		*)
			echo " ERROR: -f \"${OPTARG}\" Not supported"
			print_help
			exit 1
			;;
		esac
		;;
	j)
		YOCTO_DL_DIR="${OPTARG}"
		;;
	k)
		YOCTO_SSTATE_DIR="${OPTARG}"
		;;
	l)
		# Ignore the prop lib directory for RZ/G2UL
		if [ "${PLATFORM}" == "smarc-rzg2ul" ]; then
			echo " WARNING: No prop libs required for smarc-rzg2ul"
			echo " Continuing build..."
		else
			if [ ! -d "${OPTARG}" ]; then
				echo " ERROR: -l \"${OPTARG}\" No such directory"
				print_help
				exit 1
			fi
			PROP_DIR="$(realpath "${OPTARG}")"
		fi
		;;
	n)
		THREADS="${OPTARG}"
		;;
	o)
		if [ ! -d "${OPTARG}" ]; then
			echo " ERROR: -o \"${OPTARG}\" No such directory"
			print_help
			exit 1
		fi
		OUTPUT_DIR="$(realpath "${OPTARG}")"
		;;
	p)
		case "${OPTARG}" in
		"hihope-rzg2h" | "hihope-rzg2m" | "hihope-rzg2n" | "ek874")
			PLATFORM="${OPTARG}"
			FAMILY="rzg2h"
			;;

		"smarc-rzg2l" | "smarc-rzg2lc" | "smarc-rzg2ul")
			PLATFORM="${OPTARG}"
			FAMILY="rzg2l"
			;;
		"smarc-rzv2l")
			PLATFORM="${OPTARG}"
			FAMILY="rzv2l"
			;;
		*)
			echo " ERROR: -p \"${OPTARG}\" Not supported"
			print_help
			exit 1
			;;
		esac
		;;
	t)
		BUILD_SDK=true
		;;
	T)
		BUILD_SDK="only"
		;;
	h)
		print_help
		exit 1
		;;
	\?)
		echo " ERROR: Invalid option: -$OPTARG"
		print_help
		exit 1
		;;
	:)
		echo " ERROR: Option -$OPTARG requires an argument"
		print_help
		exit 1
		;;
	esac
done

if [ -z "$PLATFORM" ]; then
	echo " ERROR: Platform (-p) must be set"
	print_help
	exit 1
fi

if [ -z "$PROP_DIR" ]; then
	if [ ${PLATFORM} != "smarc-rzg2ul" ]; then
		echo " ERROR: Proprietary library directory (-l) must be set"
		print_help
		exit 1
	fi
fi

################################################################################
# Functions

install_dependencies () {
	echo "#################################################################"
	echo "Installing dependencies..."

	local beroot=""
	if [ $(id -u) -ne 0 ];then
		beroot="sudo"
	fi

	$beroot apt update
	$beroot apt install -y gawk wget git-core diffstat unzip texinfo \
		gcc-multilib build-essential chrpath socat cpio python3 \
		python3-pip python3-pexpect xz-utils debianutils iputils-ping \
		python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 \
		xterm python3-subunit mesa-common-dev
}

# $1 project/directory name
# $2 repo url
# $3 version
update_git_repo () {
	# Check if repo is already checked out
	if [ ! -d "$1" ]; then
		git clone $2 $1
	fi

	pushd ${WORK_DIR}/$1
	git fetch origin
	git checkout $3
	popd
}

download_source () {
	echo "#################################################################"
	echo "Downloading source..."

	update_git_repo \
		poky \
		git://git.yoctoproject.org/poky \
		a9e3cc3b9eab7a83c715bb8440454e8fea852c2a

	update_git_repo \
		meta-openembedded \
		git://git.openembedded.org/meta-openembedded \
		daa4619fe3fbf8c28f342c4a7163a84a330f7653

	update_git_repo \
		meta-gplv2 \
		https://git.yoctoproject.org/meta-gplv2 \
		60b251c25ba87e946a0ca4cdc8d17b1cb09292ac

	update_git_repo \
		meta-qt5 \
		https://github.com/meta-qt5/meta-qt5.git \
		c1b0c9f546289b1592d7a895640de103723a0305

	update_git_repo \
		meta-renesas \
		https://github.com/renesas-rz/meta-renesas.git \
		${RZG_BSP_VER}

	update_git_repo \
		meta-renesas-ai \
		${RZG_AI_BSP_URL} \
		${RZG_AI_BSP_VER}
}

patch_source () {
	while read CURRENT_DIR; do
	if [ -d ${WORK_DIR}/${CURRENT_DIR} ]; then
		pushd ${WORK_DIR}/${CURRENT_DIR}
		git am ${WORK_DIR}/meta-renesas-ai/patches/${CURRENT_DIR}/*
		popd
	fi
	done < <(find ${WORK_DIR}/meta-renesas-ai/patches/ -maxdepth 1 -mindepth 1 -type d -exec basename '{}' \;)
}

install_prop_libs () {
	echo "#################################################################"
	echo "Installing proprietary libraries..."

	if [ ${FAMILY} == "rzg2h" ]; then
		if $PROP_LIBS_EXTRACTED; then
			rm -rf ${WORK_DIR}/meta-rz-features
			cp -r ${PROP_DIR} ${WORK_DIR}/meta-rz-features
		else
			pushd ${PROP_DIR}
			unzip RTK0EF0045Z0022AZJ-v1.0.2_EN.zip
			tar -xf RTK0EF0045Z0022AZJ-v1.0.2_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
			popd
		fi
	elif [ ${PLATFORM} == "smarc-rzg2l" ] || [ ${PLATFORM} == "smarc-rzv2l" ]; then
		if $PROP_LIBS_EXTRACTED; then
			rm -rf ${WORK_DIR}/meta-rz-features
			cp -r ${PROP_DIR} ${WORK_DIR}/meta-rz-features
		else
			pushd ${PROP_DIR}
			unzip RTK0EF0045Z13001ZJ-v1.2.2_EN.zip
			tar -xf RTK0EF0045Z13001ZJ-v1.2.2_EN/meta-rz-features_graphics_v1.2.2.tar.gz -C ${WORK_DIR}

			unzip RTK0EF0045Z15001ZJ-v1.2.1_EN.zip
			tar -xf RTK0EF0045Z15001ZJ-v1.2.1_EN/meta-rz-features_codec_v1.2.1.tar.gz -C ${WORK_DIR}
			popd
		fi
	elif [ ${PLATFORM} == "smarc-rzg2lc" ]; then
		if $PROP_LIBS_EXTRACTED; then
			rm -rf ${WORK_DIR}/meta-rz-features
			cp -r ${PROP_DIR} ${WORK_DIR}/meta-rz-features
		else
			pushd ${PROP_DIR}
			unzip RTK0EF0045Z13001ZJ-v1.2.2_EN.zip
			tar -xf RTK0EF0045Z13001ZJ-v1.2.2_EN/meta-rz-features_graphics_v1.2.2.tar.gz -C ${WORK_DIR}
			popd
		fi
	fi
}

configure_build () {
	echo "#################################################################"
	echo "Configuring build..."

	# This will create and take us to the $WORK_DIR/build directory
	TEMPLATECONF=$WORK_DIR/meta-renesas/meta-${FAMILY}/docs/template/conf/ source poky/oe-init-build-env

	# Set configuration files
	if [ ${BENCHMARK} == "true" ]; then
		$WORK_DIR/meta-renesas-ai/scripts/set-config-files.sh -d ${WORK_DIR} -f ${FRAMEWORK} -b -p ${PLATFORM}
	else
		$WORK_DIR/meta-renesas-ai/scripts/set-config-files.sh -d ${WORK_DIR} -f ${FRAMEWORK} -p ${PLATFORM}
	fi

	if [ ! -z ${YOCTO_DL_DIR} ]; then
		echo "DL_DIR = \"${YOCTO_DL_DIR}\"" >> ./conf/local.conf
	fi

	if [ ! -z ${YOCTO_SSTATE_DIR} ]; then
		echo "SSTATE_DIR = \"${YOCTO_SSTATE_DIR}\"" >> ./conf/local.conf
	fi

	echo "BB_NUMBER_THREADS = \"${THREADS}\"" >> ./conf/local.conf
	echo "PARALLEL_MAKE = \"-j ${THREADS}\"" >> ./conf/local.conf
}

do_build () {
	echo "#################################################################"
	echo "Starting build..."
	MACHINE=${PLATFORM} bitbake core-image-qt
}

do_sdk_build () {
	echo "#################################################################"
	echo "Starting SDK build..."
	MACHINE=${PLATFORM} bitbake core-image-qt -c populate_sdk
}

copy_output () {
	echo "#################################################################"
	echo "Copying output..."

	local bin_dir=$WORK_DIR/build/tmp/deploy/images/${PLATFORM}
	mkdir -p ${OUTPUT_DIR}/${PLATFORM}

	if [ $BUILD_SDK != "only" ]; then
		cp ${bin_dir}/core-image-qt-${PLATFORM}.tar.gz ${OUTPUT_DIR}/${PLATFORM}
		cp ${bin_dir}/Image-${PLATFORM}.bin ${OUTPUT_DIR}/${PLATFORM}

		if [ ${FAMILY} == "rzg2h" ]; then
			cp ${bin_dir}/Image-*-${PLATFORM}*.dtb ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/u-boot-elf-${PLATFORM}.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/bootparam_sa0.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/bl2-${PLATFORM}.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/bl31-${PLATFORM}.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/cert_header_sa6.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/AArch64_Flash_writer_SCIF*.mot ${OUTPUT_DIR}/${PLATFORM}
		elif [ ${FAMILY} == "rzg2l" ] || [ ${FAMILY} == "rzv2l" ]; then
			cp ${bin_dir}/Image-*-smarc.dtb ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/bl2_bp-${PLATFORM}*.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/fip-${PLATFORM}*.srec ${OUTPUT_DIR}/${PLATFORM}
			cp ${bin_dir}/Flash_Writer_SCIF*.mot ${OUTPUT_DIR}/${PLATFORM}
		fi

		# Save license information
		pushd "${bin_dir}/../../" > /dev/null
		tar czf licenses-${PLATFORM}.tar.gz licenses
		cp licenses-${PLATFORM}.tar.gz ${OUTPUT_DIR}/${PLATFORM}
		popd > /dev/null
	fi

	if [ $BUILD_SDK != "false" ]; then
		cp $WORK_DIR/build/tmp/deploy/sdk/*.sh ${OUTPUT_DIR}/${PLATFORM}
	fi
}

################################################################################
# Main

echo "#################################################################"
echo "RZ/G AI BSP version: ${RZG_AI_BSP_VER}"
echo "RZ/G BSP version: ${RZG_BSP_VER}"
echo "Working Directory: ${WORK_DIR}"
echo "Platform: ${PLATFORM}"
echo "AI Framework: ${FRAMEWORK}"
echo "Benchmark: ${BENCHMARK}"

if [ ${PLATFORM} != "smarc-rzg2ul"  ]; then
	echo "Proprietary Library Directory: ${PROP_DIR}"
fi
echo "Output Directory: ${OUTPUT_DIR}"

if $INSTALL_DEPENDENCIES; then
	install_dependencies
fi
download_source
patch_source

if [ ${PLATFORM} != "smarc-rzg2ul"  ]; then
	install_prop_libs
fi
configure_build

if $BUILD; then
	if [ $BUILD_SDK == "true" ]; then
		do_build && do_sdk_build
	elif [ $BUILD_SDK == "only" ]; then
		do_sdk_build
	else
		do_build
	fi

	copy_output
fi

echo "#################################################################"
echo "Done!"
echo "#################################################################"
