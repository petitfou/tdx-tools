#!/bin/bash

echo "Run tdx guest"

KERNEL_VERSION=6.5.0-4-generic_6.5.0-4.4
#KOBUK_ARCHIVE=https://ppa.launchpadcontent.net/kobuk-team/tdx/ubuntu/
KOBUK_ARCHIVE=https://ppa.launchpadcontent.net/canonical-kernel-team/unstable/ubuntu/

rm -f linux-image-unsigned-${KERNEL_VERSION}_amd64.deb
wget ${KOBUK_ARCHIVE}/pool/main/l/linux-unstable/linux-image-unsigned-${KERNEL_VERSION}_amd64.deb
dpkg -x linux-image-unsigned-${KERNEL_VERSION}_amd64.deb extracted
cp extracted/boot/vmlinuz-* ./vmlinuz
rm -rf extracted

#qemu-system-x86_64 -enable-kvm -m 2048 -nic user,model=virtio -drive file=tdx-guest.qcow2,media=disk,if=virtio -nographic

#./start-qemu.sh -i ./tdx-guest.qcow2 -k ./vmlinuz

# docker

docker run -v ${PWD}:${PWD} -w $PWD --device=/dev/kvm tdx-host ./run-docker.sh
