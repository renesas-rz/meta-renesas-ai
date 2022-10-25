#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/RenesasSample-Armnn/

./RenesasSample-Armnn

if [ $? != 0 ]; then
	print_failure "Arm NN Renesas sample exit failure"
fi

print_success "Arm NN Renesas sample exit success"