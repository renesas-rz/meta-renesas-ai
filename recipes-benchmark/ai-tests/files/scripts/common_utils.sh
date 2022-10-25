#!/bin/bash

################################################################################
# Cleanup utils
################################################################################

trap __cleanup__ 0 1 2 3 6 9 15

__cleanup () {
	${TEST_SPECIFIC_CLEANUP_FUNCTION}
	if [ -n "${DEBUG}" ]; then
		cat<<-EOF | print_debug
		Please manually delete temporary directory:
		* ${TMP_DIR}
		EOF
	else
		rm -r "${TMP_DIR}"
	fi
}

__cleanup__ () {
	if [ -n "${__PRINTED_EXIT_LINE}" ]; then
		return
	fi
	echo "Received signal. Exiting..." | print_info
	print_failure "Test killed"
}

register_cleanup_function () {
	if [ -z "$1" ]; then
		echo "You must provide a function name when invoking register_cleanup_function"
		return 1
	fi
	if [ "$1" == "__cleanup" ]; then
		echo "Please, rename your test specific cleanup function to something that won't cause any problems"
		return 1
	fi
	TEST_SPECIFIC_CLEANUP_FUNCTION="$1"
}

unregister_cleanup_function () {
	unset TEST_SPECIFIC_CLEANUP_FUNCTION
}

################################################################################
# Time utils
################################################################################

get_time_from_seconds () {
	local _SECONDS="$1"
	printf '%02d:%02d:%02d' $(($_SECONDS/3600)) $(($_SECONDS%3600/60)) $(($_SECONDS%60))
}

################################################################################
# Interrupts utils
################################################################################

# This function returns a string with the IRQ counter value for the desired
# line from /proc/interrupts for the desired processors.
#
# Parameters:
# $1 - The desired line extracted from /proc/interrupts
# $2 - The list of processors for which we want to know the interrupts for.
#      Valid processor strings can be found in the first line /proc/interrupts.
#      When "all" is used (or when omitted) it'll be translated as list of all
#      the processors available as seen from /proc/interrupts
#
# Returns:
# stdout - The total number of interrupts detected for interrupt line and
#          for the desired processors
get_irq_counter_from_pattern ()  {
	local INTERRUPTS_LINE="$1"
	local PROCESSORS_LIST="$2"
	if [ -z "${PROCESSORS_LIST}" ]; then
		PROCESSORS_LIST="all"
	fi

	local INTERRUPTS_PROCESSORS=""
	local PROCESSORS_NUMBER=""

	local CURRENT_PROCESSOR=""
	local CURRENT_PROCESSOR_IRQS=0
	local CURRENT_PROCESSOR_INDEX=0
	local MATCH_PROCESSOR_INDEX=""

	local CURRENT_PROCESSOR_FROM_LIST=""

	local IRQS=0

	INTERRUPTS_LINE="$(echo "${INTERRUPTS_LINE}" | awk -F":" '{print $2}')"
	INTERRUPTS_PROCESSORS="$(head -n 1 /proc/interrupts)"
	PROCESSORS_NUMBER="$(echo "${INTERRUPTS_PROCESSORS}" | wc -w)"

	if [ "${PROCESSORS_LIST}" == "all" ]; then
		PROCESSORS_LIST="${INTERRUPTS_PROCESSORS}"
	fi

	for CURRENT_PROCESSOR in ${INTERRUPTS_PROCESSORS}; do
		# We use loops in place of awk and grep here only for robustness
		# and portability reasons
		MATCH_PROCESSOR_INDEX=0
		for CURRENT_PROCESSOR_IRQS in ${INTERRUPTS_LINE}; do
			if [ ${MATCH_PROCESSOR_INDEX} -eq ${CURRENT_PROCESSOR_INDEX} ]; then
				break;
			fi
			MATCH_PROCESSOR_INDEX=$(expr ${MATCH_PROCESSOR_INDEX} + 1)
		done

		for CURRENT_PROCESSOR_FROM_LIST in ${PROCESSORS_LIST}; do
			if [ "${CURRENT_PROCESSOR}" == "${CURRENT_PROCESSOR_FROM_LIST}" ]; then
				IRQS=$(expr ${IRQS} + ${CURRENT_PROCESSOR_IRQS})
			fi
		done
		CURRENT_PROCESSOR_INDEX=$(expr ${CURRENT_PROCESSOR_INDEX} + 1)
	done

	echo ${IRQS}
}

# This function returns a string with the IRQ counter value for the desired
# IRQ number
#
# Parameters:
# $1 - The desired IRQ number
# $2 - Optional list of cpus we want the total number of IRQs for
#
# Returns:
# stdout - The total number of interrupts detected for the desired IRQ number
get_irq_counter_by_irq_number () {
	local IRQ_NUMBER="$1"
	get_irq_counter_from_pattern "$(grep "^[ ]*${IRQ_NUMBER}:" /proc/interrupts)" "$2"
}

