#!/bin/bash
#
# This script prepares and submits LAVA job definitions.
#
# It is assumed that lavacli.yml has been configured as required. The default
# identity will be used.
# It is assumed that the ${BUILD_JOB_ID} variable is set to the GitLab CI job
# that contains the build artifacts that are to be tested.
#
# This script has been tested on Ubuntu 20.04.
#
# SPDX-License-Identifier: MIT
# Copyright (C) 2022 Renesas Electronics Corp.

set_up () {
	TMP_DIR="$(mktemp -d)"
}

clean_up () {
	rm -rf "$TMP_DIR"
}

print_help () {
	cat<<-EOF

	Create test job definitions and submit them to LAVA server.
	This script is designed to run in a GitLab CI environment.

	USAGE: $0 -p PLATFORM -t DIR -u USERNAME [-a DIR] [-f FRAMEWORK] \
	       [-j DIR] [-k FILE] [-r] [-h]

	MANDATORY:
	-p, --platform PLATFORM      Specify Yocto machine name.
	-t, --templates DIR          Specify location of LAVA templates.
	-u, --lava-username USERNAME LAVA username to use to submit jobs.

	OPTIONAL:
	-a, --artifacts-dir DIR      Directory containing build artifacts.
	                             If not specified the default for DIR is
	                             "output/\$PLATFORM".
	-f, --framework FRAMEWORK    Include tests for this framework.
	-j, --save-junit DIR         Export test results from LAVA in junit
	                             format. They will be called
	                             "results_<lava-job-no>.xml" and saved into
	                             the specified directory.
	                             Results will only be saved if
	                             --check-results is set.
	-k, --known-errors FILE      CSV formatted file detailing known issues.
	                             It lists devices that are expected to fail
	                             for each test case.
	                             If this file is provided test case failures
	                             that match will be ignored.
	                             Format: TEST_CASE,LAVA_DEVICE_TYPE1,
	                             LAVA_DEVICE_TYPE2,LAVA_DEVICE_TYPEn...
	                             --check-results must be set to use this
	                             functionality.
	-r, --check-results          After job is submitted, wait for test to
	                             run and get results.
	-h, --help                   Print this help and exit.

	EOF

	clean_up
	exit 0
}

parse_options () {
	while [[ $# -gt 0 ]]; do
		case $1 in
		-a|--artifacts-dir)
			if [ ! -d "$2" ]; then
				echo "ERROR: Specificed artifacts directory does not exist"
				print_help
				clean_up
				exit 1
			fi
			ARTIFACTS_DIR="$(realpath "${2}")"
			shift
			;;
		-f|--framework)
			FRAMEWORKS+=( "${2}" )
			shift
			;;
		-j|--save-junit)
			if [ ! -d "$2" ]; then
				echo "ERROR: Specificed directory does not exist"
				print_help
				clean_up
				exit 1
			fi
			JUNIT_DIR="$(realpath "${2}")"
			shift
			;;
		-k|--known-errors)
			if [ ! -f "$2" ]; then
				echo "ERROR: Specified known errors csv file does not exist"
				print_help
				clean_up
				exit 1
			fi
			KNOWN_ERRORS="$(realpath "${2}")"
			shift
			;;
		-p|--platform)
			PLATFORM="${2}"
			shift
			;;
		-r|--check-results)
			CHECK_FOR_RESULTS=true
			;;
		-t|--templates)
			if [ ! -d "$2" ]; then
				echo "ERROR: Specificed LAVA templates directory does not exist"
				print_help
				clean_up
				exit 1
			fi
			LAVA_TEMPLATES_DIR="$(realpath "${2}")"
			shift
			;;
		-u|--lava-username)
			LAVA_USERNAME="${2}"
			shift
			;;
		-h|--help)
			print_help
			;;
		*)
			break
			;;
		esac
		shift
	done

	# Check manditory arguments
	if [ -z ${PLATFORM+x} ]; then
		echo "ERROR: Yocto machine name (-p or --platform) must be specified"
		print_help
		clean_up
		exit 1
	fi
	if [ -z ${LAVA_TEMPLATES_DIR+x} ]; then
		echo "ERROR: LAVA template directory (-t or --templates) must be specified"
		print_help
		clean_up
		exit 1
	fi
	if [ -z ${LAVA_USERNAME+x} ]; then
		echo "ERROR: LAVA username (-u or --lava-username) must be specified"
		print_help
		clean_up
		exit 1
	fi

	# Set defaults for optional arguments
	if [ -z ${ARTIFACTS_DIR+x} ]; then
		ARTIFACTS_DIR="output/${PLATFORM}"
	fi
	if [ -z ${CHECK_FOR_RESULTS+x} ]; then
		CHECK_FOR_RESULTS=false
	fi
}

