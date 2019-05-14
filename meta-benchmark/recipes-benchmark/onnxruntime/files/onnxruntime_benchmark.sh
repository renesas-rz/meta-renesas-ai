#!/bin/sh

#Copyright (C) 2019 Renesas Electronics Corp. 
#This file is licensed under the terms of the MIT License
#This program is licensed "as is" without any warranty of any
#kind, whether express or implied.

cd /usr/bin/onnxruntime_benchmark/

filename="test_file_list_models.txt"

while read -r line; do
    name="$line"

    #CPU Usage
    ./onnxruntime_benchmark 30 $name
done < "$filename"