# This function returns a string with the IRQ counter value for the desired
# name (as shown by /proc/interrupts)
#
# Parameters:
# $1 - The desired device name (as shown by /proc/interrupts)
# $2 - Optional list of cpus we want the total number of IRQs for
#
# Returns:
# stdout - The total number of interrupts detected for the desired device name,
get_irq_counter_by_name () {
	local DEVICE_NAME="$1"
	get_irq_counter_from_pattern "$(grep -w "${DEVICE_NAME}" /proc/interrupts)" "$2"
}

# This function returns a string with the total number of IRQs seen from
# /proc/interrupts for the desired regular expression
#
# Parameters:
# $1 - The regular expression to use when grepping over /proc/interrupts
# $2 - Optional list of cpus we want the total number of IRQs for
#
# Returns:
# stdout - The total number of interrupts detected for the desired regular
#          expression,
get_irq_counter_by_regular_expression () {
	local REGULAR_EXPRESSION="$1"
	local TMP_FILE="$(mktemp -p ${TMP_DIR})"
	local CURRENT_LINE=""
	local TOTAL_COUNTER=0
	local CURRENT_COUNTER=0
	eval grep -E "${REGULAR_EXPRESSION}" /proc/interrupts > "${TMP_FILE}"
	while read CURRENT_LINE; do
		CURRENT_COUNTER="$(get_irq_counter_from_pattern "${CURRENT_LINE}" "$2")"
		TOTAL_COUNTER="$(expr ${TOTAL_COUNTER} + ${CURRENT_COUNTER})"
	done < "${TMP_FILE}"
	rm "${TMP_FILE}"
	echo "${TOTAL_COUNTER}"
}

# This function returns a string with the total number of IRQs seen from
# the desired snapshot of /proc/interrupts
#
# Parameters:
# $1 - The desired snapshot of /proc/interrupts
# $2 - Optional list of cpus we want the total number of IRQs for
#
# Returns:
# stdout - The total number of interrupts detected
get_irq_counter_from_file () {
	local INPUT_FILE="$1"
	local CURRENT_LINE=""
	local TOTAL_COUNTER=0
	local CURRENT_COUNTER=0
	while read CURRENT_LINE; do
		CURRENT_COUNTER="$(get_irq_counter_from_pattern "${CURRENT_LINE}" "$2")"
		TOTAL_COUNTER="$(expr ${TOTAL_COUNTER} + ${CURRENT_COUNTER})"
	done < "${INPUT_FILE}"
	echo "${TOTAL_COUNTER}"
}

# This function returns the IRQ number corresponding to the desired device name.
#
# Parameters:
# $1 - The desired device name
#
# Returns:
# stdout - The IRQ number corresponding to the desired device name.
get_irq_number_from_name () {
	local NAME="$1"
	local IRQ=""

	IRQ="$(grep -w "${NAME}\$" /proc/interrupts | awk -F":" '{print $1}')"
	expr ${IRQ} + 0
}

get_tty_irq () {
	local DEVICE_NAME=$(basename $1)
	local IRQ=""
	if [ ! -f "/sys/class/tty/${DEVICE_NAME}/irq" ]; then
		return 1
	else
		IRQ=$(cat /sys/class/tty/${DEVICE_NAME}/irq)
	fi
	echo "${IRQ}"
	return 0
}

################################################################################
# Kernel configuration utils
################################################################################

is_config_option_set() {
	local CONFIG_OPTION="$1"
	zcat /proc/config.gz | grep -E "^${CONFIG_OPTION}=y|^${CONFIG_OPTION}=m|^${CONFIG_OPTION}=\"" > /dev/null
}

is_module_config_option_set() {
	local CONFIG_OPTION="$1"
	zcat /proc/config.gz | grep -E "^${CONFIG_OPTION}=m" > /dev/null
}

validate_options () {
	local RETURN_VALUE=0
	for CURRENT_OPTION in $1; do
		if ! is_config_option_set "${CURRENT_OPTION}"; then
			echo "${CURRENT_OPTION} not enabled" | print_warning
			RETURN_VALUE=1
		fi
	done
	return ${RETURN_VALUE}
}

################################################################################
# Kernel bootargs utils
################################################################################

is_bootarg_available() {
	local BOOTARG_OPTION="$1"
	cat /proc/cmdline | grep "${BOOTARG_OPTION}" > /dev/null
}

################################################################################
# Kernel ring buffer utils
################################################################################

# This function strips the timestamp information from the kernel ring buffer.
# Usage example:
# dmesg | strip_timestamp
#
# Files:
# stdin - this function takes its input from the standard input.
strip_timestamp () {
	sed "s/^\[[ ]*\?[0-9.]*\] //g"
}

################################################################################
# Kernel DHCP parsing
################################################################################

