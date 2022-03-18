#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/tensorflow-lite

./TfLiteMobilenetQuantized-Armnn -d /usr/bin/armnn/examples/images/ \
--model-dir /usr/bin/armnn/examples/tensorflow-lite/models/ -c CpuAcc

if [ $? != 0 ]; then
	print_failure "Arm NN Tflite MobileNet exit failure"
fi

print_success "Arm NN Tflite MobileNet exit success"
