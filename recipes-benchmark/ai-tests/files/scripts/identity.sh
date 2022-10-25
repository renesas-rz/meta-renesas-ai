#!/bin/bash

################################################################################
# SoC/Board identification strings
################################################################################

MODEL_STRING="$(cat /sys/firmware/devicetree/base/model | tr -d '\0' | tr -d '\t')"
if [ -n "${DEBUG}" ]; then
	echo "MODEL_STRING=\"${MODEL_STRING}\"" | print_debug
fi
case ${MODEL_STRING} in
	"iWave RainboW-G22D-SODIMM RZ/G1E based board with HDMI add-on")
		DAUGHTER_BOARD="hdmi"
		SOC="r8a7745"
		SOC_FULL="r8a77450"
		SOM="iwg22m"
		BOARD="iwg22d"
		RZG_GENERATION="1"
		RZG_VARIANT="e"
		RZG_NAME="RZ/G1E"
		RZG_LABEL="rzg1e"
		;;
	"iWave Systems RainboW-G22D-SODIMM board based on RZ/G1E")
		SOC="r8a7745"
		SOC_FULL="r8a77450"
		SOM="iwg22m"
		BOARD="iwg22d"
		RZG_GENERATION="1"
		RZG_VARIANT="e"
		RZG_NAME="RZ/G1E"
		RZG_LABEL="rzg1e"
		;;
	"iW-RainboW-G20D-Q7 RZ/G1M based plus camera daughter board")
		DAUGHTER_BOARD="camera"
		SOC="r8a7743"
		SOC_FULL="r8a77430"
		SOM="iwg20m"
		BOARD="iwg20d"
		RZG_GENERATION="1"
		RZG_VARIANT="m"
		RZG_NAME="RZ/G1M"
		RZG_LABEL="rzg1m"
		;;
	"iWave Systems RainboW-G20D-Qseven board based on RZ/G1M")
		SOC="r8a7743"
		SOC_FULL="r8a77430"
		SOM="iwg20m"
		BOARD="iwg20d"
		RZG_GENERATION="1"
		RZG_VARIANT="m"
		RZG_NAME="RZ/G1M"
		RZG_LABEL="rzg1m"
		;;
	"iWave Systems RZ/G1N Qseven development platform with camera add-on")
		DAUGHTER_BOARD="camera"
		SOC="r8a7744"
		SOC_FULL="r8a77440"
		SOM="iwg20m"
		BOARD="iwg20d"
		RZG_GENERATION="1"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G1N"
		RZG_LABEL="rzg1n"
		;;
	"iWave Systems RainboW-G20D-Qseven board based on RZ/G1N")
		SOC="r8a7744"
		SOC_FULL="r8a77440"
		SOM="iwg20m"
		BOARD="iwg20d"
		RZG_GENERATION="1"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G1N"
		RZG_LABEL="rzg1n"
		;;
	"iWave iW-RainboW-G23S single board computer based on RZ/G1C")
		SOC="r8a7747"
		SOC_FULL="r8a77470"
		BOARD="iwg23s"
		RZG_GENERATION="1"
		RZG_VARIANT="c"
		RZG_NAME="RZ/G1C"
		RZG_LABEL="rzg1c"
		;;
	"iwg21m")
		DAUGHTER_BOARD="camera"
		SOC="r8a7742"
		SOC_FULL="r8a77420"
		SOM="iwg21m"
		BOARD="iwg21d"
		RZG_GENERATION="1"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G1H"
		RZG_LABEL="rzg1h"
		;;
	"iWave Systems RainboW-G21D-Qseven board based on RZ/G1H")
		SOC="r8a7742"
		SOC_FULL="r8a77420"
		SOM="iwg21m"
		BOARD="iwg21d"
		RZG_GENERATION="1"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G1H"
		RZG_LABEL="rzg1h"
		;;
	"iWave Systems RZ/G1H Qseven development platform with camera add-on")
		DAUGHTER_BOARD="camera"
		SOC="r8a7742"
		SOC_FULL="r8a77420"
		SOM="iwg21m"
		BOARD="iwg21d"
		RZG_GENERATION="1"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G1H"
		RZG_LABEL="rzg1h"
		;;
	"Silicon Linux RZ/G2E evaluation kit EK874 (CAT874 + CAT875)")
		SOC="r8a774c0"
		SOC_FULL="r8a774c0"
		BOARD="ek874"
		RZG_GENERATION="2"
		RZG_VARIANT="e"
		RZG_NAME="RZ/G2E"
		RZG_LABEL="rzg2e"
		;;
	"Silicon Linux RZ/G2E 96board platform (CAT874)")
		SOC="r8a774c0"
		SOC_FULL="r8a774c0"
		BOARD="cat874"
		RZG_GENERATION="2"
		RZG_VARIANT="e"
		RZG_NAME="RZ/G2E"
		RZG_LABEL="rzg2e"
		;;
	"HopeRun HiHope RZ/G2M with sub board"|"Hoperun Technology HiHope RZ/G2M extension board (hihope-rzg2m-ex)")
		SOC="r8a774a1"
		SOC_FULL="r8a774a1"
		BOARD="hihope-rzg2m-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="m"
		RZG_NAME="RZ/G2M"
		RZG_LABEL="rzg2m"
		;;
	"HopeRun HiHope RZ/G2M v3.0 with sub board")
		SOC="r8a774a3"
		SOC_FULL="r8a774a3"
		BOARD="hihope-rzg2m-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="m"
		RZG_NAME="RZ/G2M"
		RZG_LABEL="rzg2m"
		;;
	"HopeRun HiHope RZ/G2M main board based on r8a774a1")
		SOC="r8a774a1"
		SOC_FULL="r8a774a1"
		BOARD="hihope-rzg2m"
		RZG_GENERATION="2"
		RZG_VARIANT="m"
		RZG_NAME="RZ/G2M"
		RZG_LABEL="rzg2m"
		;;
	"HopeRun HiHope RZ/G2M with sub board connected with aistarvision-mipi-v2-adapter board")
		SOC="r8a774a1"
		SOC_FULL="r8a774a1"
		BOARD="hihope-rzg2m-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G2M"
		RZG_LABEL="rzg2m"
		RZG_VERSION="4.0"
		DAUGHTER_BOARD="aistarvision-mipi-v2-adapter"
		;;
	"HopeRun HiHope RZ/G2N with sub board")
		SOC="r8a774b1"
		SOC_FULL="r8a774b1"
		BOARD="hihope-rzg2n-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G2N"
		RZG_LABEL="rzg2n"
		RZG_VERSION="4.0"
		;;
	"HopeRun HiHope RZ/G2N main board based on r8a774b1")
		SOC="r8a774b1"
		SOC_FULL="r8a774b1"
		BOARD="hihope-rzg2n"
		RZG_GENERATION="2"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G2N"
		RZG_LABEL="rzg2n"
		RZG_VERSION="4.0"
		;;
	"HopeRun HiHope RZ/G2N with sub board connected with aistarvision-mipi-v2-adapter board")
		SOC="r8a774b1"
		SOC_FULL="r8a774b1"
		BOARD="hihope-rzg2n"
		RZG_GENERATION="2"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G2N"
		RZG_LABEL="rzg2n"
		RZG_VERSION="4.0"
		DAUGHTER_BOARD="aistarvision-mipi-v2-adapter"
		;;
	"HopeRun HiHope RZ/G2N (Rev.2.0) with sub board")
		SOC="r8a774b1"
		SOC_FULL="r8a774b1"
		BOARD="hihope-rzg2n-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G2N"
		RZG_LABEL="rzg2n"
		RZG_VERSION="2.0"
		;;
	"HopeRun HiHope RZ/G2N main board (Rev.2.0) based on r8a774b1")
		SOC="r8a774b1"
		SOC_FULL="r8a774b1"
		BOARD="hihope-rzg2n"
		RZG_GENERATION="2"
		RZG_VARIANT="n"
		RZG_NAME="RZ/G2N"
		RZG_LABEL="rzg2n"
		RZG_VERSION="2.0"
		;;
	"Renesas Ebisu board based on r8a77990")
		SOC="r8a77990"
		SOC_FULL="r8a77990"
		BOARD="ebisu"
		;;
	"Silicon Linux RZ/G2E evaluation kit EK874 (CAT874 + CAT875) with aistarvision-mipi-v2-adapter board")
		SOC="r8a774c0"
		SOC_FULL="r8a774c0"
		BOARD="ek874"
		RZG_GENERATION="2"
		RZG_VARIANT="e"
		RZG_NAME="RZ/G2E"
		RZG_LABEL="rzg2e"
		DAUGHTER_BOARD="aistarvision-mipi-v2-adapter"
		;;
	"HopeRun HiHope RZ/G2H with sub board")
		SOC="r8a774e1"
		SOC_FULL="r8a774e1"
		BOARD="hihope-rzg2h-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G2H"
		RZG_LABEL="rzg2h"
		RZG_VERSION="4.0"
		;;
	"HopeRun HiHope RZ/G2H main board based on r8a774e1")
		SOC="r8a774e1"
		SOC_FULL="r8a774e1"
		BOARD="hihope-rzg2h"
		RZG_GENERATION="2"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G2H"
		RZG_LABEL="rzg2h"
		RZG_VERSION="4.0"
		;;
	"HopeRun HiHope RZ/G2H with sub board connected with aistarvision-mipi-v2-adapter board")
		SOC="r8a774e1"
		SOC_FULL="r8a774e1"
		BOARD="hihope-rzg2h-ex"
		RZG_GENERATION="2"
		RZG_VARIANT="h"
		RZG_NAME="RZ/G2H"
		RZG_LABEL="rzg2h"
		RZG_VERSION="4.0"
		DAUGHTER_BOARD="aistarvision-mipi-v2-adapter"
		;;
	"Renesas SMARC EVK based on r9a07g044l2"|"Evaluation board based on r9a07g044l2")
		SOC="r9a07g044l2"
		SOC_FULL="r9a07g044l2"
		BOARD="smarc-rzg2l"
		RZG_GENERATION="2"
		RZG_VARIANT="l"
		RZG_NAME="RZ/G2L"
		RZG_LABEL="rzg2l"
		;;
	"SMARC v2.1 board based on r9a07g044l"|"RZG2L Evaluation Board Kit (Discrete Power System Ver.) (Dual Cortex-A55)")
		SOC="r9a07g044l"
		SOC_FULL="r9a07g044l"
		BOARD="smarc-rzg2l"
		RZG_GENERATION="2"
		RZG_VARIANT="l"
		RZG_NAME="RZ/G2L"
		RZG_LABEL="rzg2l"
		;;
	"Renesas SMARC EVK based on r9a07g044c2"|"Evaluation board based on r9a07g044c2")
		SOC="r9a07g044c2"
		SOC_FULL="r9a07g044c2"
		BOARD="smarc-rzg2lc"
		RZG_GENERATION="2"
		RZG_VARIANT="lc"
		RZG_NAME="RZ/G2LC"
		RZG_LABEL="rzg2lc"
		;;
	"Renesas SMARC EVK based on r9a07g054l2")
		SOC="r9a07g054l2"
		SOC_FULL="r9a07g054l2"
		BOARD="smarc-rzv2l"
		RZG_GENERATION="2"
		RZG_VARIANT="l"
		RZG_NAME="RZ/V2L"
		RZG_LABEL="rzv2l"
		;;
	"Renesas SMARC EVK based on r9a07g043u11"|"Evaluation board based on r9a07g043u11")
		SOC="r9a07g043u11"
		SOC_FULL="r9a07g043u11"
		BOARD="smarc-rzg2ul"
		RZG_GENERATION="2"
		RZG_VARIANT="ul"
		RZG_NAME="RZ/G2UL"
		RZG_LABEL="rzg2ul"
		;;
	*)
		echo "############Unsupported Board############"
		exit 1
		;;