get_boot_dhcp_server_address () {
	local DEFAULT_ADDRESS="$1"
	local BOOT_DHCP=""
	local TO_MATCH="IP-Config: Got DHCP answer from"
	if ! dmesg | strip_timestamp | grep "${TO_MATCH}" > /dev/null 2>&1; then
		echo "${DEFAULT_ADDRESS}"
		return 1
	fi
	BOOT_DHCP="$(dmesg | \
		strip_timestamp | \
		grep "${TO_MATCH}" | \
		awk -F"," '{print $1}' | \
		rev | \
		awk -F" " '{print $1}' | \
		rev)"
	echo "${BOOT_DHCP}"
	return 0
}

get_boot_dhcp_network_interface () {
	local DEFAULT_INTERFACE="$1"
	local BOOT_INTERFACE=""
	local TO_MATCH="IP-Config: Complete:"
	if ! dmesg | strip_timestamp | grep "${TO_MATCH}" > /dev/null 2>&1; then
		echo "${DEFAULT_INTERFACE}"
		return 1
	fi
	BOOT_INTERFACE="$(dmesg | \
		strip_timestamp | \
		grep -A 1 "IP-Config: Complete:" | \
		tail -n +2 | \
		awk -F"device=" '{print $2}' | \
		awk -F"," '{print $1}')"
	echo "${BOOT_INTERFACE}"
	return 0
}


################################################################################
# Communication with user utils
################################################################################

get_timestamp_date () {
	date +"%Y/%m/%d %H:%M:%S"
}

get_timestamp_seconds_from_date () {
	date +%s
}

get_timestamp_seconds_since_start () {
	expr $(date +%s) "-" ${START_TIME}
}

get_timestamp () {
	case "${PRINT_TIMESTAMP}" in
	"seconds-start")
		echo -n "$(get_timestamp_seconds_since_start)"
		;;
	"seconds-date")
		echo -n "$(get_timestamp_seconds_from_date)"
		;;
	"date")
		echo -n "$(get_timestamp_date)"
		;;
	esac
}

print_message () {
	local LABEL=""
	local TIMESTAMP="$(get_timestamp)"
	if [ -n "${TIMESTAMP}" ]; then
		TIMESTAMP="[${TIMESTAMP}]"
	fi
	LABEL="$(echo "${TIMESTAMP}[${1}]" | sed "s/\//\\\\\//g")"
	sed "s/^/ ${LABEL} /g"
}

print_debug () {
	print_message "DEBUG"
}

print_warning () {
	print_message "WARNING"
}

print_error () {
	print_message "ERROR"
}

print_info () {
	print_message "INFO"
}

print_expected () {
	local EXPECTED="$1"
	local COMMAND=""

	if [ -f "${EXPECTED}" ]; then
		COMMAND="cat"
	else
		COMMAND="echo"
	fi

	cat<<-EOF

	########################################################################
	#                               EXPECTED                               #
	########################################################################
	EOF
	"${COMMAND}" "${EXPECTED}"
}

print_current (){
	local CURRENT="$1"
	local COMMAND=""
	if [ -f "${CURRENT}" ]; then
		COMMAND="cat"
	else
		COMMAND="echo"
	fi

	cat<<-EOF

	########################################################################
	#                                CURRENT                               #
	########################################################################
	EOF
	"${COMMAND}" "${CURRENT}"
}

# This function prints a expected output against a current output.
#
# Parameters:
# $1 - "Golden" file / string
# $2 - Current file / string
#
# Returns:
# prints expected vs current
# return value - 1 if $1 and $2 aren't the same type (ie. file or string)
#                OR 0
print_expected_current () {
	local EXPECTED="$1"
	local CURRENT="$2"

	if [ -f "${EXPECTED}" ] && [ -f "${CURRENT}" ]; then
		print_expected "${EXPECTED}"
		print_current "${CURRENT}"
	elif [ ! -f "${EXPECTED}" ] && [ ! -f "${CURRENT}" ]; then
		print_expected "${EXPECTED}"
		print_current "${CURRENT}"
	else
		echo "\$1 and \$2 aren't the same type" | print_error
		return 1
	fi

	return 0
}

# This function asks the user a question to which a y (yes) or (no) answer
# exists.
#
# Parameters:
# $1 - The question to ask to the user
#
# Returns:
# return value - 0 if the user answered yes to the question, 1 otherwise
ask_user () {
	local QUESTION="$1"
	local ANSWER=""
	while true; do
		read -p " ${QUESTION} [y/n] " ANSWER
		case $ANSWER in
			[Yy]* )
				return 0
				;;
			[Nn]* )
				return 1
				;;
			* )
				echo " Please, answer yes ([yY]) or no ([nN])"
				;;
		esac
	done
}

# This function asks the user a question and sits on it until the user answers
# with a y (yes)
#
# Parameters:
# $1 - The question to ask to the user
user_must_answer_yes () {
	local QUESTION="$1"
	while ! ask_user "${QUESTION}"; do : ; done
}

################################################################################
# Failure states available in LAVA are: FAIL, UNKNOWN, and SKIP
# Success states available in LAVA are: PASS
# For more details please have a look at:
# http://lava.ciplatform.org/static/docs/v2/results-intro.html#results-in-lava

