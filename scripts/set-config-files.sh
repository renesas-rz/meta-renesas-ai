#!/bin/bash
#
# Simple script to set up the configuration files for the RZ/G AI BSP:
#   https://github.com/renesas-rz/meta-renesas-ai
# The script supports building for the following devices:
#   RZ/G2: hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874
#   RZ/G2L: smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul
#   RZ/V2L: smarc-rzv2l
#
# This script has been tested on Ubuntu 18.04, Ubuntu 20.04.
#
# SPDX-License-Identifier: MIT
# Copyright (C) 2022 Renesas Electronics Corp.

set -e

################################################################################
# Global parameters
WORK_DIR="${PWD}"
BUILD_DIR="${PWD}/build"
COMMAND_NAME="$0"
PLATFORM=""
FRAMEWORK="armnn"
BENCHMARK=false

################################################################################
# Helpers

print_help () {
	cat<<-EOF

 	This script will set up the configuration files for the specified
 	platform and add the necessary dependencies based on the
 	framework chosen. This is intended to be run after the yocto environment
 	has been sourced and the configuration templates from meta-renesas-ai
 	have been copied to the build/conf directory.

 	USAGE: ${COMMAND_NAME} -p <platform>
 			[-b] [-f <framework>] [-d <directory>] [-h]

 	OPTIONS:
 	-h		Print this help and exit.
 	-d <directory>	Set work directory.
 			Default: ${WORK_DIR}
 	-f <framework>	Select which AI framework to include in the
 			filesystem.
 			Choose from:
 				armnn (default)
 				onnxruntime
 				tensorflow-lite
 	-b 		Enable benchmarking.
 	-p <platform>	Platform to build for.
 			Choose from:
 				hihope-rzg2h
 				hihope-rzg2m
 				hihope-rzg2n
 				ek874
 				smarc-rzg2l
 				smarc-rzg2lc
 				smarc-rzg2ul
 				smarc-rzv2l

	EOF
}

################################################################################
# Options parsing

while getopts ":d:f:bp:h" opt; do
	case $opt in
	d)
		if [ ! -d "${OPTARG}" ]; then
			echo " ERROR: -d \"${OPTARG}\" No such directory"
			print_help
			exit 1
		fi
		WORK_DIR="${OPTARG}"
		BUILD_DIR="${WORK_DIR}/build"
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
	b)
		BENCHMARK=true
		;;
	p)
		case "${OPTARG}" in
		"hihope-rzg2h" | "hihope-rzg2m" | "hihope-rzg2n" | "ek874" | \
		"smarc-rzg2l" | "smarc-rzg2lc" | "smarc-rzg2ul" | "smarc-rzv2l")
			PLATFORM="${OPTARG}"
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
		exit 0
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

################################################################################
# Functions

configure_layers () {
	echo "#################################################################"
	echo "Adding bitbake layers"

	# Add GFX/MMP layers where appropriate
	if [ ${PLATFORM} != "smarc-rzg2ul" ]; then
		if [ ${PLATFORM} != "smarc-rzg2lc" ]; then
			bitbake-layers add-layer ${WORK_DIR}/meta-rz-features/meta-rz-codecs
		fi
		bitbake-layers add-layer ${WORK_DIR}/meta-rz-features/meta-rz-graphics
	fi

	bitbake-layers add-layer ${WORK_DIR}/meta-qt5

	# Add AI BSP layer
	bitbake-layers add-layer ${WORK_DIR}/meta-renesas-ai
}

configure_packages () {
	echo "#################################################################"
	echo "Adding AI packages to local.conf..."

	# Disable CIP Core
	sed -i 's/CIP_MODE = "Buster"/CIP_MODE = "None"/g' ${BUILD_DIR}/conf/local.conf

	# Add AI packages to local.conf
	if [ ${FRAMEWORK} == "armnn" ]; then
		echo 'IMAGE_INSTALL_append = " armnn-dev armnn-examples armnn-tensorflow-lite-dev armnn-onnx-dev armnn-onnx-examples tensorflow-lite-python"' >> ${BUILD_DIR}/conf/local.conf

		# Enable TensorFlow Lite and ArmNN Benchmark
		if [ ${BENCHMARK} == "true" ]; then
			echo 'IMAGE_INSTALL_append = " tensorflow-lite-staticdev tensorflow-lite-dev armnn-benchmark"' >> ${BUILD_DIR}/conf/local.conf

			# Enable TensorFlow Lite Delegate benchmark
			echo 'IMAGE_INSTALL_append = " tensorflow-lite-delegate-benchmark"' >> ${BUILD_DIR}/conf/local.conf
		fi
	elif [ ${FRAMEWORK} == "onnxruntime" ]; then
		echo 'IMAGE_INSTALL_append = " onnxruntime"' >> ${BUILD_DIR}/conf/local.conf

		# Enable ONNX Runtime benchmark
		if [ ${BENCHMARK} == "true" ]; then
			echo 'IMAGE_INSTALL_append = " onnxruntime-benchmark"' >> ${BUILD_DIR}/conf/local.conf
		fi
	elif [ ${FRAMEWORK} == "tensorflow-lite" ]; then
		echo 'IMAGE_INSTALL_append = " tensorflow-lite-staticdev tensorflow-lite-dev tensorflow-lite-python"' >> ${BUILD_DIR}/conf/local.conf

		# Enable TensorFlow Lite benchmark
		if [ ${BENCHMARK} == "true" ]; then
			echo 'IMAGE_INSTALL_append = " tensorflow-lite-benchmark"' >> ${BUILD_DIR}/conf/local.conf
		fi
	fi

	# Add test scripts
	if [ ${BENCHMARK} == "true" ]; then
		echo 'IMAGE_INSTALL_append = " ai-tests"' >> ${BUILD_DIR}/conf/local.conf
	fi
}

################################################################################
# Main

echo "#################################################################"
echo "Work Directory: ${WORK_DIR}"
echo "Build Directory: ${BUILD_DIR}"
echo "Platform: ${PLATFORM}"
echo "AI Framework: ${FRAMEWORK}"
echo "Benchmark: ${BENCHMARK}"

# Set TensorFlow Lite version to v2.5.3 for ArmNN, since ArmNN v22.02
# requires TensorFlow Lite r2.5 and is not compatible with v2.15.1
if [ ${FRAMEWORK} == "armnn" ]; then
	sed -i 's/PREFERRED_VERSION_tensorflow-lite ?= "2.15.1"/PREFERRED_VERSION_tensorflow-lite ?= "2.5.3"/g' ${WORK_DIR}/meta-renesas-ai/conf/layer.conf
fi

configure_layers
configure_packages

echo "#################################################################"
echo "Done!"
echo "#################################################################"
