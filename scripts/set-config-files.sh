#!/bin/bash
#
# Simple script to set up the configuration files for the RZ/G AI BSP:
#   https://github.com/renesas-rz/meta-renesas-ai
# The script supports building for the following devices:
#   RZ/G2: hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874
#   RZ/G2L: smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul
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
		"smarc-rzg2l" | "smarc-rzg2lc" | "smarc-rzg2ul")
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

configure_machine () {
	echo "#################################################################"
	echo "Adding machine name in local.conf..."

	# Add machine name
	echo 'MACHINE = "'${PLATFORM}'"' >> ${BUILD_DIR}/conf/local.conf

	# Add SoC family for rzg2l
	if [ ${PLATFORM} == "smarc-rzg2l" ]; then
		echo 'SOC_FAMILY = "r9a07g044l"' >> ${BUILD_DIR}/conf/local.conf
	elif [ ${PLATFORM} == "smarc-rzg2lc" ]; then
		echo 'SOC_FAMILY = "r9a07g044c"' >> ${BUILD_DIR}/conf/local.conf
	elif [ ${PLATFORM} == "smarc-rzg2ul" ]; then
		echo 'SOC_FAMILY = "r9a07g043u"' >> ${BUILD_DIR}/conf/local.conf
	elif [ ${PLATFORM} == "hihope-rzg2h" ]; then
		echo 'SOC_FAMILY = "r8a774e1"' >> ${BUILD_DIR}/conf/local.conf
	elif [ ${PLATFORM} == "hihope-rzg2m" ]; then
		echo 'SOC_FAMILY = "r8a774a1"' >> ${BUILD_DIR}/conf/local.conf
	elif [ ${PLATFORM} == "hihope-rzg2n" ]; then
		echo 'SOC_FAMILY = "r8a774b1"' >> ${BUILD_DIR}/conf/local.conf
	elif [ ${PLATFORM} == "ek874" ]; then
		echo 'SOC_FAMILY = "r8a774c0"' >> ${BUILD_DIR}/conf/local.conf
	fi
}

configure_packages () {
	echo "#################################################################"
	echo "Adding AI packages to local.conf..."

	# Add AI packages to local.conf
	if [ ${FRAMEWORK} == "armnn" ]; then
		echo 'IMAGE_INSTALL_append = " armnn-dev armnn-examples armnn-tensorflow-lite-dev armnn-onnx-dev armnn-onnx-examples tensorflow-lite-python"' >> ${BUILD_DIR}/conf/local.conf

		# Enable TensorFlow Lite and ArmNN Benchmark
		if [ ${BENCHMARK} == "true" ]; then
			echo 'IMAGE_INSTALL_append = " tensorflow-lite-staticdev tensorflow-lite-dev tensorflow-lite-benchmark armnn-benchmark"' >> ${BUILD_DIR}/conf/local.conf

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

configure_machine
configure_packages

echo "#################################################################"
echo "Done!"
echo "#################################################################"
