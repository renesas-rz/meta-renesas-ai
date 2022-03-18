#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

CORES=$(get_active_cpu_count)
BIG_CORES=$(get_big_cpu_count)
LOOP_INFERENCE=30

case "${RZG_LABEL}" in
	"rzg1e")
		LOOP_INFERENCE=10
		;;
	"rzg2l" | "rzg2lc" | "rzg2ul")
		LOOP_INFERENCE=10
		;;
esac

cd /usr/bin/tensorflow-lite-benchmark

if [ ${BIG_CORES} -lt ${CORES} ]; then
	./run_TF_measurement.py test_file_list_Mobile_Net_V1.txt \
		/home/root/models/tensorflowlite/Mobile_Net_V1_Model/ $LOOP_INFERENCE "${BIG_CORES}" benchmark

	if [ $? != 0 ]; then
		print_failure "Tflite Mobile_Net_V1_Model big cores benchmark exit failure"
	fi

	./run_TF_measurement.py test_file_list_Mobile_Net_V1.txt \
		/home/root/models/tensorflowlite/Mobile_Net_V1_Model/ $LOOP_INFERENCE "${CORES}"

	if [ $? != 0 ]; then
		print_failure "Tflite Mobile_Net_V1_Model all cores benchmark exit failure"
	fi
else
	./run_TF_measurement.py test_file_list_Mobile_Net_V1.txt \
		/home/root/models/tensorflowlite/Mobile_Net_V1_Model/ $LOOP_INFERENCE "${CORES}" benchmark

	if [ $? != 0 ]; then
		print_failure "Tflite Mobile_Net_V1_Model benchmark exit failure"
	fi
fi
print_success "Tflite Mobile_Net_V1_Model benchmark exit success"
