FROM ubuntu:22.04

# Tell future scripts that user input isn't available during build.
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install git.
RUN apt-get update && apt-get install -y git

# Clone the bzt/posix-uefi repository.
# Ensure we are in root.
WORKDIR /
RUN git clone https://gitlab.com/bztsrc/posix-uefi.git

# Install UEFI development dependencies.
RUN apt-get update -y && apt-get install -y \
    build-essential \
    gcc \
    make \
    cmake \
    uuid-dev \
    libelf-dev \
    gnu-efi \
    mtools \
    dosfstools

# Install disk format tools.
RUN apt-get update -y && apt-get install -y \
    parted \
    udev

# Install QEMU and UEFI firmware.
RUN apt-get update -y && apt-get install -y \
    qemu-system-x86 \
    ovmf

# Copy the entrypoint script.
COPY /entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]