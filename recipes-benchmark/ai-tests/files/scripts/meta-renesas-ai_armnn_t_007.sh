#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/ExecuteNetwork/
./ExecuteNetwork \
	-d /usr/bin/armnn/examples/images/rsz_grace_hopper.csv \
	-m /usr/bin/armnn/examples/tensorflow-lite/models/mobilenet_v1_1.0_224_quant.tflite \
	-c CpuAcc

if [ $? != 0 ]; then
		print_failure "Arm NN ExecuteNetwork exit failure"
fi

print_success "Arm NN ExecuteNetwork exit success"