create_combined_job_template () {
	local job_template="${TMP_DIR}"/job_template.yaml

	cat "${LAVA_TEMPLATES_DIR}"/header.yaml > "${job_template}"
	if [ ${CI} ]; then
		cat "${LAVA_TEMPLATES_DIR}"/metadata.yaml >> "${job_template}"
	fi
	cat "${LAVA_TEMPLATES_DIR}"/notify.yaml >> "${job_template}"
	cat "${LAVA_TEMPLATES_DIR}"/timeouts.yaml >> "${job_template}"
	cat "${LAVA_TEMPLATES_DIR}"/deploy.yaml >> "${job_template}"
	cat "${LAVA_TEMPLATES_DIR}"/boot.yaml >> "${job_template}"
	cat "${LAVA_TEMPLATES_DIR}"/test_setup_swap.yaml >> "${job_template}"

	for framework in "${FRAMEWORKS[@]}"; do
		cat "${LAVA_TEMPLATES_DIR}"/test_${framework}.yaml >> "${job_template}"
	done

	echo "${job_template}"
}

# $1: Platform
get_device_type () {
	local device_type

	# TODO move device type definition to external file
	case ${1} in
		hihope-rzg2h)
			device_type="r8a774e1-hihope-rzg2h-ex"
			;;
		hihope-rzg2m)
			device_type="r8a774a1-hihope-rzg2m-ex"
			;;
		hihope-rzg2n)
			device_type="r8a774b1-hihope-rzg2n-ex"
			;;
		ek874)
			device_type="r8a774c0-ek874"
			;;
		smarc-rzg2l)
			device_type="r9a07g044l2-smarc-rzg2l"
			;;
		smarc-rzg2lc)
			device_type="r9a07g044c2-smarc-rzg2lc"
			;;
		smarc-rzg2ul)
			device_type="r9a07g043u11-smarc-rzg2ul"
			;;
		smarc-rzv2l)
			device_type="r9a07g054l2-smarc-rzv2l"
			;;
		*)
			device_type="unknown"
			;;
	esac

	echo ${device_type}
}

# $1: Platform
get_login_prompt () {
	local login_prompt

	# TODO move definitions to external file
	case ${1} in
		hihope-rzg2h)
			login_prompt="hihope-rzg2h login:"
			;;
		hihope-rzg2m)
			login_prompt="hihope-rzg2m login:"
			;;
		hihope-rzg2n)
			login_prompt="hihope-rzg2n login:"
			;;
		ek874)
			login_prompt="ek874 login:"
			;;
		smarc-rzg2l)
			login_prompt="smarc-rzg2l login:"
			;;
		smarc-rzg2lc)
			login_prompt="smarc-rzg2lc login:"
			;;
		smarc-rzg2ul)
			login_prompt="smarc-rzg2ul login:"
			;;
		smarc-rzv2l)
			login_prompt="smarc-rzv2l login:"
			;;
		*)
			login_prompt="unknown"
			;;
	esac

	echo ${login_prompt}
}

