#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/onnxruntime_benchmark

LOOP_INFERENCE=30

case "${RZG_LABEL}" in
	"rzg1e" | "rzg2l" | "rzg2lc" | "rzv2l")
		LOOP_INFERENCE=10
		;;
esac

./onnxruntime_benchmark.sh $LOOP_INFERENCE

if [ $? != 0 ]; then
	print_failure "ONNX Runtime benchmark exit failure"
fi

print_success "ONNX Runtime benchmark exit success"
