#!/usr/bin/env python2

'''
Copyright (C) 2021 Renesas Electronics Corp.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

'''

import sys
import os
import subprocess
from subprocess import call
import numpy as np

# test file
# model root
# inference runs
# cores
# log level

def main():
   print("ArmNN TfLite Delegate Test App")

   if len(sys.argv) != 7 and len(sys.argv) != 8:
       print("Invalid parameters...")
       print("Expected parameters are:")
       print("1) Model List File    - A .txt file listing each model to be tested")
       print("2) Model Directory    - The path to the directory containing the models listed in (1)")
       print("3) Interference runs  - The number of times to run inference on each model")
       print("4) Number of Threads  - The number of threads to use")
       print("5) Delegate selection - The ArmNN delegate to use [none|tflite]")
       print("6) ArmNN Log Level    - The level to set ArmNN to use [trace|debug|info|warning|error]")
       print("7) Benchmark          - Optionally add \"benchmark\" to output benchmark results in a parsable format")
       print("Example: python run_Delegate_measurement.py test_model_list_armnnDelegate.txt /home/root/models/tensorflowlite/ 30 2 tflite warning benchmark")
       sys.exit(1)

   filepath = sys.argv[1]
   if not filepath:
       print("need to provide model list file")
       sys.exit(1)

   if not os.path.isfile(filepath):
       print("File path {} does not exist. Exiting...".format(filepath))
       sys.exit(1)

   # Retreive command line parameters
   base_directory_path = sys.argv[2]
   number_of_iteration = int(sys.argv[3])
   number_of_cores = int(sys.argv[4])
   armnnDelegate = sys.argv[5]
   armnnLogLevel = sys.argv[6]

   if len(sys.argv) == 8:
     benchmark = sys.argv[7].lower() == 'benchmark'
   else:
     benchmark = False

   with open(filepath) as fp:
       for line in fp:
           if not len(line.strip()) == 0:
               model_details = line.split()
               list = []
               list_tmp = []

               if len(model_details) != 2:
                   print("Invalid line: " + line)
                   sys.exit(1)

               run_delegate_benchmark(model_details[0], base_directory_path, './usr/bin/armnn/examples/tensorflow-lite/models/labels.txt', number_of_cores, number_of_iteration, list_tmp, list, armnnDelegate, armnnLogLevel)

               print("Average Time" + " at Model " + model_details[0] + str(Average(list_tmp)) + " ms ")
               print("Standard Deviation" + " at Model " + model_details[0] + str(Average(list)))
               print("\n")

               if benchmark == True:
                   print("AI_BENCHMARK_MARKER,Arm NN SDK v21.05 Delegate (" + armnnDelegate + ")," + model_details[0].rstrip().rsplit('/', 1)[1] +  "," +  model_details[1] + "," + str(Average(list_tmp)) + "," + str(Average(list)) + ",")

def Average(lst):
    return sum(lst) / len(lst)

def run_delegate_benchmark(model_file_name, base_directory, label_file_name, number_of_threads, times_to_run, list, list_dev, armnnDelegate, armnnLogLevel):
    command = "/usr/bin/armnnDelegateBenchmark/armnnTFLiteDelegateBenchmark -i /usr/bin/armnn-21.05/examples/grace_hopper.bmp -c %s -l %s -t %d -m %s -d %s -n %s" % (times_to_run, label_file_name, number_of_threads, base_directory+model_file_name.rstrip(), armnnDelegate, armnnLogLevel)

    for line in run_command(command):
        count = 0
        if line.find("Average Time") != -1:
            line = line.split(" ")
            list.insert(count, float(line[3]))
            count = count + 1
        elif line.find("Standard Deviation") != -1:
            line = line.split(" ")
            list_dev.insert(count, float(line[2]))
            break;


def run_command(command):
    p = subprocess.Popen(command,shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    return iter(p.stdout.readline, b'')

if __name__ == '__main__':
   main()
