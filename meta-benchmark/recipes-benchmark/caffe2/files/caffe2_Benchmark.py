#!/usr/bin/env python2

'''
Copyright (C) 2019 Renesas Electronics Corp.
This file is licensed under the terms of the MIT License
This program is licensed "as is" without any warranty of any
kind, whether express or implied.
'''

CAFFE_MODELS = "./models/"
import sys
IMAGE_LOCATION = sys.argv[2]

print "Image is ", IMAGE_LOCATION

MODEL_squeezenet = 'squeezenet', 'init_net.pb', 'predict_net.pb', 'ilsvrc_2012_mean.npy', 227
MODEL_mobilenetv2_1_0_224 = 'mobilenetv2', 'init_net.pb', 'predict_net.pb', 'ilsvrc_2012_mean.npy', 224

codes =  "./alexnet_codes"
from datetime import datetime
t1 = datetime.now()

MODEL_MAP = {
    "squeezenet" : MODEL_squeezenet,
    "mobilenetv2_1.0_224" : MODEL_mobilenetv2_1_0_224
}

MODEL_NAME = sys.argv[1]

MODEL = MODEL_MAP.get(MODEL_NAME)

if MODEL == None:
    raise ValueError('Unsupported model ' + MODEL_NAME)

from caffe2.proto import caffe2_pb2
import numpy as np
import os
from caffe2.python import core, workspace
import urllib2
import cv2


def crop_center(img,cropx,cropy):
    y,x,c = img.shape
    startx = x//2-(cropx//2)
    starty = y//2-(cropy//2)
    return img[starty:starty+cropy,startx:startx+cropx]

def rescale(img, input_height, input_width):
    print("Original image shape:" + str(img.shape) + " and remember it should be in H, W, C!")
    print("Model's input shape is %dx%d") % (input_height, input_width)
    aspect = img.shape[1]/float(img.shape[0])
    print("Orginal aspect ratio: " + str(aspect))
    if(aspect>1):
        # landscape orientation - wide image
        res = int(aspect * input_height)
        imgScaled = cv2.resize(img, (input_width, res))
    if(aspect<1):
        # portrait orientation - tall image
        res = int(input_width/aspect)
        imgScaled = cv2.resize(img, (res, input_height))
    if(aspect == 1):
        imgScaled = cv2.resize(img, (input_width, input_height))
    print("New image shape:" + str(imgScaled.shape) + " in HWC")
    return imgScaled
print "Functions set."

# set paths and variables from model choice and prep image
CAFFE_MODELS = os.path.expanduser(CAFFE_MODELS)

print "--> Caffe2 models", CAFFE_MODELS

# mean can be 128 or custom based on the model
# gives better results to remove the colors found in all of the training images
MEAN_FILE = os.path.join(CAFFE_MODELS, MODEL[0], MODEL[3])
if not os.path.exists(MEAN_FILE):
    mean = 128
else:
    mean = np.load(MEAN_FILE).mean(1).mean(1)
    mean = mean[:, np.newaxis, np.newaxis]
print "mean was set to: ", mean

t2 = datetime.now()
# some models were trained with different image sizes, this helps you calibrate your image
INPUT_IMAGE_SIZE = MODEL[4]

# make sure all of the files are around...
INIT_NET = os.path.join(CAFFE_MODELS, MODEL[0], MODEL[1])
print 'INIT_NET = ', INIT_NET
PREDICT_NET = os.path.join(CAFFE_MODELS, MODEL[0], MODEL[2])
print 'PREDICT_NET = ', PREDICT_NET
if not os.path.exists(INIT_NET):
    print(INIT_NET + " not found!")
else:
    print "Found ", INIT_NET, "...Now looking for", PREDICT_NET
    if not os.path.exists(PREDICT_NET):
        print "Caffe model file, " + PREDICT_NET + " was not found!"
    else:
        print "All needed files found! Loading the model in the next block."

t3 = datetime.now()
# load and transform image
img = cv2.imread(IMAGE_LOCATION).astype(np.float32)
img = rescale(img, INPUT_IMAGE_SIZE, INPUT_IMAGE_SIZE)
img = crop_center(img, INPUT_IMAGE_SIZE, INPUT_IMAGE_SIZE)
print "After crop: " , img.shape

t4 = datetime.now()
# switch to CHW
img = img.swapaxes(1, 2).swapaxes(0, 1)

# switch to BGR
img = img[(2, 1, 0), :, :]

if MODEL_NAME == 'squeezenet':
    img = img * 255 - 128

elif MODEL_NAME == 'mobilenetv2_1.0_224':
    img = img / 255
else:
    raise ValueError('Unsupported model ' + MODEL_NAME)


# add batch size
img = img[np.newaxis, :, :, :].astype(np.float32)
print "NCHW: ", img.shape


t5 = datetime.now()
# initialize the neural net

with open(INIT_NET, 'rb') as f:
    init_net = f.read()
with open(PREDICT_NET, 'rb') as f:
    predict_net = f.read()

p = workspace.Predictor(init_net, predict_net)

test_loop_count = 30
i = 0
timingResult = np.array([],dtype = float)

while i < test_loop_count:

    i = i + 1

    t6 = datetime.now()
    # run the net and return prediction
    results = p.run([img])

    t7 = datetime.now()
    # the rest of this is digging through the results

    timingResult = np.append(timingResult,(t7 - t6).total_seconds() * 1000)

    print "Caffe2 Prediction time(msecs) this round: ", (t7 - t6).total_seconds() * 1000

#Caculate Means and STD
print "Caffe2 Prediction Average time(msecs): ",np.mean(timingResult)
print "Caffe2 Prediction STD: ",np.std(timingResult)
