#!/bin/bash
#
# Simple script to build the RZ/G AI BSP: https://github.com/renesas-rz/meta-renesas-ai
# The script supports building for the following devices:
#   RZ/G2: hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874
#   RZ/G2L: smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul
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
FRAMEWORK="armnn"
BENCHMARK=false
PROP_DIR=""
PROP_LIBS_EXTRACTED=false
BUILD=true
OUTPUT_DIR="${WORK_DIR}/output"
FAMILY=""
SKIP_LICENSE_WARNING=false

################################################################################
# Helpers

print_help () {
        cat<<-EOF

	 This script will build the RZ/G AI BSP for the specified platform.
	 It will install all dependencies and download all source code,
	 apart from the proprietary libraries.

	 USAGE: ${COMMAND_NAME} -p <platform> -l <prop lib dir> \\
	                    [-b] [-c] [-d] [-e] [-f <framework>] \\
	                    [-o <output dir>] [-s] [-h]

	 OPTIONS:
	 -h                 Print this help and exit.
	 -b		    Enable benchmarking.
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
	 -l <prop lib dir>  Location when proprietary libraries have been
	                    downloaded to. This is not needed for smarc-rzg2ul.
	 -o <output dir>    Location to copy binaries to when build is complete.
	                    By default ${OUTPUT_DIR} will be used.
	 -p <platform>      Platform to build for. Choose from:
	                    hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874,
	                    smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul.
	 -s                 Skip the license warning prompt and automatically
	                    include the packages in LICENSE_FLAGS_WHITELIST.

	EOF
}

################################################################################
# Options parsing

while getopts ":bcdef:l:o:p:sh" opt; do
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
        l)
		# Ignore the prop lib directory for RZ/G2UL
		if [ ${PLATFORM} == "smarc-rzg2ul" ]; then
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
			FAMILY="rzg2"
        	        ;;

		"smarc-rzg2l" | "smarc-rzg2lc" | "smarc-rzg2ul")
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
	s)
		SKIP_LICENSE_WARNING=true
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

		cd poky; git cherry-pick 0810ac6b92; cd -

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
			dunfell-23.0.13

		cd poky; git cherry-pick e256885889

		# We need to cherry-pick the following commit to prevent SDK basehash issue
		git cherry-pick cfd897e213d; cd -

		update_git_repo \
			meta-openembedded \
			git://git.openembedded.org/meta-openembedded \
			ab9fca485e13f6f2f9761e1d2810f87c2e4f060a

		update_git_repo \
			meta-gplv2 \
			https://git.yoctoproject.org/meta-gplv2 \
			60b251c25ba87e946a0ca4cdc8d17b1cb09292ac

		update_git_repo \
			meta-qt5 \
			https://github.com/meta-qt5/meta-qt5.git \
			c1b0c9f546289b1592d7a895640de103723a0305

		update_git_repo \
			meta-virtualization \
			https://git.yoctoproject.org/git/meta-virtualization \
			9e9868ef3d6e5da7f0ecd0680fcd69324593842b

		update_git_repo \
			meta-rzg2 \
			https://github.com/renesas-rz/meta-rzg2.git \
			${RZG_BSP_VER}

		update_git_repo \
			meta-renesas-ai \
			https://github.com/renesas-rz/meta-renesas-ai.git \
			${RZG_AI_BSP_VER}
	fi
}

install_prop_libs () {
	echo "#################################################################"
	echo "Installing proprietary libraries..."

	if [ ${FAMILY} == "rzg2" ]; then
		if ! $PROP_LIBS_EXTRACTED; then
			pushd ${PROP_DIR}
			tar -zxf RZG2_Group_*_Software_Package_for_Linux_*.tar.gz
			PROP_DIR=${PROP_DIR}/proprietary
			popd
		fi

		pushd ${WORK_DIR}/meta-rzg2
		sh docs/sample/copyscript/copy_proprietary_softwares.sh \
			-f ${PROP_DIR}
		popd
	elif [ ${PLATFORM} == "smarc-rzg2l" ]; then
		if $PROP_LIBS_EXTRACTED; then
			rm -rf ${WORK_DIR}/meta-rz-features
			cp -r ${PROP_DIR} ${WORK_DIR}/meta-rz-features
		else
			pushd ${PROP_DIR}
			unzip RTK0EF0045Z13001ZJ-v0.81_EN.zip
			tar -xf RTK0EF0045Z13001ZJ-v0.81_EN/meta-rz-features.tar.gz -C ${WORK_DIR}

			unzip RTK0EF0045Z15001ZJ-v0.55_EN.zip
			tar -xf RTK0EF0045Z15001ZJ-v0.55_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
			popd
		fi
	elif [ ${PLATFORM} == "smarc-rzg2lc" ]; then
		if $PROP_LIBS_EXTRACTED; then
			rm -rf ${WORK_DIR}/meta-rz-features
			cp -r ${PROP_DIR} ${WORK_DIR}/meta-rz-features
		else
			pushd ${PROP_DIR}
			unzip RTK0EF0045Z13001ZJ-v0.81_EN.zip
			tar -xf RTK0EF0045Z13001ZJ-v0.81_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
			popd
		fi
	fi
}

configure_build () {
	echo "#################################################################"
	echo "Configuring build..."

	# This will create and take us to the $WORK_DIR/build directory
	source poky/oe-init-build-env

	cp $WORK_DIR/meta-renesas-ai/templates/${FAMILY}/*.conf ./conf/

	# Set configuration files
	if [ ${BENCHMARK} == "true" ]; then
		$WORK_DIR/meta-renesas-ai/scripts/set-config-files.sh -d ${WORK_DIR} -f ${FRAMEWORK} -b -p ${PLATFORM}
	else
		$WORK_DIR/meta-renesas-ai/scripts/set-config-files.sh -d ${WORK_DIR} -f ${FRAMEWORK} -p ${PLATFORM}
	fi

	if $SKIP_LICENSE_WARNING; then
		sed -i 's/#LICENSE_FLAGS_WHITELIST/LICENSE_FLAGS_WHITELIST/g' ./conf/local.conf
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

case ${RZG_AI_BSP_VER} in
*)
	if [ ${FAMILY} == "rzg2" ]; then
		RZG_BSP_VER="BSP-1.0.10-update1"
	elif [ ${FAMILY} == "rzg2l" ]; then
		RZG_BSP_VER="rzg2l_bsp_v1.4"
	fi
	;;
esac


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

if [ ${PLATFORM} != "smarc-rzg2ul"  ]; then
	install_prop_libs
fi
configure_build

if $BUILD; then
	if $SKIP_LICENSE_WARNING; then
		do_build
		copy_output
	else
		echo -ne "\nHave licensing options been updated in the local.conf file? "; read
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			do_build
			copy_output
		else
			echo "Please uncomment the LICENSE_FLAGS_WHITELIST to build the BSP"
		fi
	fi
fi

echo "#################################################################"
echo "Done!"
echo "#################################################################"
