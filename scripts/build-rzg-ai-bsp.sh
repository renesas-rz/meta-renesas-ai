#!/bin/bash
#
# Simple script to build the RZ/G AI BSP: https://github.com/renesas-rz/meta-renesas-ai
# The script supports building for the following devices:
#   RZ/G2: hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874
#   RZ/G2L: smarc-rzg2l, smarc-rzg2lc
#
# This script has been tested on Ubuntu 18.04.
#
# SPDX-License-Identifier: MIT
# Copyright (C) 2020 Renesas Electronics Corp.

set -e

################################################################################
# Global parameters
RZG_AI_BSP_VER="master"
WORK_DIR="${PWD}"
COMMAND_NAME="$0"
INSTALL_DEPENDENCIES=false
PLATFORM=""
FRAMEWORK="benchmark-armnn+tfl"
BENCHMARK=true
PROP_DIR=""
BUILD=true
OUTPUT_DIR="${WORK_DIR}/output"
FAMILY=""

################################################################################
# Helpers

print_help () {
        cat<<-EOF

	 This script will build the RZ/G AI BSP for the specified platform.
	 It will install all dependencies and download all source code,
	 apart from the proprietary libraries.

	 USAGE: ${COMMAND_NAME} -p <platform> -l <prop lib dir> \\
	                    [-c] [-d] [-f <framework>] [-o <output dir>] [-h]

	 OPTIONS:
	 -h                 Print this help and exit.
	 -c                 Only perform checkout, proprietary library
	                    extraction and configuration. Don't start the build.
	 -d                 Install OS dependencies before starting build.
	 -f <framework>     Select which AI framework to include in the
	                    filesystem.
	                    Choose from:
	                    benchmark-armnn+tfl, benchmark-onnx,
	                    benchmark-tflite, armnn, onnxruntime or
	                    tensorflow-lite.
	                    By default ${FRAMEWORK} will be used.
	 -l <prop lib dir>  Location when proprietary libraries have been
	                    downloaded to.
	 -o <output dir>    Location to copy binaries to when build is complete.
	                    By default ${OUTPUT_DIR} will be used.
	 -p <platform>      Platform to build for. Choose from:
	                    hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874,
	                    smarc-rzg2l, smarc-rzg2lc.

	EOF
}

################################################################################
# Options parsing

while getopts ":cdf:l:o:p:h" opt; do
        case $opt in
	c)	BUILD=false
		;;
        d)
		INSTALL_DEPENDENCIES=true
                ;;
        f)
		case "${OPTARG}" in
		"armnn" | "onnxruntime" | "tensorflow-lite" | \
		"benchmark-armnn+tfl" | "benchmark-onnx" | "benchmark-tflite")
			FRAMEWORK="${OPTARG}"
			;;

		*)
			echo " ERROR: -f \"${OPTARG}\" Not supported"
			print_help
			exit 1
			;;
		esac
		;;
        l)
                if [ ! -d "${OPTARG}" ]; then
                        echo " ERROR: -l \"${OPTARG}\" No such directory"
                        print_help
                        exit 1
                fi
                PROP_DIR="$(realpath "${OPTARG}")"
                ;;
        o)
                if [ ! -d "${OPTARG}" ]; then
                        echo " ERROR: -l \"${OPTARG}\" No such directory"
                        print_help
                        exit 1
                fi
                OUTPUT_DIR="$(realpath "${OPTARG}")"
                ;;
        p)
		case "${OPTARG}" in
		"hihope-rzg2h" | "hihope-rzg2m" | "hihope-rzg2n" | "ek874")
			PLATFORM="${OPTARG}"
			FAMILY="rzg2"
        	        ;;

		"smarc-rzg2l" | "smarc-rzg2lc")
			PLATFORM="${OPTARG}"
			FAMILY="rzg2l"
			;;
		*)
			echo " ERROR: -p \"${OPTARG}\" Not supported"
			print_help
			exit 1
			;;
		esac
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
	echo " ERROR: Proprietary library directory (-l) must be set"
	print_help
	exit 1
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

	$beroot apt install -y gawk wget git-core diffstat unzip texinfo \
		gcc-multilib build-essential chrpath socat cpio python python3 \
		python3-pip python3-pexpect xz-utils debianutils iputils-ping \
		libsdl1.2-dev xterm p7zip-full
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
	# Update from remote repo
	git fetch origin

	# Switch to a local branch
	git checkout HEAD^
	git branch -f tmp $3
	git checkout tmp

	popd
}

