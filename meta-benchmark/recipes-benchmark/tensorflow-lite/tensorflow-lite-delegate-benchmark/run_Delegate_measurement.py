#!/usr/bin/env python2

'''
Copyright (C) 2022 Renesas Electronics Corp.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

'''

import glob
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
   print("TfLite Delegate Benchmarking App")

   if len(sys.argv) != 8 and len(sys.argv) != 9:
       print("Invalid parameters...")
       print("Expected parameters are:")
       print("1) Model List File    - A .txt file listing each model to be tested")
       print("2) Model Directory    - The path to the directory containing the models listed in (1)")
       print("3) Interference runs  - The number of times to run inference on each model")
       print("4) Number of Threads  - The number of threads to use")
       print("5) Delegate selection - The TfLite delegate to use [none|armnn|xnnpack]")
       print("6) ArmNN Log Level    - The level to set ArmNN to use [trace|debug|info|warning|error]")
       print("7) Compute            - The ArmNN backend to use [CpuRef|CpuAcc|GpuAcc]")
       print("8) Benchmark          - Optionally add \"benchmark\" to output benchmark results in a parsable format")
       print("Example: python run_Delegate_measurement.py test_model_list_delegate.txt /home/root/models/tensorflowlite/ 30 2 armnn warning GpuAcc benchmark")
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
   delegateType = sys.argv[5]
   armnnLogLevel = sys.argv[6]
   armnnCompute = sys.argv[7]

   if len(sys.argv) == 9:
     benchmark = sys.argv[8].lower() == 'benchmark'
   else:
     benchmark = False

   armnn_ver = glob.glob("/usr/bin/armnn-2*")
   armnn_ver = armnn_ver[0][-1-4:len(armnn_ver[0])]

   tfl_ver = glob.glob("/usr/bin/tensorflow-lite-2.*")
   tfl_ver = tfl_ver[0][-1-4:len(tfl_ver[0])]

   with open(filepath) as fp:
       for line in fp:
           if not len(line.strip()) == 0:
               model_details = line.split()
               list = []
               list_tmp = []

               if len(model_details) != 2:
                   print("Invalid line: " + line)
                   sys.exit(1)

               run_delegate_benchmark(model_details[0], base_directory_path, 'labels.txt', number_of_cores, number_of_iteration, list_tmp, list, delegateType, armnnLogLevel, armnnCompute)

               print("Average Time" + " at Model " + model_details[0] + str(Average(list_tmp)) + " ms ")
               print("Standard Deviation" + " at Model " + model_details[0] + str(Average(list)))

               if benchmark == True:
                   if delegateType == "armnn":
                       print("AI_BENCHMARK_MARKER,TensorFlow Lite v" + tfl_ver + " (Delegate: ArmNN v" + armnn_ver + " " + armnnCompute + ")," + model_details[0].rstrip().rsplit('/', 1)[1] +  "," +  model_details[1] + "," + str(Average(list_tmp)) + "," + str(Average(list)) + ",")
                   elif delegateType == "xnnpack":
                       print("AI_BENCHMARK_MARKER,TensorFlow Lite v" + tfl_ver + " (Delegate: XNNPack)," + model_details[0].rstrip().rsplit('/', 1)[1] +  "," +  model_details[1] + "," + str(Average(list_tmp)) + "," + str(Average(list)) + ",")
                   else:
                       print("AI_BENCHMARK_MARKER,TensorFlow Lite v" + tfl_ver + "," + model_details[0].rstrip().rsplit('/', 1)[1] +  "," +  model_details[1] + "," + str(Average(list_tmp)) + "," + str(Average(list)) + ",")

def Average(lst):
    return sum(lst) / len(lst)

def run_delegate_benchmark(model_file_name, base_directory, label_file_name, number_of_threads, times_to_run, list, list_dev, delegateType, armnnLogLevel, armnnCompute):
    command = "/usr/bin/tfLiteDelegateBenchmark/tfLiteDelegateBenchmark -i /usr/bin/tensorflow-lite/examples/grace_hopper.bmp -c %s -l %s -t %d -m %s -d %s -n %s -r %s" % (times_to_run, base_directory+label_file_name, number_of_threads, base_directory+model_file_name.rstrip(), delegateType, armnnLogLevel, armnnCompute)

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
