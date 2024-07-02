# gg_os

## Run Bootloader Dev Environment

```bash
docker compose run bootloader-dev
# Inside container: test UEFI with alpine image.
apt-get update -y && apt-get install -y curl
curl https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso -o alpine.iso
qemu-system-x86_64 \
    -bios /usr/share/OVMF/OVMF_CODE.fd \
    -drive file=alpine.iso,format=raw \
    -enable-kvm \
    -m 2G
```