print_exit_line () {
	local EXIT_RESULT="$1"
	local EXIT_MESSAGE="$2"
	local EXIT_MEASUREMENT="$3"
	local EXIT_UNIT="$4"
	local END_TIME=$(date +%s)
	local EXECUTION_TIME="$(get_time_from_seconds $((END_TIME - START_TIME)))"
	__cleanup
	echo
	echo "EXIT|${EXIT_RESULT}|${PROGRAM_BASENAME}|[${EXECUTION_TIME}] ${EXIT_MESSAGE}|${EXIT_MEASUREMENT}|${EXIT_UNIT}"
	echo

	__PRINTED_EXIT_LINE="yes"
}

# This function prints a successful exit message and exits
#
# Parameters:
# $1 - Exit message
# $2 - Measurement value, must be a number
# $3 - The unit of measure corresponding to the measurement
print_success () {
	local EXIT_MESSAGE="$1"
	local EXIT_MEASUREMENT="$2"
	local EXIT_UNIT="$3"
	print_exit_line \
		"PASS" \
		"${EXIT_MESSAGE}" \
		"${EXIT_MEASUREMENT}" \
		"${EXIT_UNIT}"
	exit 0
}

# This function prints a failure exit message and exits
#
# Parameters:
# $1 - Exit message
# $2 - Measurement value, must be a number
# $3 - The unit of measure corresponding to the measurement
print_failure () {
	local EXIT_MESSAGE="$1"
	local EXIT_MEASUREMENT="$2"
	local EXIT_UNIT="$3"
	print_exit_line \
		"FAIL" \
		"${EXIT_MESSAGE}" \
		"${EXIT_MEASUREMENT}" \
		"${EXIT_UNIT}"
	exit 2
}

# This function prints an exit message for the skip case and exits
#
# Parameters:
# $1 - Exit message
# $2 - Measurement value, must be a number
# $3 - The unit of measure corresponding to the measurement
print_skip () {
	local EXIT_MESSAGE="$1"
	local EXIT_MEASUREMENT="$2"
	local EXIT_UNIT="$3"
	print_exit_line \
		"SKIP" \
		"${EXIT_MESSAGE}" \
		"${EXIT_MEASUREMENT}" \
		"${EXIT_UNIT}"
	exit 3
}

# This function prints an exit message for the generic error case and exits
#
# Parameters:
# $1 - Exit message
# $2 - Measurement value, must be a number
# $3 - The unit of measure corresponding to the measurement
print_unknown () {
	local EXIT_MESSAGE="$1"
	local EXIT_MEASUREMENT="$2"
	local EXIT_UNIT="$3"
	print_exit_line \
		"UNKNOWN" \
		"${EXIT_MESSAGE}" \
		"${EXIT_MEASUREMENT}" \
		"${EXIT_UNIT}"
	exit 4
}

# This function prints the command to run on the stdout and then executes it
#
# Parameters:
# $@ - The command to executed
print_and_run () {
	echo "\$ $@"
	eval $@
}

################################################################################
# Block device utils
################################################################################

# This function returns the device name corresponding to a block device
# given the class name for the device and a string used to uniquely identify
# the specific device
#
# Parameters:
# $1 - The string used to uniquely identify the desired block device
# $2 - The class name for the desired device
#
# Returns:
# stdout - The desired device name
get_block_device_name () {
	local PATTERN="$1"
	local DEVICE_CLASS="$2"
	local CURRENT_DEVICE=""
	for CURRENT_DEVICE in $(ls -d /sys/class/block/${DEVICE_CLASS}?) ; do
		readlink ${CURRENT_DEVICE} | grep "${PATTERN}" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "/dev/$(basename ${CURRENT_DEVICE})"
			return 0
		fi
	done
	return 1
}

# This function returns the device name corresponding to a device with class
# name sd
#
# Parameters:
# $1 - The string used to uniquely identify the desired block device
#
# Returns:
# stdout - The desired device name
get_block_device_name_sd () {
	get_block_device_name $1 "sd"
}

# This function returns the device name corresponding to a device with class
# name sd
#
# Parameters:
# $1 - The string used to uniquely identify the desired block device
#
# Returns:
# stdout - The desired device name
get_block_device_name_mmcblk () {
	get_block_device_name $1 "mmcblk"
}

# This function returns the device filenames for the partitions that belong
# to the desired device
#
# Parameters:
# $1 - The device name to return the partition device filename for
#
# Returns:
# stdout - the device filenames corresponding to the partitions, separated by
#          a new line
get_partition_names () {
	local DEVICE_NAME="$1"
	local PARTITION_NAMES=""
	local CURRENT_PARTITION=""
	PARTITION_NAMES="$(lsblk -P --output TYPE,NAME ${DEVICE_NAME} | \
		grep 'TYPE="part"' | \
		awk -F'NAME="' '{print $2}' | \
		rev | cut -c 2- | rev)"
	for CURRENT_PARTITION in ${PARTITION_NAMES}; do
		echo "/dev/${CURRENT_PARTITION}"
	done
}

