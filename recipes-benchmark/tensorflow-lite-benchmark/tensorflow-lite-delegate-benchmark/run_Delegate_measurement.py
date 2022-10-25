#!/usr/bin/env python3

'''
Copyright (C) 2022 Renesas Electronics Corp.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

'''

import argparse
import glob
import sys
import os
import subprocess
from subprocess import call
import numpy as np

def main():
   print("TfLite Delegate Benchmarking App")

   args = argparse.ArgumentParser(description = "TfLite Delegate Benchmarking App \n Example Execution: python run_Delegate_measurement.py -f /usr/bin/tfLiteDelegateBenchmark/test_model_list_delegate.txt -b /home/root/models/tensorflowlite/ -i 5 -t 2 -d armnn -a warning -c CpuAcc -m True\n")
   args.add_argument("-b", "--base_dir", help = "Directory containing subdirectories, each containing label and model files", required = True)
   args.add_argument("-f", "--models_file", help = "File containing the list of models and data types", required = True)
   args.add_argument("-l", "--label_file", help = "[Optional] Path of the label file. Default: labels.txt", required = False, default = "labels.txt" )
   args.add_argument("-i", "--iterations", help = "[Optional] The number of times to run inference on each model. Default:10", required = False, default = "10")
   args.add_argument("-t", "--threads", help = "[Optional] The number of threads to use (does not apply to ArmNN Delegate. Default:2", required = False, default = 2, type = int)
   args.add_argument("-d", "--delegate", help = "[Optional] The TfLite delegate to use [none|armnn|xnnpack]", required = False, default = "none")
   args.add_argument("-c", "--compute", help = "[Optional] The ArmNN backend to use with the ArmNN delegate [CpuRef|CpuAcc|GpuAcc]", required = False, default = "CpuAcc")
   args.add_argument("-a", "--armnn_log_level", help = "[Optional] The level to set ArmNN Delegate to use [trace|debug|info|warning|error]", required = False, default = "warning")
   args.add_argument("-m", "--benchmark", help = "[Optional] Add \"benchmark\" to output benchmark results in a parsable format", required = False, action='store_true')

   # Retreive command line parameters
   argument = args.parse_args()

   if not argument.base_dir:
       print("Error: Please provide base directory (-b)")
       sys.exit(1)
   else:
       base_directory_path = argument.base_dir

   if not argument.models_file:
       print("Error: Please provide model file (-f)")
       sys.exit(1)
   else:
       filepath = argument.models_file

   if argument.label_file:
       label_file = argument.label_file
   if argument.iterations:
       number_of_iteration = argument.iterations
   if argument.threads:
       number_of_cores = argument.threads
   if argument.delegate:
       delegateType = argument.delegate
   if argument.compute:
       armnnCompute = argument.compute
   if argument.armnn_log_level:
       armnnLogLevel = argument.armnn_log_level
   if argument.benchmark:
       benchmark = True
   else:
       benchmark = False

   # Retreive Library versions
   armnn_ver = glob.glob("/usr/bin/armnn-2*")
   armnn_ver = armnn_ver[0][-1-4:len(armnn_ver[0])]

   tfl_ver = glob.glob("/usr/bin/tensorflow-lite-2.*")
   tfl_ver = tfl_ver[0][-1-4:len(tfl_ver[0])]

   # Retreive model and label files
   with open(filepath) as fp:
       for line in fp:
           if not len(line.strip()) == 0:
               model_details = line.split()
               list = []
               list_tmp = []

               if len(model_details) != 2:
                   print("Invalid line: " + line)
                   sys.exit(1)

               subdir = line.split('/')[0]

               # Start benchmark app
               run_delegate_benchmark(model_details[0], base_directory_path, base_directory_path+subdir+"/"+label_file, number_of_cores, number_of_iteration, list_tmp, list, delegateType, armnnLogLevel, armnnCompute)

               print("Average Time" + " at Model " + model_details[0] + ": "  + str(Average(list_tmp)) + " ms ")
               print("Standard Deviation" + " at Model " + model_details[0] + ": " + str(Average(list)))

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
    command = "/usr/bin/tfLiteDelegateBenchmark/tfLiteDelegateBenchmark -i /usr/bin/tensorflow-lite/examples/grace_hopper.bmp -c %s -l %s -t %d -m %s -d %s -n %s -r %s" % (times_to_run, label_file_name, number_of_threads, base_directory+model_file_name.rstrip(), delegateType, armnnLogLevel, armnnCompute)

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
                         stderr=subprocess.STDOUT, text=True)
    return iter(p.stdout.readline, b'')

if __name__ == '__main__':
   main()
