#!/bin/bash

apt update
apt install --yes software-properties-common

#add-apt-repository ppa:kobuk-team/tdx
add-apt-repository ppa:hectorcao/kobuk

# PPA pinning
cat <<EOF | tee /etc/apt/preferences.d/hectorcao-kobuk-pin-4000
Package: *
Pin: release o=LP-PPA-hectorcao-kobuk
Pin-Priority: 4000
EOF

apt update

#apt install --yes kobuk-tdx-host
apt install --yes qemu-system-x86 ovmf
