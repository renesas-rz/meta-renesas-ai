#!/usr/bin/env python2

'''
Copyright (C) 2019 Renesas Electronics Corp.
This file is licensed under the terms of the MIT License
This program is licensed "as is" without any warranty of any
kind, whether express or implied.
'''

import sys
import os
import commands
import subprocess
from subprocess import call
import numpy as np

def main():
   print("Tensorflow Lite Test App")

   if len(sys.argv) != 5 and len(sys.argv) != 6:
       print("invalid parameters")
       print("Example python run_TF_measurement.py test_file_list_Mobile_Net_V1.txt /home/root/models/mobileNetModels/Mobile_Net_V1_Modle/ 30 2 ")
       sys.exit()

   filepath = sys.argv[1]
   if not filepath:
       print("need to provide model list file")
       sys.exit()

   if not os.path.isfile(filepath):
       print("File path {} does not exist. Exiting...".format(filepath))
       sys.exit()

   base_direcotry_path = sys.argv[2]

   number_of_iteration = int(sys.argv[3])

   number_of_cores = int(sys.argv[4])

   if len(sys.argv) == 6:
     benchmark = sys.argv[5].lower() == 'benchmark'
   else:
     benchmark = False

   with open(filepath) as fp:
       for line in fp:
	   if not len(line.strip()) == 0:
	       list = []
	       list_tmp = []

	       run_label_image(line,base_direcotry_path,'labels.txt',number_of_cores,number_of_iteration,list_tmp,list)

	       print("Average Time" + " at Model " + line + str(Average(list_tmp)) + " ms ")
	       print("Standard Deviation" + " at Model " + line + str(Average(list)))
	       print("\n")

               if "quant" not in line:
                   model_type = ",Float,"
               else:
                   model_type = ",Quant,"

               if benchmark == True:
                   print("AI_BENCHMARK_MARKER,TensorFlow Lite v2.0.2," + line.rstrip() + model_type + str(Average(list_tmp)) + "," + str(Average(list)) + ",")

def Average(lst):
    return sum(lst) / len(lst)

def run_label_image(model_file_name,base_direcotry,label_file_name,number_of_threads,times_to_run,list,list_dev):
    command = "/usr/bin/tensorflow-lite-benchmark/tensorflow-lite-benchmark -i /usr/bin/tensorflow-lite/examples/grace_hopper.bmp -c %s -l %s -t %d -m %s" % (times_to_run, label_file_name, number_of_threads, base_direcotry+model_file_name)

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
