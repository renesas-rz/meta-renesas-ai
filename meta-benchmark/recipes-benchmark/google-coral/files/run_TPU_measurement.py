#!/usr/bin/env python2

'''
Copyright (C) 2020 Renesas Electronics Corp.
This file is licensed under the terms of the MIT License
This program is licensed "as is" without any warranty of any
kind, whether express or implied.

Script based on meta-benchmark/recipes-benchmark/tensorflow-lite/run_TF_measurement.py
'''

import sys
import os
import commands
import subprocess
from subprocess import call
import numpy as np

def main():
   print("Google Coral TPU Benchmark App")

   if len(sys.argv) != 4:
       print("invalid parameters")
       print("Example python run_TPU_measurement.py test_file_list_Resnet.txt /home/root/models/google-coral/Resnet 30")
       sys.exit()

   filepath = sys.argv[1]
   if not filepath:
       print("need to provide model list file")
       sys.exit()

   if not os.path.isfile(filepath):
       print("File path {} does not exist. Exiting...".format(filepath))
       sys.exit()

   base_directory_path = sys.argv[2]

   number_of_iteration = int(sys.argv[3])

   with open(filepath) as fp:
       for line in fp:
	   if not len(line.strip()) == 0:
	       list = []
	       list_tmp = []

	       run_label_image(line,base_directory_path,'labels.txt',number_of_iteration,list_tmp,list)

	       print("Average Time" + " at Model " + line + str(Average(list_tmp)) + " ms ")
               print("Standard Deviation" + " at Model " + line + str(Average(list)))

               print("\n")

def Average(lst):
    return sum(lst) / len(lst)

def run_label_image(model_file_name,base_directory,label_file_name,times_to_run,list,list_dev):
    command = "/usr/bin/google-coral-benchmark/google-coral-tpu-benchmark -i /usr/bin/google-coral/images/grace_hopper_224_224.bmp -c %s -l %s -m %s" % (times_to_run, label_file_name, base_directory+model_file_name)

    for line in run_command(command):
        count = 0
        if line.find("Average Time") != -1:
            line = line.split(" ")
            list.insert(count, float(line[3]))
            count = count + 1
        elif line.find("Standard Deviation") != -1:
            line = line.split(" ")
            list_dev.insert(count, float(line[2]))


def run_command(command):
    #Debug
    #print("Run Command: " + command)
    p = subprocess.Popen(command,shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    return iter(p.stdout.readline, b'')

if __name__ == '__main__':
   main()
