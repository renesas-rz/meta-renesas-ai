#!/bin/sh

#Copyright (C) 2019 Renesas Electronics Corp. 
#This file is licensed under the terms of the MIT License
#This program is licensed "as is" without any warranty of any
#kind, whether express or implied.

cd /usr/bin/onnxruntime_benchmark/

filename="test_file_list_models.txt"

SUCCESS=true
MAX_RUN_COUNT=30

if [ ! -z "$1" ]; then
     MAX_RUN_COUNT=$1
fi

while read -r line; do
    name="$line"

    #CPU Usage
    ./onnxruntime_benchmark $MAX_RUN_COUNT $name
    if [ $? != 0 ]; then
        SUCCESS=false
    fi
done < "$filename"

if ! ${SUCCESS}; then
	>&2 echo "ERROR: One or more tests have failed."
	exit 2
fi
