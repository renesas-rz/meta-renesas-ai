#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/onnxruntime/examples/unittest/

./onnx_test_runner squeezenet

if [ $? != 0 ]; then
	print_failure "ONNX Runtime unit test exit failure"
fi

print_success "ONNX Runtime unit test exit success"