# This function tests a block device with mount/read/write/unmount operations
# exists.
#
# Parameters:
# $1 - partition name
#
# Returns:
# return value - 0 for success, 1 for failure
test_block_device () {
	local DEV_PATH=""
	local DEV=""
	local ERROR=""
	if [ -z "$1" ]; then
		echo "Please specify the input block device name (e.g. /dev/mmcblk0p1) to be tested as an argument"
		return 1
	fi

	DEV_PATH=$1
	DEV=$(echo $DEV_PATH | cut -c 6-)
	echo $DEV
	ERROR=0

	#Test Device Mounts
	echo "Mounting Block Device - $DEV"
	print_and_run mkdir -p /tmp/rmnt/$DEV
	print_and_run mount -t auto $DEV_PATH /tmp/rmnt/$DEV
	if [ $? -eq 0 ]; then
		echo "Block Device $DEV mounted with no failures"
		#Device mounted so run cp to test it.
		print_and_run dd if=/dev/urandom of=/tmp/$DEV-random bs=1024 count=10240
		print_and_run cp /tmp/$DEV-random /tmp/rmnt/$DEV/$DEV-random
		if [ $? -ne 0 ]; then ERROR=1; fi
		print_and_run diff -q /tmp/$DEV-random /tmp/rmnt/$DEV/$DEV-random
		if [ $? -ne 0 ]; then ERROR=1; fi
		#Finished testing device so make sure we can un-mount it.
		echo "Un-mounting Block Device - $DEV"
		print_and_run umount /tmp/rmnt/$DEV
		if [ $? -eq 0 ]; then
			echo "Block Device $DEV un-mounted with no failures"
		else
			echo "Block Device $DEV failed to un-mount (see above)"
			return 1
		fi

		if [ $ERROR -ne 0 ]; then
			echo "Block Device $DEV tests completed with failures (see above)"
			return 1
		else
			echo "Block Device $DEV tests completed with no failures"
		fi
	else
		echo "FAILED: Block Device $DEV failed to mount (see above)"
		return 1
	fi

	return 0
}

################################################################################
# String utils
################################################################################

trim_leading_whitespaces () {
	sed 's/^[ \t]*//g'
}

trim_trailing_whitespaces () {
	sed 's/[ \t]*$//g'
}

trim_whitespaces () {
	trim_leading_whitespaces | trim_trailing_whitespaces
}

################################################################################
# Display utils
################################################################################

get_crtc_resolution () {
	local CRTC_ID="$1"
	modetest -M rcar-du -p | grep "^${CRTC_ID}" | head -n 1 | awk '{print $4}' | sed "s|(||g" | sed "s|)||g"
}

get_crtc_width () {
	local CRTC_ID="$1"
	local SCREEN_RESOLUTION="$(get_crtc_resolution "${CRTC_ID}")"
	echo "${SCREEN_RESOLUTION}" | awk -F"x" '{print $1}'
}

get_crtc_height () {
	local CRTC_ID="$1"
	local SCREEN_RESOLUTION="$(get_crtc_resolution "${CRTC_ID}")"
	echo "${SCREEN_RESOLUTION}" | awk -F"x" '{print $2}'
}

get_fraction_from_percentage () {
	echo "$(echo $1 | sed "s|%||g") / 100"
}

get_rectangle_size () {
	local CRTC_ID="$1"
	local FRACTION="$(get_fraction_from_percentage $2)"
	echo "$(echo "$(get_crtc_width "${CRTC_ID}") * ${FRACTION}" | bc)x$(echo "$(get_crtc_height "${CRTC_ID}") * ${FRACTION}" | bc)"
}

get_coordinates_on_diagonal () {
	local CRTC_ID="$1"
	local FRACTION="$(get_fraction_from_percentage $2)"
	echo "$(echo "$(get_crtc_width "${CRTC_ID}") * ${FRACTION}" | bc)+$(echo "$(get_crtc_height "${CRTC_ID}") * ${FRACTION}" | bc)"
}

# This function returns a string with the crtc ID
#
# Parameters: None
#
# Returns:
# stdout - the crtc ID, or "ERROR" when there is no entry for crtc ID
# return value - 0 when successfull, 1 in case of error
get_crtc_id () {
	local CONNECTOR_ID="$(get_connector_id ${1})"
	local ENCODER_ID=""
	local CRTC_ID=""
	if [ "${CONNECTOR_ID}" == "ERROR" ]; then
		echo "ERROR"
		return 1
	fi
	ENCODER_ID="$(modetest -M rcar-du -c | grep -w "^${CONNECTOR_ID}" | awk '{print $2}')"
	CRTC_ID=$(modetest -M rcar-du -e | grep -w "^${ENCODER_ID}" | awk '{print $2}')
	echo "${CRTC_ID}"
	return 0
}

