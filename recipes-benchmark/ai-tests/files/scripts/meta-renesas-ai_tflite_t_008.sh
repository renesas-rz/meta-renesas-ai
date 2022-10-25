#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/tensorflow-lite/examples/

./benchmark_model \
    --graph=/home/root/models/tensorflowlite/Mobile_Net_V1_Model/mobilenet_v1_1.0_224_quant.tflite

if [ $? != 0 ]; then
	print_failure "Tflite benchmark_model exit failure"
fi

print_success "Tflite benchmark_model exit success"