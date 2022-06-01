#!/bin/bash
#
# This script prepares and submit LAVA job definitions.
# It is assumed that lavacli.yml has been configured as required.
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

	USAGE: $0 -p PLATFORM -t DIR -u USERNAME [-a DIR] [-f FRAMEWORK] [-h]

	MANDATORY:
	-p, --platform PLATFORM      Specify Yocto machine  name.
	-t, --templates DIR          Specify location of LAVA templates.
	-u, --lava-username USERNAME LAVA username to use to submit jobs.

	OPTIONAL:
	-a, --artifacts-dir DIR      Directory containing build artifacts.
	                             If not specified the default for DIR is
	                             "output/\$PLATFORM".
	-f, --framework FRAMEWORK    Include tests for this framework.
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
			ARTIFACTS_DIR="$(realpath ${2})"
			shift
			;;
		-f|--framework)
			FRAMEWORKS+=( "${2}" )
			shift
			;;
		-p|--platform)
			PLATFORM="${2}"
			shift
			;;
		-t|--templates)
			if [ ! -d "$2" ]; then
				echo "ERROR: Specificed LAVA templates directory does not exist"
				print_help
				clean_up
				exit 1
			fi
			LAVA_TEMPLATES_DIR="$(realpath ${2})"
			shift
			;;
		-u|--lava-username)
			LAVA_USERNAME="${2}"
			shift
			;;
		-h|--help)
			print_help
			shift
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
}

create_combined_job_template () {
	local job_template="${TMP_DIR}"/job_template.yaml

	cat "${LAVA_TEMPLATES_DIR}"/header.yaml > "${job_template}"
	cat "${LAVA_TEMPLATES_DIR}"/metadata.yaml >> "${job_template}"
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
	local rzg2m_files=("Image-hihope-rzg2m.bin" "Image-r8a774a1-hihope-rzg2m-ex.dtb" "core-image-qt-hihope-rzg2m.tar.gz")
	local rzg2n_files=("Image-hihope-rzg2n.bin" "Image-r8a774b1-hihope-rzg2n-ex.dtb" "core-image-qt-hihope-rzg2n.tar.gz")
	local rzg2e_files=("Image-ek874.bin" "Image-r8a774c0-ek874.dtb" "core-image-qt-ek874.tar.gz")
	local rzg2l_files=("Image-smarc-rzg2l.bin" "r9a07g044l2-smarc-smarc-rzg2l.dtb" "core-image-qt-smarc-rzg2l.tar.gz")
	local rzg2lc_files=("Image-smarc-rzg2lc.bin" "r9a07g044c2-smarc-smarc-rzg2lc.dtb" "core-image-qt-smarc-rzg2lc.tar.gz")
	local rzg2ul_files=("Image-smarc-rzg2ul.bin" "r9a07g043u11-smarc-smarc-rzg2ul.dtb" "core-image-qt-smarc-rzg2ul.tar.gz")
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
# $1: Job template file
submit_job () {
	local job_url=$(lavacli jobs submit "${1}" --url)
	echo "${job_url}"
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
if [[ "${JOB_LINK}" == "http"* ]]; then
	echo "LAVA job submitted: ${JOB_LINK}"
else
	echo "ERROR: LAVA job submission failed: ${JOB_LINK}"
	clean_up
	exit 1
fi

clean_up