download_source () {
	echo "#################################################################"
	echo "Downloading source..."

	if [ ${FAMILY} == "rzg2" ]; then
		update_git_repo \
			poky \
			git://git.yoctoproject.org/poky \
			7e7ee662f5dea4d090293045f7498093322802cc

		update_git_repo \
			meta-linaro \
			git://git.linaro.org/openembedded/meta-linaro.git \
			75dfb67bbb14a70cd47afda9726e2e1c76731885

		update_git_repo \
			meta-openembedded \
			git://git.openembedded.org/meta-openembedded \
			352531015014d1957d6444d114f4451e241c4d23

		update_git_repo \
			meta-gplv2 \
			https://git.yoctoproject.org/meta-gplv2 \
			f875c60ecd6f30793b80a431a2423c4b98e51548

		update_git_repo \
			meta-qt5 \
			https://github.com/meta-qt5/meta-qt5.git \
			c1b0c9f546289b1592d7a895640de103723a0305

		update_git_repo \
			meta-rzg2 \
			https://github.com/renesas-rz/meta-rzg2.git \
			${RZG_BSP_VER}

		update_git_repo \
			meta-renesas-ai \
			https://github.com/renesas-rz/meta-renesas-ai.git \
			${RZG_AI_BSP_VER}
	elif [ ${FAMILY} == "rzg2l" ]; then
		update_git_repo \
			poky \
			git://git.yoctoproject.org/poky \
			e32d854e33bc86c2a616df8708e021a098afcf73

		cd poky; git cherry-pick 9e444; cd -

		update_git_repo \
			meta-openembedded \
			git://git.openembedded.org/meta-openembedded \
			cc6fc6b1641ab23089c1e3bba11e0c6394f0867c

		update_git_repo \
			meta-gplv2 \
			https://git.yoctoproject.org/meta-gplv2 \
			60b251c25ba87e946a0ca4cdc8d17b1cb09292ac

		update_git_repo \
			meta-qt5 \
			https://github.com/meta-qt5/meta-qt5.git \
			c1b0c9f546289b1592d7a895640de103723a0305

		update_git_repo \
			meta-rzg2 \
			https://github.com/renesas-rz/meta-rzg2.git \
			${RZG_BSP_VER}

		update_git_repo \
			meta-renesas-ai \
			https://github.com/renesas-rz/meta-renesas-ai.git \
			${RZG_AI_BSP_VER}

		cd meta-rzg2; git am ../meta-renesas-ai/patches/meta-rzg2/dunfell-rzg2l/0001-Enable-RZ-G2L-Qt-SDK-builds.patch; cd -
	fi
}

install_prop_libs () {
	echo "#################################################################"
	echo "Installing proprietary libraries..."

	if [ ${FAMILY} == "rzg2" ]; then
		pushd ${PROP_DIR}
		tar -zxf RZG2_Group_*_Software_Package_for_Linux_*.tar.gz
		popd

		PROP_DIR=${PROP_DIR}/proprietary

		pushd ${WORK_DIR}/meta-rzg2
		sh docs/sample/copyscript/copy_proprietary_softwares.sh \
			-f ${PROP_DIR}
		popd
	elif [ ${FAMILY} == "rzg2l" ]; then
		pushd ${PROP_DIR}
		unzip RTK0EF0045Z13001ZJ-v0.8_EN.zip
		tar -xf RTK0EF0045Z13001ZJ-v0.8_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
		unzip RTK0EF0045Z15001ZJ-v0.51_EN.zip
		tar -xf RTK0EF0045Z15001ZJ-v0.51_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
		popd
	fi
}

