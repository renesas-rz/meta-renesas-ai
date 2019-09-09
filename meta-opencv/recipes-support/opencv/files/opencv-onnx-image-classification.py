#!/usr/bin/env python

import numpy as np
import cv2
import sys

if __name__ == '__main__':
    try:
        if len(sys.argv) != 2:
            print('require parameters: Image name')

        input_image = cv2.imread(sys.argv[1])
        if input_image is not None:
            resized = cv2.resize(input_image, (224, 224))

            blob = cv2.dnn.blobFromImage(resized)
            print(blob.shape)

            net = cv2.dnn.readNetFromONNX("/usr/bin/opencv/examples/opencv-models/model.onnx")

            net.setInput(blob)

            pred = np.squeeze(net.forward())

            rows = open("/usr/bin/opencv/examples/opencv-models/synset_words.txt").read().strip().split("\n")
            classes = [r[r.find(" ") + 1:].split(",")[0] for r in rows]

            indexes = np.argsort(pred)[::-1][:5]
            for i in indexes:
                text = "{}: {:.2f}%".format(classes[i], pred[i] * 100)
                print(text)
        else:
            print('can\'t read image')

    except cv2.error as e:
        print(e)
