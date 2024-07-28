OUTDIR=out
TARGET = boot.efi

include uefi/Makefile

DISK_STRUCTURE=disk_structure/
DISK_IMG = out/disk.img

create_disk:
	./scripts/create_disk.sh $(OUTDIR)/$(TARGET) $(DISK_STRUCTURE) $(DISK_IMG)

run_qemu:
	qemu-system-x86_64 \
		-drive file=$(DISK_IMG),format=raw,if=virtio \
		-bios /usr/share/ovmf/OVMF.fd

run: 
	# Clean build artifacts.
	make clean
	# Build bootloader (see definition in ./uefi/Makefile).
	make all 
	# Create and format disk.
	make create_disk
	# Run qemu.
	make run_qemu