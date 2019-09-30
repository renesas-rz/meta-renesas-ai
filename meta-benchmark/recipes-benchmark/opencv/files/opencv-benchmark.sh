#!/bin/bash

echo "Running ... Squeezenet Onnx Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/onnx/squeezenet1.1.onnx --width=224 --height=224 \
--classes=/usr/bin/opencv/examples/opencv-models/synset_words.txt --input=/usr/bin/opencvBenchmark/grace_hopper.jpg \
--mean="104 117 123" --rgb

echo "Running ... Mobilenet v2 1.0 Onnx Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/onnx/mobilenetv2-1.0.onnx --width=224 --height=224 \
--classes=/home/root/models/onnx/classification_classes_ILSVRC2012.txt --input=/usr/bin/opencvBenchmark/grace_hopper.jpg \
--scale="0.004" --mean="104 117 123" --rgb

echo "Running ... Squeezenet v1.1 Caffe Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/caffe/squeezenet_v1.1.caffemodel \
--config=/home/root/models/caffe/deploy.prototxt --width=224 --height=224 \
--classes=/usr/bin/opencv/examples/opencv-models/synset_words.txt \
--input=/usr/bin/opencvBenchmark/grace_hopper.jpg --mean="104 117 123" --rgb

echo "Running ... Inception v3 float Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/tensorflow/InceptionV3/inception_v3_2016_08_28_frozen.pb \
--width=299 --height=299 --classes=/home/root/models/tensorflow/InceptionV3/imagenet_slim_labels.txt \
--input=/usr/bin/opencvBenchmark/grace_hopper.jpg --scale="0.004" --mean="0 0 0" --rgb

echo "Running ... Darknet19 Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/darknet/darknet19.weights \
--config=/home/root/models/darknet/darknet19.cfg \
--width=256 --height=256 --classes=/home/root/models/darknet/imagenet.shortnames.list \
--input=/usr/bin/opencvBenchmark/grace_hopper.jpg --mean="0 0 0" --scale="0.004" --rgb

echo "Running ... Darknet Model"

/usr/bin/opencvBenchmark/opencv-dnn-benchmark --model=/home/root/models/darknet/darknet.weights \
--config=/home/root/models/darknet/darknet.cfg \
--width=256 --height=256 --classes=/home/root/models/darknet/imagenet.shortnames.list --input=/usr/bin/opencvBenchmark/grace_hopper.jpg \
--mean="0 0 0" --scale="0.004" --rgb
