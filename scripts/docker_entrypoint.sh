#!/bin/bash

# Docker entrypoint for building the POSIX-UEFI bootloader.
# This script expects that bzt/posix-uefi is mounted at /posix-uefi

# Symlink /posix-efui to /bootloader/uefi.
echo "🧭 Symlinking /posix-uefi/uefi to /bootloader/uefi..."
mkdir -p /bootloader
cd /bootloader && ln -s -f /posix-uefi/uefi

# Sleep forever to keep container alive (for dev containers).
sleep infinity