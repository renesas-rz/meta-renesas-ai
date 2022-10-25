#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/DelegateUnitTests/

./DelegateUnitTests --test-suite=*CpuRef*

if [ $? != 0 ]; then
	print_failure "Arm NN delegate unit test CpuRef exit failure"
fi

./DelegateUnitTests --test-suite=*CpuAcc*

if [ $? != 0 ]; then
	print_failure "Arm NN delegate unit test CpuAcc exit failure"
fi

case "${RZG_LABEL}" in
	"rzg2l" | "rzg2lc")
		./DelegateUnitTests --test-suite=*GpuAcc*
		if [ $? != 0 ]; then
			print_failure "Arm NN delegate unit test GpuAcc exit failure"
		fi
		;;
esac


print_success "Arm NN delegate unit test exit success"
