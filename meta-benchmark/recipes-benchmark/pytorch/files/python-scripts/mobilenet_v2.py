import sys
import time
import argparse
import numpy as np
from PIL import Image
import torch
from torchvision import models
from torchvision import transforms

parser = argparse.ArgumentParser(description='Mobilenet v2 Inference')
parser.add_argument('Model')
parser.add_argument('ModelType')
parser.add_argument('Label')
parser.add_argument('Image')
parser.add_argument('--count', dest='Inference Count', type=int, default=30, help='Change inference count, default is 30')

args = parser.parse_args()
argv = vars(args)

model_location = argv['Model']
model_type = argv['ModelType']
label_location = argv['Label']
image_location = argv['Image']
inference_count = argv['Inference Count']

print("Model is ", model_location)
print("Model Type is ", model_type)
print("Label is ", label_location)
print("Image is ", image_location)
print("Inference count is ", inference_count)

mobilenet_v2 = models.mobilenet_v2()
mobilenet_v2.load_state_dict(torch.load(model_location))

with open(label_location) as f:
    labels = [line.strip() for line in f.readlines()]

transform = transforms.Compose([
    transforms.Resize(256),                    #resize image to 256x256
    transforms.CenterCrop(224),                #crop image to 224x224
    transforms.ToTensor(),                     #convert to pytorch tensor
    transforms.Normalize(                      #normalize image
    mean=[0.485, 0.456, 0.406],                #by mean
    std=[0.229, 0.224, 0.225]                  #and std
    )])

img = Image.open(image_location)
img_transform = transform(img)
batch_transform = torch.unsqueeze(img_transform, 0)

mobilenet_v2.eval()

inference_times = np.empty(inference_count)

out = mobilenet_v2(batch_transform) # Warm up

for i in range(inference_count):
    start_time = time.time()
    out = mobilenet_v2(batch_transform)
    end_time = (time.time() - start_time) * 1000
    np.put(inference_times,i,end_time)

total_time = np.sum(inference_times)
average_time = np.mean(inference_times)
standard_deviation = np.std(inference_times)

print("Total time = {0:.2f}ms".format(total_time))
print("Average time = {0:.2f}ms".format(average_time))
print("Standard deviation = {0:.2f}ms".format(standard_deviation))

percentage = torch.nn.functional.softmax(out, dim=1)[0] * 100

_, indices = torch.sort(out, descending=True)
for idx in indices[0][:5]:
    print((labels[idx], percentage[idx].item()))

print("AI_BENCHMARK_MARKER,PyTorch v1.5.1,{0},{1},{2:.2f},{3:.2f},".format(model_location.strip(), model_type.strip(), average_time, standard_deviation))
