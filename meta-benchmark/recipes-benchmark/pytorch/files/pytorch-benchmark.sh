#!/bin/sh

SUCCESS=true

python alexnet.py alexnet-owt-4df8aa71.pth imagenet_classes.txt grace_hopper.jpg

if [ $? != 0 ]; then
	SUCCESS=false
fi

python mnasnet.py mnasnet1.0_top1_73.512-f206786ef8.pth imagenet_classes.txt grace_hopper.jpg

if [ $? != 0 ]; then
	SUCCESS=false
fi

python mobilenet_v2.py mobilenet_v2-b0353104.pth imagenet_classes.txt grace_hopper.jpg

if [ $? != 0 ]; then
	SUCCESS=false
fi

python resnet152.py resnet152-b121ed2d.pth imagenet_classes.txt grace_hopper.jpg

if [ $? != 0 ]; then
	SUCCESS=false
fi

if (python -c "help('modules');" | grep -q scipy); then
	echo "scipy found, running Inception v3 benchmark..."
	python inception_v3.py inception_v3_google-1a9a5a14.pth imagenet_classes.txt grace_hopper.jpg
	if [ $? != 0 ]; then
		SUCCESS=false
	fi
else
	echo "scipy not found, skipping Inception v3 benchmark..."
fi

if ! ${SUCCESS}; then
	>&2 echo "ERROR: One or more tests have failed."
	exit 1
fi
