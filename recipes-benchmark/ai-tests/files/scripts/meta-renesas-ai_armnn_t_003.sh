#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/SampleApp/

yes 1 | ./SimpleSample

if [ $? != 0 ]; then
	print_failure "Arm NN simple sample exit failure"
fi

print_success "Arm NN simple sample exit success"