#!/bin/sh

export PYTHONPATH=$PYTHONPATH:/usr

SUCCESS=true

./caffe2_Benchmark.py squeezenet grace_hopper.jpg
if [ $? != 0 ]; then
	SUCCESS=false
fi

./caffe2_Benchmark.py mobilenetv2_1.0_224 grace_hopper.jpg
if [ $? != 0 ]; then
	SUCCESS=false
fi

if ! ${SUCCESS}; then
	>&2 echo "ERROR: One or more tests have failed."
	exit 2
fi