# $1: Platform
get_prompt () {
	local prompt

	# TODO move definitions to external file
	case ${1} in
		hihope-rzg2h)
			prompt="root@hihope-rzg2h:~#"
			;;
		hihope-rzg2m)
			prompt="root@hihope-rzg2m:~#"
			;;
		hihope-rzg2n)
			prompt="root@hihope-rzg2n:~#"
			;;
		ek874)
			prompt="root@ek874:~#"
			;;
		smarc-rzg2l)
			prompt="root@smarc-rzg2l:~#"
			;;
		smarc-rzg2lc)
			prompt="root@smarc-rzg2lc:~#"
			;;
		smarc-rzg2ul)
			prompt="root@smarc-rzg2ul:~#"
			;;
		smarc-rzv2l)
			prompt="root@smarc-rzv2l:~#"
			;;
		*)
			prompt="unknown"
			;;
	esac

	echo ${prompt}
}

# $1: Platform
# $2: Filetype
get_filename () {
	# TODO move this out to config files
	local filetypes=("kernel" "dtb" "rfs")
	local rzg2h_files=("Image-hihope-rzg2h.bin" "Image-r8a774e1-hihope-rzg2h-ex.dtb" "core-image-qt-hihope-rzg2h.tar.gz")
	local rzg2m_files=("Image-hihope-rzg2m.bin" "Image-r8a774a3-hihope-rzg2m-ex.dtb" "core-image-qt-hihope-rzg2m.tar.gz")
	local rzg2n_files=("Image-hihope-rzg2n.bin" "Image-r8a774b1-hihope-rzg2n-ex.dtb" "core-image-qt-hihope-rzg2n.tar.gz")
	local rzg2e_files=("Image-ek874.bin" "Image-r8a774c0-ek874.dtb" "core-image-qt-ek874.tar.gz")
	local rzg2l_files=("Image-smarc-rzg2l.bin" "Image-r9a07g044l2-smarc.dtb" "core-image-qt-smarc-rzg2l.tar.gz")
	local rzg2lc_files=("Image-smarc-rzg2lc.bin" "Image-r9a07g044c2-smarc.dtb" "core-image-qt-smarc-rzg2lc.tar.gz")
	local rzg2ul_files=("Image-smarc-rzg2ul.bin" "Image-r9a07g043u11-smarc.dtb" "core-image-qt-smarc-rzg2ul.tar.gz")
	local rzv2l_files=("Image-smarc-rzv2l.bin" "Image-r9a07g054l2-smarc.dtb" "core-image-qt-smarc-rzv2l.tar.gz")
	local filename="unknown"

	# Get index number for filetype
	local index
	for i in "${!filetypes[@]}"; do
		if [[ "${filetypes[${i}]}" == "${2}" ]]; then
			index=${i}
		fi
	done

	if [ ! -z ${index} ]; then
		case ${1} in
		hihope-rzg2h)
			filename=${rzg2h_files[${index}]}
			;;
		hihope-rzg2m)
			filename=${rzg2m_files[${index}]}
			;;
		hihope-rzg2n)
			filename=${rzg2n_files[${index}]}
			;;
		ek874)
			filename=${rzg2e_files[${index}]}
			;;
		smarc-rzg2l)
			filename=${rzg2l_files[${index}]}
			;;
		smarc-rzg2lc)
			filename=${rzg2lc_files[${index}]}
			;;
		smarc-rzg2ul)
			filename=${rzg2ul_files[${index}]}
			;;
		smarc-rzv2l)
			filename=${rzv2l_files[${index}]}
			;;
		esac
	fi

	echo "${filename}"
}

# $1: Filename
get_gitlab_artifact_url () {
	local url="${CI_PROJECT_URL}/-/jobs/${BUILD_JOB_ID}/artifacts/raw/${ARTIFACTS_DIR}/${1}"
	echo "${url}"
}

