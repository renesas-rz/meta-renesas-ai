#!/usr/bin/env python

import cv2
import sys

if len(sys.argv) != 2:
    print('require parameters: Image name')
 
tensorflowNet = cv2.dnn.readNetFromTensorflow('/usr/bin/opencv/examples/opencv-models/frozen_inference_graph.pb', '/usr/bin/opencv/examples/opencv-models/ssd_mobilenet_v2_coco_2018_03_29.pbtxt')
 
img = cv2.imread(sys.argv[1])
rows, cols, channels = img.shape
 
tensorflowNet.setInput(cv2.dnn.blobFromImage(img, size=(300, 300), swapRB=True, crop=False))
 
networkOutput = tensorflowNet.forward()
 
for detection in networkOutput[0,0]:
    
    score = float(detection[2])
    if score > 0.2:
    	
        left = detection[3] * cols
        top = detection[4] * rows
        right = detection[5] * cols
        bottom = detection[6] * rows
 
        cv2.rectangle(img, (int(left), int(top)), (int(right), int(bottom)), (0, 0, 255), thickness=3)

cv2.imwrite("opencv-tensorflow-object-detection.jpg",img)