esac

validate_board () {
	for CURRENT_BOARD in $1; do
		if [ "${CURRENT_BOARD}" == "${BOARD}" ]; then
			return 0
		fi
	done
	return 1
}

################################################################################
# Kernel version utils
################################################################################

kernel_get_version1 () {
	local KERNEL_VERSION="$1"
	echo "${KERNEL_VERSION}" | \
		awk -F"-" '{print $1}' | \
		awk -F"." '{print $1}'
}

kernel_get_version2 () {
	local KERNEL_VERSION="$1"
	echo "${KERNEL_VERSION}" | \
		awk -F"-" '{print $1}' | \
		awk -F"." '{print $2}'
}

kernel_get_version3 () {
	local KERNEL_VERSION="$1"
	local VERSION3=$(echo "${KERNEL_VERSION}" | \
			awk -F"-" '{print $1}' | \
			awk -F"." '{print $3}')
	if [ -z "${VERSION3}" ]; then
		echo 0
	else
		echo "${VERSION3}"
	fi
}

kernel_get_tags () {
	local KERNEL_VERSION="$1"
	echo "${KERNEL_VERSION}" | awk -F"-" '{print $2}'
}

kernel_is_cip () {
	local KERNEL_VERSION="$1"
	if kernel_get_tags "${KERNEL_VERSION}" | grep cip > /dev/null 2>&1; then
		return 0
	fi
	return 1
}

