#!/bin/bash

# Docker entrypoint for building the POSIX-UEFI bootloader.
# This script expects that bzt/posix-uefi is mounted at /posix-uefi

echo "🧭 Symlinking /posix-uefi/uefi to /bootloader/uefi..."

mkdir -p /bootloader
cd /bootloader && ln -s -f /posix-uefi/uefi

git config --global --add safe.directory /bootloader

sleep infinity