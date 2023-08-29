FROM ubuntu:23.10

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install --no-install-recommends --yes build-essential \
        fakeroot devscripts wget git equivs liblz4-tool sudo python-is-python3 \
        pkg-config unzip curl xz-utils binutils cpio rpm2cpio python3-dev


# for guest image creation
RUN apt install --yes qemu-utils libguestfs-tools virtinst genisoimage
