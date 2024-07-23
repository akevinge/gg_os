#!/bin/sh

usage() {
    echo "Usage: $0 <EFI application> <efi_path> <disk image>"
}

EFI_PATH=$1
IMAGE_OUT=$2

# Temporary mount directory to build EFI partition.
TEMP_MNT_DIR=/tmp/mnt

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

# Remove the disk image file if it already exists.
rm -f $IMAGE_OUT

# Create a disk image file of 64MB.
dd if=/dev/zero of=$IMAGE_OUT bs=1M count=64

# Create a GPT partition table with a single FAT32 partition.
# UEFI systems require a FAT32 partition to boot from.
parted $IMAGE_OUT --script -- mklabel gpt
parted $IMAGE_OUT --script -- mkpart EFI FAT32 2048s 100%
# Set the partition type to EFI System for UEFI boot.
parted $IMAGE_OUT --script -- set 1 esp on

# Create a loop device from the disk image file.
LOOP_DEVICE=$(losetup --find --show --partscan $IMAGE_OUT)

# Format the first partition (EFI System Partition).
mkfs.fat -F32 ${LOOP_DEVICE}p1

# Mount the partition.
mkdir -p $TEMP_MNT_DIR
mount ${LOOP_DEVICE}p1 $TEMP_MNT_DIR

# Create the EFI directory structure.
mkdir -p $TEMP_MNT_DIR/EFI/BOOT

# Copy the EFI application.
cp $EFI_PATH $TEMP_MNT_DIR/EFI/BOOT/BOOTX64.EFI

# Ensure that the EFI application is fully written to the disk.
sync

# Run cleanup.
if [ -d mnt ]; then
    umount $TEMP_MNT_DIR
    rm -dfr $TEMP_MNT_DIR
fi

if [ -b "$LOOP_DEVICE" ]; then
    losetup -d "$LOOP_DEVICE"
fi