configure_build () {
	echo "#################################################################"
	echo "Configuring build..."

	# This will create and take us to the $WORK_DIR/build directory
	source poky/oe-init-build-env

	# Remove benchmark from framework name
	case "${FRAMEWORK}" in
		"armnn" | "onnxruntime" | "tensorflow-lite")
			BENCHMARK=false
			;;

		"benchmark-armnn+tfl")
			FRAMEWORK="armnn+tfl"
			BENCHMARK=true
			;;

		"benchmark-onnx")
			FRAMEWORK="onnx"
			BENCHMARK=true
			;;

		"benchmark-tflite")
			FRAMEWORK="tflite"
			BENCHMARK=true
			;;
	esac

	if ${BENCHMARK}; then
		cp $WORK_DIR/meta-renesas-ai/meta-benchmark/templates/${FRAMEWORK}/${PLATFORM}/*.conf ./conf/
	else
		cp $WORK_DIR/meta-renesas-ai/meta-${FRAMEWORK}/templates/${PLATFORM}/*.conf ./conf/
	fi
}

do_build () {
	echo "#################################################################"
	echo "Starting build..."

	if [ ${FAMILY} == "rzg2" ]; then
		bitbake core-image-qt
	elif [ ${FAMILY} == "rzg2l" ]; then
		bitbake core-image-qt
	fi
}

copy_output () {
	echo "#################################################################"
	echo "Copying output..."

	local bin_dir=$WORK_DIR/build/tmp/deploy/images/${PLATFORM}
	mkdir -p ${OUTPUT_DIR}/${PLATFORM}

	if [ ${FAMILY} == "rzg2" ]; then
		cp ${bin_dir}/core-image-*-${PLATFORM}.tar.gz ${OUTPUT_DIR}/${PLATFORM}
		cp ${bin_dir}/Image-${PLATFORM}.bin ${OUTPUT_DIR}/${PLATFORM}
		cp ${bin_dir}/Image-*-${PLATFORM}*.dtb ${OUTPUT_DIR}/${PLATFORM}
	elif [ ${FAMILY} == "rzg2l" ]; then
		cp ${bin_dir}/core-image-*-${PLATFORM}.tar.gz ${OUTPUT_DIR}/${PLATFORM}
		cp ${bin_dir}/Image-${PLATFORM}.bin ${OUTPUT_DIR}/${PLATFORM}
		cp ${bin_dir}/*smarc*.dtb ${OUTPUT_DIR}/${PLATFORM}
	fi
}

################################################################################
# Main

clear

case ${RZG_AI_BSP_VER} in
*)
	if [ ${FAMILY} == "rzg2" ]; then
		RZG_BSP_VER="BSP-1.0.10-update1"
	elif [ ${FAMILY} == "rzg2l" ]; then
		RZG_BSP_VER="rzg2l_bsp_v1.3-update1"
	fi
	;;
esac


echo "#################################################################"
echo "RZ/G AI BSP version: ${RZG_AI_BSP_VER}"
echo "RZ/G BSP version: ${RZG_BSP_VER}"
echo "Working Directory: ${WORK_DIR}"
echo "Platform: ${PLATFORM}"
echo "AI Framework: ${FRAMEWORK}"
echo "Proprietary Library Directory: ${PROP_DIR}"
echo "Output Directory: ${OUTPUT_DIR}"

if $INSTALL_DEPENDENCIES; then
	install_dependencies
fi
download_source
install_prop_libs
configure_build

if $BUILD; then
	echo -ne "\nHave licensing options been updated in the local.conf file? "; read
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		do_build
		copy_output
	else
		echo "Please uncomment the LICENSE_FLAGS_WHITELIST to build the BSP"
	fi
fi

echo "#################################################################"
echo "Done!"
echo "#################################################################"
