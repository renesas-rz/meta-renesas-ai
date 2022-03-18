#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

cd /usr/bin/armnn/examples/UnitTests/

./UnitTests -- --dynamic-backend-build-dir "/usr/bin/armnn/examples/UnitTests/"

if [ $? != 0 ]; then
	print_failure "Arm NN unit test exit failure"
fi

print_success "Arm NN unit test exit success"
