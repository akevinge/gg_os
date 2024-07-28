#!/bin/sh

usage() {
    echo "Usage: $0 <EFI application> <efi_path> <disk_structure_to_mount> <out_disk_image>"
}

EFI_PATH=$1
DISK_STRUCTURE=$2
IMAGE_OUT=$3

# Temporary mount directory to build EFI partition.
TEMP_MNT_DIR=/tmp/mnt

if [ "$#" -ne 3 ]; then
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

# Copy all files and directories to the disk image.
# Ensure we're inside the directory to copy over.
# Otherwise we'll end up with the full path in the disk image.
# For example, if our disk structure is mountable_disk/test.txt,
# we want to copy over test.txt to the disk image, not mountable_disk/test.txt.
cd $DISK_STRUCTURE
for f in $(find . -type f -print); do
    cp --parents $f $TEMP_MNT_DIR/
done
cd ..

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