get_encoder_id_for_crtc_id () {
	local CRTC_ID="$1"
	modetest -M rcar-du -e | awk "\$2 == ${CRTC_ID}" | awk '{print $1}'
}

get_possible_crtcs_for_encoder_id () {
	local ENCODER_ID="$1"
	modetest -M rcar-du -e | awk "\$1 == ${ENCODER_ID}" | awk '{print $4}'
}

# This function returns a string with the connector ID
#
# Parameters:
# $1 -  The name of the connector interface.
#
# Returns:
# stdout - the connector ID, "ERROR" when there is no entry for connector ID
# return value - 0 when successfull, 1 in case of error
get_connector_id () {
	local CONNECTOR_ID=""
	CONNECTOR_ID=$(modetest -M rcar-du -c | grep -E "^[0-9]+" | grep -w connected | grep -w ${1} | head -n 1 | awk '{print $1}')
	if [ -z "${CONNECTOR_ID}" ]; then
		echo "ERROR"
		return 1
	fi
	echo "${CONNECTOR_ID}"
	return 0
}

get_modetest_planes () {
	local PLANES_LINE_NUMBER=$(modetest -M rcar-du -p | grep -n "Planes:" | awk -F":" '{print $1}')
	modetest -M rcar-du -p | tail -n +$(expr ${PLANES_LINE_NUMBER} + 1)
}

# This function returns a string with an alpha value
#
# Parameters:
# $1 -  The name of the connector interface.
# $2 -  One of the two following strings "MIN"/"MAX"
#
# Returns:
# stdout - either the minimum alpha value or the maximum alpha value;
# 	   by default it return the maximum alpha value
get_alpha_range_for_plane_id () {
	local PLANE_ID="$1"

	if [[ $2 == "MIN" ]]; then
		get_modetest_planes | awk "\$1 == ${PLANE_ID} {for(i=1; i<=10; i++) {getline; print}}" | awk "\$2 == alpha {for(i=0; i<=2; i++) {getline; print}}" | awk '$1=="values:" {print $2}'
	else
		get_modetest_planes | awk "\$1 == ${PLANE_ID} {for(i=1; i<=10; i++) {getline; print}}" | awk "\$2 == alpha {for(i=0; i<=2; i++) {getline; print}}" | awk '$1=="values:" {print $3}'
	fi
}

get_possible_crtcs_for_plane_id () {
	local PLANE_ID="$1"
	get_modetest_planes | awk "\$1 == ${PLANE_ID}" | awk '{print $7}'
}

filter_planes_list_by_possible_crtcs () {
	local PLANE_IDS="$1"
	local POSSIBLE_CRTCS="$2"
	local POSSIBLE_CRTCS_FOR_PLANE_ID=""
	local NEW_LIST=""
	local CRTCS=""
	for CURRENT_PLANE_ID in ${PLANE_IDS}; do
		POSSIBLE_CRTCS_FOR_PLANE_ID="$(get_possible_crtcs_for_plane_id ${CURRENT_PLANE_ID})"
		if [ -z "${POSSIBLE_CRTCS_FOR_PLANE_ID}" ]; then
			continue
		fi
		CRTCS=$(and "${POSSIBLE_CRTCS_FOR_PLANE_ID}" "${POSSIBLE_CRTCS}")
		if [ "${CRTCS}" != "0x0" ]; then
			NEW_LIST="${NEW_LIST} ${CURRENT_PLANE_ID}"
		fi
	done
	echo ${NEW_LIST}
}

get_crtc_id_for_plane_id () {
	local PLANE_ID="$1"
	get_modetest_planes | grep "^${PLANE_ID}" | awk '{print $2}'
}

# This function returns the PLANE ID of the planes supporting the specified
# property
#
# Parameters:
# $1 - The name of the property to look for
#
# Returns:
# stdout - a white space separated list of PLANE IDs that allow for the
#          specified property
# return value - 0 when successfull, 1 in case of error
get_plane_ids_for_property () {
	local PROPERTY="$1"

	local PROPERTY_LINES=""
	local PLANE_LINES=""

	local FIRST_PLANE=""
	local LAST_PLANE=""

	local CURRENT_PROPERTY=""
	local CURRENT_PLANE=""
	local PREVIOUS_PLANE=""

	local PLANE_IDS=""
	local PLANE_ID=""

	get_modetest_planes > "${TMP_DIR}/planes.log"

	# now we need to get the line numbers of where the desired property
	# appears, but also we need to get the line numbers of where the desired
	# each plane information starts
	PROPERTY_LINES=$(grep -nw "${PROPERTY}:" "${TMP_DIR}/planes.log" | awk -F":" '{print $1}')
	PLANE_LINES=$(grep -n "^[1-9]" "${TMP_DIR}/planes.log" | awk -F":" '{print $1}')

	if [ -z "${PROPERTY_LINES}" ]; then
		return 1
	fi

	# let's just save the first plane line and the last plane line for
	# later reuse
	FIRST_PLANE=$(echo ${PLANE_LINES} | awk '{print $1}')
	LAST_PLANE=$(echo ${PLANE_LINES} | awk '{print $NF}')

	for CURRENT_PROPERTY in ${PROPERTY_LINES}; do
		PREVIOUS_PLANE=${FIRST_PLANE}
		PLANE_ID=""
		for CURRENT_PLANE in ${PLANE_LINES}; do
			if [ ${CURRENT_PROPERTY} -lt ${CURRENT_PLANE} ]; then
				break
			fi
			PREVIOUS_PLANE="${CURRENT_PLANE}"
		done
		PLANE_ID="$(head -n ${PREVIOUS_PLANE} "${TMP_DIR}/planes.log" | tail -n 1 | awk '{print $1}')"
		if [ "$(get_crtc_id_for_plane_id "${PLANE_ID}")" -eq 0 ]; then
			PLANE_IDS="${PLANE_IDS} ${PLANE_ID}"
		fi
	done
	echo "${PLANE_IDS}" | trim_leading_whitespaces

	return 0
}

