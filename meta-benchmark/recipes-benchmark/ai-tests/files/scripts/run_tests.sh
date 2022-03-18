#!/bin/bash

RESULTS_FILE="results.log"
CURRENT_RESULT_FILE="current.log"
PROGRAM_NAME="$0"

################################################################################
# Utils

print_help () {
	cat<<-EOF

	  Run the given test files from within Lava's environment

	  USAGE: ${PROGRAM_NAME} [-h] FILE1 FILE2 ... FILEn

	  OPTIONS:
	  -h             Print this help and exit.

	EOF
}

get_filepath () {
	local CURRENT_FILE="$1"
	echo "$(cd "$(dirname "${CURRENT_FILE}")"; pwd)/$(basename "${CURRENT_FILE}")"
}

################################################################################
# Options parsing

while getopts ":h" opt; do
	case $opt in
	h)
		print_help
		exit 1
		;;
	\?)
		echo
		echo "Invalid option: -$OPTARG"
		print_help
		exit 1
		;;
	:)
		echo
		echo "Option -$OPTARG requires an argument."
		print_help
		exit 1
		;;
	esac
done

shift "$((OPTIND - 1))"

################################################################################
# Main

rm -f ${RESULTS_FILE} ${CURRENT_RESULT_FILE}

while (( "$#" )); do
	CURRENT_FILE="$(get_filepath "${1}")"
	eval ${CURRENT_FILE} | tee ${CURRENT_RESULT_FILE}
	EXIT_VALUE=${PIPESTATUS[0]}
	EXIT_LINE="$(grep "^EXIT|" ${CURRENT_RESULT_FILE})"
	RESULT="$(echo "${EXIT_LINE}" | awk -F'|' '{print $2}' | tr [A-Z] [a-z])"
	TEST="$(echo "${EXIT_LINE}" | awk -F'|' '{print $3}')"
	TEST="$(echo ${TEST%.*} | tr [a-z] [A-Z])"
	MESSAGE="$(echo "${EXIT_LINE}" | awk -F'|' '{print $4}')"
	MEASUREMENT="$(echo "${EXIT_LINE}" | awk -F'|' '{print $5}')"
	UNIT="$(echo "${EXIT_LINE}" | awk -F'|' '{print $6}')"
	cat<<-EOF

	Exit value:  ${EXIT_VALUE}
	Result:      ${RESULT}
	Test:        ${TEST}
	Message:     ${MESSAGE}
	Measurement: ${MEASUREMENT}
	Unit:        ${UNIT}
	EOF
	echo "${EXIT_LINE}" >> "${RESULTS_FILE}"

	if [ -z "${MEASUREMENT}" ] || [ -z "${UNIT}" ]; then
		lava-test-case \
			"${TEST}" \
			--result "${RESULT}"
	else
		lava-test-case \
			"${TEST}" \
			--result "${RESULT}" \
			--measurement "${MEASUREMENT}" \
			--units "${UNIT}"
	fi

	shift
done
