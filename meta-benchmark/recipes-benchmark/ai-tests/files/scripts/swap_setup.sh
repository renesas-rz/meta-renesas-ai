#!/bin/bash

SCRIPTS_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
. "${SCRIPTS_DIRECTORY}"/common_utils.sh
. "${SCRIPTS_DIRECTORY}"/identity.sh

dev_found=0

mmc_device_exists() {
	if [ -b "$1" ]; then
		echo 1
	else
		echo 0
	fi
}

SWAP_DEVICE=/dev/mmcblk0
dev_found=$(mmc_device_exists $SWAP_DEVICE)
if [ "$dev_found" -eq "0" ]; then
	SWAP_DEVICE=/dev/mmcblk1
	dev_found=$(mmc_device_exists $SWAP_DEVICE)
fi

if [ "$dev_found" -eq "0" ]; then
	print_failure "swap setup failed. mmcblk0/1 block device missing!"
fi

umount "$SWAP_DEVICE"p*
mkdir -p /mnt/mmcswap
mount "$SWAP_DEVICE"p1 /mnt/mmcswap
if [ ! -f /mnt/mmcswap/swapfile ]; then
	umount /mnt/mmcswap || true
	umount "$SWAP_DEVICE"p* || true
	echo -e "o\nn\np\n1\n\n\nw" | fdisk "$SWAP_DEVICE"
	mkfs.ext4 -F "$SWAP_DEVICE"p1
	mkdir -p /mnt/mmcswap
	mount "$SWAP_DEVICE"p1 /mnt/mmcswap
	dd if=/dev/zero of=/mnt/mmcswap/swapfile bs=1024 count=2000000
	if [ "$?" -ne "0" ]; then
		print_failure "Failed to create swap area!"
	fi
	chmod 0600 /mnt/mmcswap/swapfile
fi

mkswap /mnt/mmcswap/swapfile
if [ "$?" -ne "0" ]; then
	print_failure "Failed to setup swap area!"
fi

swapon /mnt/mmcswap/swapfile
if [ "$?" -ne "0" ]; then
	print_failure "Failed to enable swap area!"
fi

print_success "Swap setup successful"
