#!/bin/bash

sudo apt install docker.io

sudo usermod -a -G docker ubuntu
# force group membership to be effective without logout
#newgrp docker

echo "Build ..."
(cd build/ubuntu-22.04/ && ./pkg-builder build-repo.sh)

# create guest image
#(cd build/ubuntu-22.04/ && ./pkg-builder ./guest-image/create-ubuntu-image.sh -r ../guest_repo/ -f -o mytest.qcow2 -u tdx -p tdx -n tdx-guest)
sudo apt install qemu-utils libguestfs-tools virtinst genisoimage
# the qcow2 image will be in tmp
(cd build/ubuntu-22.04/guest-image/ && sudo ./create-ubuntu-image.sh -r ../guest_repo/ -f -o ./tdx-guest.qcow2 -u tdx -p tdx -n tdx-guest)

# install host
(cd build/ubuntu-22.04/host_repo/ && sudo apt -y --allow-downgrades --reinstall install ./*.deb)

# reboot host with new kernel
# check TDX enabled
# sudo dmesg | grep -i tdx

# set root password for the image
#sudo virt-customize -a tdx-guest.qcow2 --root-password password:root


# can we run guest image with normal qemu
# qemu-system-x86_64 -enable-kvm -m 2048 -nic user,model=virtio -drive file=tdx-guest.qcow2,media=disk,if=virtio -nographic


# rebuild one component (like qemu)
# cd build/ubuntu-22.04/intel-mvp-tdx-qemu-kvm/
# rm ../build-status/qemu.done
# ./build.sh

# run TDX qemu
#./start-qemu.sh -i ./tdx-guest.qcow2  -k ./build/ubuntu-22.04/intel-mvp-tdx-kernel/mvp-tdx-kernel-v6.2.16/debian/build/build-generic/vmlinux

