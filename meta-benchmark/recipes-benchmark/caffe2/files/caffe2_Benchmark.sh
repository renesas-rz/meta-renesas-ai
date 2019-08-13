#!/bin/sh

export PYTHONPATH=$PYTHONPATH:/usr

./caffe2_Benchmark.py squeezenet grace_hopper.jpg

./caffe2_Benchmark.py mobilenetv2_1.0_224 grace_hopper.jpg
