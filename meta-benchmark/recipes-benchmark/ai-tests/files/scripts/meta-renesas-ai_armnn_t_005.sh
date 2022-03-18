#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/onnx

./OnnxMobileNet-Armnn -d /usr/bin/armnn/examples/images/ \
--model-dir /usr/bin/armnn/examples/onnx/models/ -c CpuAcc

if [ $? != 0 ]; then
	print_failure "Arm NN ONNX MobileNet exit failure"
fi

print_success "Arm NN ONNX MobileNet exit success"