kernel_both_cip () {
	local VERSION1="$1"
	local VERSION2="$2"
	if kernel_is_cip "${VERSION1}" && kernel_is_cip "${VERSION2}"; then
		return 0
	fi
	return 1
}

kernel_get_label () {
	local VERSION="$1"
	local FULL_VERSION="$2"
	local VERSION1="$(kernel_get_version1 "${VERSION}")"
	local VERSION2="$(kernel_get_version2 "${VERSION}")"
	local VERSION3="$(kernel_get_version3 "${VERSION}")"
	if [ "${FULL_VERSION}" == "full" ]; then
		local VERSION_LABEL="${VERSION1}.${VERSION2}.${VERSION3}"
	elif [ -z "${FULL_VERSION}" ]; then
		local VERSION_LABEL="${VERSION1}.${VERSION2}"
	else
		echo "Invalid \$2 argument \"$2\""
	fi
	if kernel_is_cip "${VERSION}"; then
		VERSION_LABEL="${VERSION_LABEL}-cip"
	fi
	echo "${VERSION_LABEL}"
}

get_current_kernel_label() {
	if [ "$1" == "full" ]; then
		kernel_get_label "$(uname -r)" "$1"
	elif [ -z "$1" ]; then
		kernel_get_label "$(uname -r)"
	else
		echo "Invalid input "$1""
		return 1
	fi

}

