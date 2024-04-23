#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnnBenchmark

OPTIONS=""

case "${RZG_LABEL}" in
	"rzg1e")
		OPTIONS="${OPTIONS} -i 10"
		;;
	"rzg2l" | "rzg2lc" | "rzv2l")
		# Turbo mode with GPU backend
		./armnnBenchmark -l model_list.txt -f -c GpuAcc
		# Set Turbo mode for CpuAcc tests
		OPTIONS="${OPTIONS} -f"
		;;
	"rzg2ul")
		# Set Turbo mode for CpuAcc tests
		OPTIONS="${OPTIONS} -f"
		;;
esac

./armnnBenchmark -l model_list.txt $OPTIONS
if [ $? != 0 ]; then
	print_failure "Arm NN benchmark exit failure"
fi

print_success "Arm NN benchmark exit success"