################################################################################
# CPU utils
################################################################################

# This function returns the total number of cores reported in the OS
#
# Returns:
# stdout - total CPU number
# return value - total CPU number
get_total_cpu_count() {
	local TOTAL_CPUS=$(ls /sys/devices/system/cpu/ | grep -E "cpu[0-9]+" | wc -l)
	echo "${TOTAL_CPUS}"
	return ${TOTAL_CPUS}
}

# This function returns the number of cores that are online at any one time on
# the device
#
# Returns:
# stdout - active CPU number
# return value - active CPU number
get_active_cpu_count() {
	local ACTIVE_CPUS=$(cat /sys/devices/system/cpu/cpu*/online | grep "^1" | wc -l)
	echo "${ACTIVE_CPUS}"
	return ${ACTIVE_CPUS}
}

# This function returns a list of online CPUs as a string
#
# Parameters:
# $1 ... $n - list of cpus to hold back
#
# Returns:
# stdout - a white space seperated list of CPU numbers
list_available_cpus() {
	local AVAILABLE_CPUS=""
	local CURRENT_PROCESSOR=""
	local TOTAL_CPUS=$(get_total_cpu_count)
	for CURRENT_PROCESSOR in $(seq 0 `expr ${TOTAL_CPUS} - 1`); do
		if [ "$(cat /sys/devices/system/cpu/cpu"${CURRENT_PROCESSOR}"/online 2>&1)" == "1" ]; then
			if ! echo $@ | grep -wq ${CURRENT_PROCESSOR}; then
				AVAILABLE_CPUS="${AVAILABLE_CPUS} ${CURRENT_PROCESSOR}"
			fi
		fi
	done

	echo "${AVAILABLE_CPUS}"
}

load_cpus() {
	local CPUS_LIST="$1"
	local CURRENT_CPU=""
	local CURRENT_PID=""
	local LOAD_PIDS=""
	local CPU_ID=""

	for CURRENT_CPU in ${CPUS_LIST}; do
		echo "Loading CPU ${CURRENT_CPU}" 1>&2
		CPU_ID="$(printf "0x%x" $(echo "2^${CURRENT_CPU}" | bc))"
		echo 2000000000 | dhry > /dev/null 2>&1 &
		CURRENT_PID=$!
		taskset -p "${CPU_ID}" "${CURRENT_PID}" > /dev/null 2>&1
		LOAD_PIDS="${LOAD_PIDS} ${CURRENT_PID}"
	done

	echo "${LOAD_PIDS}"
}

load_available_cpus() {
	load_cpus "$(list_available_cpus)"
}

unload_pids() {
	local CURRENT_PID=""
	for CURRENT_PID in $1; do
		echo "Killing PID ${CURRENT_PID}" 1>&2
		kill -9 ${CURRENT_PID}
	done
}

# This function brings online the specified core
#
# Parameters:
# $1 - the number of the core to bring online
#
# Returns:
# return value 0 if successful, 1 if connot bring CPU online
enable_cpu() {
	local PROCESSOR="$1"
	echo 1 > /sys/devices/system/cpu/cpu"${PROCESSOR}"/online
	if [ "$(cat /sys/devices/system/cpu/cpu"${PROCESSOR}"/online)" != "1" ]; then
		echo "Can't bring CPU${PROCESSOR} online"
		return 1
	fi
	return 0
}

# This function brings online all the cores reported by the OS
#
# Returns:
# return value 0 if successful, 1 if connot bring all CPUs online
enable_all_cpus() {
	local CURRENT_PROCESSOR=""
	local TOTAL_PROCESSORS=$(get_total_cpu_count)
	local ONLINE_PROCESSORS=$(get_active_cpu_count)
	local EXIT_VALUE="0"

	for CURRENT_PROCESSOR in $(seq 0 `expr ${TOTAL_PROCESSORS} - 1` ); do
		enable_cpu ${CURRENT_PROCESSOR}
		if [ $? -ne 0 ]; then
			echo "Failed to take CPU${CURRENT_PROCESSOR} offline"
			EXIT_VALUE="1"
		fi
	done
	return ${EXIT_VALUE}
}

