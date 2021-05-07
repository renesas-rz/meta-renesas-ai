#!/bin/bash

SUCCESS=true

echo "Running ... Squeezenet Onnx Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/opencv/squeezenet1.1.onnx --modeltype=float32 --width=224 --height=224 \
--classes=/usr/bin/opencv/examples/opencv-models/synset_words.txt --input=/usr/bin/opencvBenchmark/grace_hopper.jpg \
--mean="104 117 123" --rgb

if [ $? != 0 ]; then
	SUCCESS=false
fi

echo "Running ... Mobilenet v2 1.0 Onnx Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/opencv/mobilenetv2-1.0.onnx --modeltype=float32 --width=224 --height=224 \
--classes=/home/root/models/opencv/classification_classes_ILSVRC2012.txt --input=/usr/bin/opencvBenchmark/grace_hopper.jpg \
--scale="0.004" --mean="104 117 123" --rgb

if [ $? != 0 ]; then
	SUCCESS=false
fi

echo "Running ... Squeezenet v1.1 Caffe Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/opencv/squeezenet_v1.1.caffemodel --modeltype=float32 \
--config=/home/root/models/opencv/deploy.prototxt --width=224 --height=224 \
--classes=/usr/bin/opencv/examples/opencv-models/synset_words.txt \
--input=/usr/bin/opencvBenchmark/grace_hopper.jpg --mean="104 117 123" --rgb

if [ $? != 0 ]; then
	SUCCESS=false
fi

echo "Running ... Inception v3 float Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/opencv/inception_v3_2016_08_28_frozen.pb --modeltype=float32 \
--width=299 --height=299 --classes=/home/root/models/opencv/imagenet_slim_labels.txt \
--input=/usr/bin/opencvBenchmark/grace_hopper.jpg --scale="0.004" --mean="0 0 0" --rgb

if [ $? != 0 ]; then
	SUCCESS=false
fi

echo "Running ... Darknet19 Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/opencv/darknet19.weights --modeltype=float32 \
--config=/home/root/models/opencv/darknet19.cfg \
--width=256 --height=256 --classes=/home/root/models/opencv/imagenet.shortnames.list \
--input=/usr/bin/opencvBenchmark/grace_hopper.jpg --mean="0 0 0" --scale="0.004" --rgb

if [ $? != 0 ]; then
	SUCCESS=false
fi

echo "Running ... Darknet Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/opencv/darknet.weights --modeltype=float32 \
--config=/home/root/models/opencv/darknet.cfg \
--width=256 --height=256 --classes=/home/root/models/opencv/imagenet.shortnames.list --input=/usr/bin/opencvBenchmark/grace_hopper.jpg \
--mean="0 0 0" --scale="0.004" --rgb

if [ $? != 0 ]; then
	SUCCESS=false
fi

if ! ${SUCCESS}; then
	>&2 echo "ERROR: One or more tests have failed."
	exit 2
fi
