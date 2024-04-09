#!/bin/bash
#
# This script uses a given file or downloads a LAVA test job log, searches for
# the AI benchmark results markers and parses the performance metrics into a csv
# file that can be copied into the master results spreadsheet.
#
# Prerequisites:
# lavacli should be installed and ~/.config/lavacli.yaml configured correctly
# with the default identity set up to access the correct LAVA server.
#
# Parameters:
# $1: Log filename or LAVA test job number to process. Assumed to be valid.
#
# SPDX-License-Identifier: MIT
# Copyright (C) 2024 Renesas Electronics Corp.

################################################################################
# Global parameters

TEMP_FILE=$(mktemp)
MARKER="AI_BENCHMARK_MARKER"
OUTPUTFILE="benchmark_$(basename "${1}" | rev | cut -d'.' -f2- | rev).csv"

################################################################################
# Cleanup

cleanup () {
        if [ -n "${TEMP_FILE}" ]; then
                rm -rf "${TEMP_FILE}"
        fi
}

################################################################################
# Backups

get_backup_for_existing_file () {
        local FILENAME="${1}"
	BACKUP_FILE="${FILENAME}.bak"

	if [ -f "${FILENAME}" ]; then
		while [ -f "${BACKUP_FILE}" ]; do
			BACKUP_FILE="${BACKUP_FILE}.bak"
		done
		mv "${FILENAME}" "${BACKUP_FILE}"
		echo "INFO: ${FILENAME} already exists! created backup: ${BACKUP_FILE}"
	fi

}

restore_backup_file () {
	if [ -f "${BACKUP_FILE}" ]; then
		echo "Restoring "${BACKUP_FILE}" to "${OUTPUTFILE}""
		mv "${BACKUP_FILE}" "${OUTPUTFILE}"
	fi
}

################################################################################
# Lava Verification

check_lava_configuration () {
	# Check that the lavacli configuration is valid
	lavacli system whoami > /dev/null
	local RET=$?
	if [ ${RET} -eq 127 ]; then
		echo "lavacli is not installed. Please install."
		exit 1
	elif [ ${RET} -ne 0 ]; then
		echo "lavacli is not configured correctly. Please check ~/.config/lavacli.yaml."
		exit 1
	fi
}

################################################################################
# Main

if [ -z "${1}" ]; then
	echo "ERROR: Please provide log filename or LAVA job number"
	exit 1
fi

check_lava_configuration
get_backup_for_existing_file "${OUTPUTFILE}"

if [ -f "${1}" ]; then
	FILE="${1}"
	echo "Parsing log ${FILE}"

	# Search for $MARKER and remove timestamp
	grep -a "${MARKER}" "${FILE}" \
		| cut -d "," -f2- \
		> "${OUTPUTFILE}"
elif [[ "${1}" =~ ^[0-9]+$ ]]; then
	LAVA_JOB_NO=${1}
	echo "Downloading and parsing LAVA job #${LAVA_JOB_NO}"
	lavacli jobs show "${LAVA_JOB_NO}" > "${TEMP_FILE}"
	if [ $? -ne 0 ]; then
		echo "ERROR: could not view LAVA job information"
		restore_backup_file
		cleanup
		exit 1
	fi

	# Download lava log, search for $MARKER and remove timestamp
	if grep -q "state       : Finished" "${TEMP_FILE}"; then
		OUTPUT=$(lavacli jobs logs "${LAVA_JOB_NO}" | tr -d '\0')
		if [ $? -ne 0 ]; then
			echo "ERROR: could not view LAVA job log"
			restore_backup_file
			cleanup
			exit 1
		fi
		echo "${OUTPUT}" \
			| grep -a "${MARKER}" \
			| cut -d "," -f2- \
			> "${OUTPUTFILE}"
	else
		echo "ERROR: Job not finished. Please try again later"
		restore_backup_file
		cleanup
		exit 2
	fi
else
	echo "Invalid input: \""${1}"\" Please enter a filename or LAVA job number"
	exit 1
fi

# Add column headings
sed -i '1s/^/AI Framework,Model,Model Type,Average Model Prediction Time (ms),Standard Deviation (ms)\n/' "${OUTPUTFILE}"

if [ "$(wc -l < "${OUTPUTFILE}")" -eq 0 ]; then
	echo "ERROR: No logs found"
	rm "${OUTPUTFILE}"
	restore_backup_file
	cleanup
	exit 1
fi

echo "${OUTPUTFILE} created"
cleanup