# VERSION1 eq VERSION2
kernel_version_eq () {
	local VERSION1="$1"
	local VERSION2="$2"
	if [ $(kernel_get_version1 "${VERSION1}") -eq $(kernel_get_version1 "${VERSION2}") ] &&
	   [ $(kernel_get_version2 "${VERSION1}") -eq $(kernel_get_version2 "${VERSION2}") ] &&
	   [ $(kernel_get_version3 "${VERSION1}") -eq $(kernel_get_version3 "${VERSION2}") ]; then
		return 0
	fi
	return 1
}

# VERSION1 gt VERSION2
kernel_version_gt () {
	local VERSION1="$1"
	local VERSION2="$2"
	if [ $(kernel_get_version1 "${VERSION1}") -gt $(kernel_get_version1 "${VERSION2}") ]; then
		return 0
	elif [ $(kernel_get_version1 "${VERSION1}") -eq $(kernel_get_version1 "${VERSION2}") ]; then
		if [ $(kernel_get_version2 "${VERSION1}") -gt $(kernel_get_version2 "${VERSION2}") ]; then
			return 0
		elif [ $(kernel_get_version2 "${VERSION1}") -eq $(kernel_get_version2 "${VERSION2}") ] &&
		     [ $(kernel_get_version3 "${VERSION1}") -gt $(kernel_get_version3 "${VERSION2}") ]; then
			return 0
		fi
	fi
	return 1
}

# VERSION1 lt VERSION2
kernel_version_lt () {
	local VERSION1="$1"
	local VERSION2="$2"
	if ! kernel_version_gt "${VERSION1}" "${VERSION2}" && ! kernel_version_eq "${VERSION1}" "${VERSION2}"; then
		return 0
	fi
	return 1
}

# VERSION1 le VERSION2
kernel_version_le () {
	local VERSION1="$1"
	local VERSION2="$2"
	if ! kernel_version_gt "${VERSION1}" "${VERSION2}"; then
		return 0
	fi
	return 1
}

# VERSION1 ge VERSION2
kernel_version_ge () {
	local VERSION1="$1"
	local VERSION2="$2"
	if ! kernel_version_lt "${VERSION1}" "${VERSION2}"; then
		return 0
	fi
	return 1
}

current_kernel_eq () {
	kernel_version_eq "$(uname -r)" "$1"
}

current_kernel_gt () {
	kernel_version_gt "$(uname -r)" "$1"
}

current_kernel_lt () {
	kernel_version_lt "$(uname -r)" "$1"
}

current_kernel_ge () {
	kernel_version_ge "$(uname -r)" "$1"
}

current_kernel_le () {
	kernel_version_le "$(uname -r)" "$1"
}

current_kernel_cip () {
	uname -r | grep "cip"
	if [ $? -eq 0 ]; then
		return 1
	fi

	return 0
}
