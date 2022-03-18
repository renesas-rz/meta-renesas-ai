#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/tensorflow-lite/examples/

./label_image \
    --tflite_model /home/root/models/tensorflowlite/Mobile_Net_V1_Model/mobilenet_v1_1.0_224_quant.tflite \
    --labels /home/root/models/tensorflowlite/Mobile_Net_V1_Model/labels.txt

if [ $? != 0 ]; then
	print_failure "Tflite label_image exit failure"
fi

print_success "Tflite label_image exit success"