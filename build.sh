#!/bin/bash

sudo apt install docker.io

sudo usermod -a -G docker $USER
# force group membership to be effective without logout
#newgrp docker

echo "Build ..."
(cd build/ubuntu-23.10/ && ./pkg-builder build-repo.sh)

# create guest image
sudo apt install --yes qemu-utils libguestfs-tools virtinst genisoimage
(cd build/ubuntu-23.10/guest-image/ && sudo ./create-ubuntu-image.sh -r ../guest_repo/ -f -o ./tdx-guest.qcow2 -u tdx -p tdx -n tdx-guest)

# create docker host image with qemu
docker build -t tdx-host-qemu build/ubuntu-23.10/docker-host

sudo mv /tmp/tdx-guest.qcow2 ./
sudo chown $USER:$(id -g) ./tdx-guest.qcow2

# To modify the qcow2
# sudo virt-customize -a /tmp/tdx-guest.qcow2   --copy-in ./build/ubuntu-23.10/guest-image/setup.sh:/tmp/
# sudo virt-customize -a /tmp/tdx-guest.qcow2   --run-command "/tmp/setup.sh"