# $1: Job template file
customise_template () {
	local job_template="${1}"

	local device_type=$(get_device_type ${PLATFORM})
	if [ ${device_type} == "unknown" ]; then
		echo "ERROR: There is no known LAVA device type for ${PLATFORM}"
		clean_up
		exit 1
	fi
	sed -i "s|PLACEHOLDER_DEVICE_TYPE|${device_type}|g" "${job_template}"

	if [ -z ${FRAMEWORKS} ]; then
		local job_name="RZ\/G AI BSP tests"
	else
		local job_name="RZ\/G AI BSP tests - ${FRAMEWORKS[*]}"
	fi
	sed -i "s|PLACEHOLDER_JOB_NAME|${job_name}|g" "${job_template}"

	sed -i "s|PLACEHOLDER_GITLAB_PIPELINE_URL|${CI_PIPELINE_URL}|g" "${job_template}"
	sed -i "s|PLACEHOLDER_GITLAB_JOB_URL|${CI_JOB_URL}|g" "${job_template}"
	sed -i "s|PLACEHOLDER_LAVA_USER|${LAVA_USERNAME}|g" "${job_template}"

	local filename="$(get_filename ${PLATFORM} "kernel")"
	if [ "${filename}" == "unknown" ]; then
		echo "ERROR: There is no known kernel filename for ${PLATFORM}"
		clean_up
		exit 1
	fi
	local url=$(get_gitlab_artifact_url "${filename}")
	sed -i "s|PLACEHOLDER_KERNEL_URL|${url}|g" "${job_template}"

	filename="$(get_filename ${PLATFORM} "rfs")"
	if [ "${filename}" == "unknown" ]; then
		echo "ERROR: There is no known rfs filename for ${PLATFORM}"
		clean_up
		exit 1
	fi
	url=$(get_gitlab_artifact_url "${filename}")
	sed -i "s|PLACEHOLDER_NFSROOTFS_URL|${url}|g" "${job_template}"

	filename="$(get_filename ${PLATFORM} "dtb")"
	if [ "${filename}" == "unknown" ]; then
		echo "ERROR: There is no known dtb filename for ${PLATFORM}"
		clean_up
		exit 1
	fi
	url=$(get_gitlab_artifact_url "${filename}")
	sed -i "s|PLACEHOLDER_DTB_URL|${url}|g" "${job_template}"

	local login_prompt=$(get_login_prompt ${PLATFORM})
	if [ "${login_prompt}" == "unknown" ]; then
		echo "ERROR: There is no known login prompt for ${PLATFORM}"
		clean_up
		exit 1
	fi
	sed -i "s|PLACEHOLDER_LOGIN_PROMPT|\"${login_prompt}\"|g" "${job_template}"

	local prompt=$(get_prompt ${PLATFORM})
	if [ "${prompt}" == "unknown" ]; then
		echo "ERROR: There is no known prompt for ${PLATFORM}"
		clean_up
		exit 1
	fi
	sed -i "s|PLACEHOLDER_PROMPT|\"${prompt}\"|g" "${job_template}"
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1:     Job template file
# return: URL to submitted job
submit_job () {
	local job_url=$(lavacli jobs submit "${1}" --url)
	echo "${job_url}"
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1: Submitted job number
wait_for_job_to_complete () {
	echo "========================================================================="
	for i in {1..10}; do
		lavacli jobs wait "${1}"
		if [[ $? -eq 0 ]]; then
			break
		fi

		if [[ $i -eq 10 ]]; then
			echo "Something is still wrong. Give up!"
		else
			echo "Something went awry. Let's try again..."
		fi
	done
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1: Submitted job number
get_job_results () {
	echo "========================================================================="
	lavacli results "${1}"
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1: Submitted job number
get_junit_results () {
	echo "========================================================================="
	# Extract server URL from LAVA CLI configuration file
	local lava_config_file="${HOME}/.config/lavacli.yaml"
	local lava_api_url=$(grep uri "${lava_config_file}" | \
			     cut -d " " -f 4 | \
		             sed 's|RPC2|api/v0.2|g')
	curl -s -o "${JUNIT_DIR}"/results_${1}.xml ${lava_api_url}/jobs/${1}/junit/
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1: Submitted job number
# return PASS: Job completed okay
#        FAIL: Job did not complete
get_job_result () {
	local lavacli_output=$TMP_DIR/lavacli_output
	lavacli jobs show "${1}" > ${lavacli_output}

	local health=$(cat "$lavacli_output" \
		| grep "Health" \
		| cut -d ":" -f 2 \
		| awk '{$1=$1};1')

	if [ "${health}" != "Complete" ]; then
		echo "FAIL"
	else
		echo "PASS"
	fi
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1: Submitted job number
# return: Number of failed test cases
get_test_case_failure_count () {
	local count=$(lavacli results "${1}" | grep -c "\[fail\]")
	echo ${count}
}

# This function assumes that ~/.config/lavacli.yaml is already configured
# $1: CSV formatted file detailing known issues. Format: TEST_CASE,LAVA_DEVICE_TYPE1,LAVA_DEVICE_TYPEn...
# $2: LAVA device type being tested
# $3: Submitted job number
# return: Number of failed test cases, once known issues have been ignored
get_new_test_case_failure_count () {
	local known_issues="${1}"
	local device="${2}"
	local lavacli_output=$TMP_DIR/lavacli_output
	local new_issue_count=0

	lavacli results "${3}" > "${lavacli_output}"
	if [ $? == 0 ]; then
		while read -r line; do
			if grep -q "fail" <<< "${line}"; then
				# Get test case name from LAVA output
				local test_case=$(echo "${line}" | awk -F'.' '{print $2}')
				test_case=$(echo "${test_case}" | awk -F' ' '{print $1}')

				# Seach known issues file for test case and
				# check to see if target platform is listed
				local known_issue=$(grep "${test_case}" "${known_issues}" | grep -c "${device}")
				if [ ${known_issue} == 0 ]; then
					((new_issue_count++))
				fi
			fi
		done < "${lavacli_output}"
	else
		# Something went wrong with obtaining the results.
		# Better to fail and trigger a manual check of results then
		# return a false positive.
		((new_issue_count++))
	fi

	echo ${new_issue_count}
}

trap clean_up SIGHUP SIGINT SIGTERM
set_up

parse_options "$@"

JOB_TEMPLATE=$(create_combined_job_template)
customise_template "${JOB_TEMPLATE}"
echo "========================================================================="
echo "GENERATED LAVA TEMPLATE"
echo "========================================================================="
cat ${JOB_TEMPLATE}

echo "========================================================================="
JOB_LINK=$(submit_job "${JOB_TEMPLATE}")
JOB_NO=$(echo ${JOB_LINK} | rev | cut -d "/" -f 1 | rev)
if [[ "${JOB_LINK}" == "http"* ]]; then
	echo "LAVA job #${JOB_NO} submitted: ${JOB_LINK}"
else
	echo "ERROR: LAVA job submission failed: ${JOB_LINK}"
	clean_up
	exit 1
fi

if ${CHECK_FOR_RESULTS}; then
	wait_for_job_to_complete ${JOB_NO}

	get_job_results ${JOB_NO}

	if [ ! -z ${JUNIT_DIR+x} ]; then
		get_junit_results ${JOB_NO}
	fi

	RESULT=$(get_job_result ${JOB_NO})
	if [ ${RESULT} != "PASS" ]; then
		echo "ERROR: Test job did not complete successfully"
		clean_up
		exit 1
	fi

	if [ -n "${KNOWN_ERRORS}" ]; then
		RESULT=$(get_new_test_case_failure_count ${KNOWN_ERRORS} \
				$(get_device_type ${PLATFORM}) ${JOB_NO})
		if [ ${RESULT} -gt "0" ]; then
			echo "ERROR: New test case failures found"
			clean_up
			exit 1
		fi
	else
		RESULT=$(get_test_case_failure_count ${JOB_NO})
		if [ ${RESULT} -gt "0" ]; then
			echo "ERROR: Test case failures found"
			clean_up
			exit 1
		fi
	fi
fi

clean_up
