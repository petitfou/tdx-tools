#!/bin/bash

apt update

# upgrade before install tdx components to avoid error like this:
#The following packages have unmet dependencies:
# grub-efi-amd64 : Conflicts: grub-pc but 2.12~rc1-4ubuntu1 is to be installed
# grub-pc : Conflicts: grub-efi-amd64 but 2.12~rc1-4ubuntu1 is to be installed
# E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.

# This whole line is important to make sure that the upgrade is fully non-interactive
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --allow-unauthenticated -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

# setup TDX guest
add-apt-repository ppa:kobuk-team/tdx

# PPA pinning
cat <<EOF | tee /etc/apt/preferences.d/kobuk-team-tdx-pin-4000
Package: *
Pin: release o=LP-PPA-kobuk-team-tdx
Pin-Priority: 4000
EOF

apt update

# install TDX feature
apt install -y kobuk-tdx-guest

# measurement tool
#apt install -y python3-pip
#python3 -m pip install pytdxattest
