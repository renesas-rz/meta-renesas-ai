#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

CORES=$(get_active_cpu_count)
BIG_CORES=$(get_big_cpu_count)
LOOP_INFERENCE=30
BACKENDS=("CpuAcc")
DELEGATES=("armnn")
BENCHMARK_DIR="/usr/bin/tfLiteDelegateBenchmark"

case "${RZG_LABEL}" in
	"rzg1e")
		LOOP_INFERENCE=10
		;;
	"rzg2l" | "rzg2lc")
		LOOP_INFERENCE=10
		BACKENDS+=("GpuAcc")
		DELEGATES+=("xnnpack")
		;;
	"rzg2ul")
		LOOP_INFERENCE=10
		DELEGATES+=("xnnpack")
esac

cd $BENCHMARK_DIR

if [ ${BIG_CORES} -lt ${CORES} ]; then

	for DELEGATE in "${DELEGATES[@]}"; do
		if [ "$DELEGATE" == "armnn" ]; then
			for BACKEND in "${BACKENDS[@]}"; do
				./run_Delegate_measurement.py -f $BENCHMARK_DIR/test_model_list_delegate.txt \
					-b /home/root/models/tensorflowlite/ -i $LOOP_INFERENCE -t "${BIG_CORES}" -d $DELEGATE \
					-a warning -c $BACKEND --benchmark

				if [ $? != 0 ]; then
					print_failure "ArmNN ($BACKEND) TfLite Delegate big cores benchmark exit failure"
				fi
			done
		else
			./run_Delegate_measurement.py -f $BENCHMARK_DIR/test_model_list_delegate.txt \
				-b /home/root/models/tensorflowlite/ -i $LOOP_INFERENCE -t "${BIG_CORES}" -d $DELEGATE \
				--benchmark

			if [ $? != 0 ]; then
				print_failure "$DELEGATE TfLite Delegate big cores benchmark exit failure"
			fi
		fi
	done

	for DELEGATE in "${DELEGATES[@]}"; do
		if [ "$DELEGATE" == "armnn" ]; then
			for BACKEND in "${BACKENDS[@]}"; do
				./run_Delegate_measurement.py -f $BENCHMARK_DIR/test_model_list_delegate.txt \
					-b /home/root/models/tensorflowlite/ -i $LOOP_INFERENCE -t "${CORES}" -d $DELEGATE \
					-a warning -c $BACKEND

				if [ $? != 0 ]; then
					print_failure "ArmNN ($BACKEND) TfLite Delegate all cores benchmark exit failure"
				fi
			done
		else
			./run_Delegate_measurement.py -f $BENCHMARK_DIR/test_model_list_delegate.txt \
				-b /home/root/models/tensorflowlite/ -i $LOOP_INFERENCE -t "${CORES}" -d $DELEGATE \

			if [ $? != 0 ]; then
				print_failure "$DELEGATE TfLite Delegate all cores benchmark exit failure"
			fi
		fi
	done

else
	for DELEGATE in "${DELEGATES[@]}"; do
		if [ "$DELEGATE" == "armnn" ]; then
			for BACKEND in "${BACKENDS[@]}"; do
				if [[ "$BACKEND" == "GpuAcc" && "$RZG_LABEL" == "rzg2lc" ]]; then
					echo "Using low memory model list..."
					MODEL_LIST=test_model_list_delegate_low_mem.txt
				else
					MODEL_LIST=test_model_list_delegate.txt
				fi

				./run_Delegate_measurement.py -f $BENCHMARK_DIR/$MODEL_LIST \
					-b /home/root/models/tensorflowlite/ -i $LOOP_INFERENCE -t "${CORES}" -d $DELEGATE \
					-a warning -c $BACKEND --benchmark

				if [ $? != 0 ]; then
					print_failure "ArmNN ($BACKEND) TfLite Delegate benchmark exit failure"
				fi
			done
		else
			./run_Delegate_measurement.py -f $BENCHMARK_DIR/test_model_list_delegate.txt \
				-b /home/root/models/tensorflowlite/ -i $LOOP_INFERENCE -t "${CORES}" -d $DELEGATE \
				--benchmark

			if [ $? != 0 ]; then
				print_failure "$DELEGATE TfLite Delegate benchmark exit failure"
			fi
		fi
	done
fi
print_success "TfLite Delegate benchmark exit success"
