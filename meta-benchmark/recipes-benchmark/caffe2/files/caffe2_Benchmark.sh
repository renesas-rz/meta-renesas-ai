#!/bin/sh

export PYTHONPATH=$PYTHONPATH:/usr

SUCCESS=true
MAX_RUN_COUNT=30

./caffe2_Benchmark.py squeezenet grace_hopper.jpg $MAX_RUN_COUNT
if [ $? != 0 ]; then
	SUCCESS=false
fi

./caffe2_Benchmark.py mobilenetv2_1.0_224 grace_hopper.jpg $MAX_RUN_COUNT
if [ $? != 0 ]; then
	SUCCESS=false
fi

if ! ${SUCCESS}; then
	>&2 echo "ERROR: One or more tests have failed."
	exit 2
fi
