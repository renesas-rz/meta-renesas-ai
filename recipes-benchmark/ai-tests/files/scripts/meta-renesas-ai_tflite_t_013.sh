#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

CORES=$(get_active_cpu_count)

cd /usr/bin/tensorflow-lite/examples/

python3 label_image.py \
--model_file /home/root/models/tensorflowlite/Mobile_Net_V1_Model/mobilenet_v1_1.0_224_quant.tflite \
--label_file /home/root/models/tensorflowlite/Mobile_Net_V1_Model/labels.txt \
--image /usr/bin/tensorflow-lite/examples/grace_hopper.bmp \
--num_threads ${CORES}

if [ $? != 0 ]; then
	print_failure "Tflite Python Module test execution exit failure"
fi

print_success "Tflite Python Module test exit success"