# This function bring offline the specified core
#
# Parameters:
# $1 - the number of the core to take offline
#
# Returns:
# return value 0 if successful, 1 if connot take CPUs offline
disable_cpu() {
	local PROCESSOR="$1"
	echo 0 > /sys/devices/system/cpu/cpu"${PROCESSOR}"/online
	if [ "$(cat /sys/devices/system/cpu/cpu"${PROCESSOR}"/online)" != "0" ]; then
		echo "Failed to bring CPU${PROCESSOR} offline"
		return 1
	fi
	return 0
}

# This function gets the type of cpus available, defined by capacity-dmips-mhz
#
# Returns:
# The number of cpus of each type
get_big_little_cpu_types(){
	local TOTAL_CPUS=$(get_total_cpu_count)
	local CURRENT_PROCESSOR=""
	local HEX_FREQ=""
	local BIG_FREQ=""
	local LITTLE_FREQ=""
	local CUR_FREQ=""
	for CURRENT_PROCESSOR in $(seq 0 `expr ${TOTAL_CPUS} - 1`); do
		if [ -f /sys/devices/system/cpu/cpu"${CURRENT_PROCESSOR}"/cpufreq/cpuinfo_max_freq ]; then
			DEC_FREQ=$(cat /sys/devices/system/cpu/cpu"${CURRENT_PROCESSOR}"/cpufreq/cpuinfo_max_freq)
			CUR_FREQ=$(printf '%x\n' ${DEC_FREQ})
		else
			CUR_FREQ="0"
		fi
		HEX_FREQ="${HEX_FREQ} ${CUR_FREQ}"
	done
	BIG_FREQ="$(echo "${HEX_FREQ}" | tr " " "\n" | sort -r | head -n 1)"
	LITTLE_FREQ="$(echo "${HEX_FREQ}" | tr " " "\n" | sort -r | tail -n 2)"
	echo "${HEX_FREQ}" | sed "s/${BIG_FREQ}/big/g; s/${LITTLE_FREQ}/little/g"
}

# This function gets the number of little cpus
#
# Returns:
# The number of big cpus
get_big_cpu_count(){
	get_big_little_cpu_types | tr " " "\n" | grep -wc big
}

# This function gets the number of little cpus
#
# Returns:
# The number of little cpus
get_little_cpu_count(){
	get_big_little_cpu_types | tr " " "\n" | grep -wc little
}

# This function gets the type of cpu
#
# Returns:
# "big" or "little"
get_big_little_cpu_type () {
	local CPU_ID="$(expr $1 + 1)"
	get_big_little_cpu_types | awk -v CPU_ID=${CPU_ID} '{print $CPU_ID}'
}

# This function checks if the cpu is big
#
# Parameters:
# $1 - the cpu core id to check
#
# Returns:
# Value 1 if true, 0 if false
is_cpu_big(){
	if [ "$(get_big_little_cpu_type $1)" == "big" ]; then
		return 0
	fi
	return 1
}

# This function checks if the cpu is little
#
# Parameters:
# $1 - the cpu core id to check
#
# Returns:
# Value 1 if true, 0 if false
is_cpu_little(){
	if [ "$(get_big_little_cpu_type $1)" == "little" ]; then
		return 0
	fi
	return 1
}

################################################################################
# Math utils
################################################################################

# This function returns the value of M^N
#
# NOTE: This function is NOT POSIX compatible
#
# Parameters:
# $1 - M
# $2 - N
#
# Returns:
# stdout - M^N
m_power_of_n() {
	local M=$1
	local N=$2
	local Y=$(($M**$N))
	echo "$Y"
}

# This function checks that the value of a variable is a number
#
# Parameters:
# $1 - input variable to check
#
# Returns:
# return value 0 if variable is a number, 1 if not
check_number() {
	local INPUT=$1
	local NUMBER='^[0-9]+$'
	if ! [[ ${INPUT} =~ ${NUMBER} ]]; then
		return 1
	fi
	return 0
}

################################################################################
# Initialization
################################################################################

START_TIME=$(date +%s)
if [ -z "${SCRIPTS_DIRECTORY}" ]; then
	SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
fi
PROGRAM_BASENAME="$(basename "$0")"
if [ -d "${SCRIPTS_DIRECTORY}/cip-test-data" ]; then
	DATA_DIRECTORY="$(cd "${SCRIPTS_DIRECTORY}/cip-test-data"; pwd)"
fi
if [ -z "${BINARIES_DIRECTORY}" ]; then
	BINARIES_DIRECTORY="/usr/bin"
fi
TMP_DIR="$(mktemp -d)"
if [ -n "${DEBUG}" ]; then
	cat<<-EOF | print_debug
	The temporary directory is:
	* ${TMP_DIR}
	Please delete it manually once done
	EOF
fi
TEST_SPECIFIC_CLEANUP_FUNCTION=""
