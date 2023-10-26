#!/bin/bash

apt update

# Intel testing stuff
# linux-tools-common for perf, please make sure that linux-tools is also installed
apt install -y cpuid linux-tools-common msr-tools

# upgrade before install tdx components to avoid error like this:
#The following packages have unmet dependencies:
# grub-efi-amd64 : Conflicts: grub-pc but 2.12~rc1-4ubuntu1 is to be installed
# grub-pc : Conflicts: grub-efi-amd64 but 2.12~rc1-4ubuntu1 is to be installed
# E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.

# This whole line is important to make sure that the upgrade is fully non-interactive
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --allow-unauthenticated -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

# setup TDX guest
add-apt-repository ppa:kobuk-team/tdx-release

# PPA pinning
cat <<EOF | tee /etc/apt/preferences.d/kobuk-team-tdx-release-pin-4000
Package: *
Pin: release o=LP-PPA-kobuk-team-tdx-release
Pin-Priority: 4000
EOF

apt update

# install TDX feature
apt install -y kobuk-tdx-guest

# modprobe the tdx_guest
modprobe tdx-guest
echo tdx-guest > /etc/modprobe.d/tdx-guest.conf

# measurement tool
#apt install -y python3-pip
#python3 -m pip install pytdxattest

# setup ssh
# allow password auth + root login
sed -i 's|[#]*PasswordAuthentication .*|PasswordAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's|[#]*PermitRootLogin .*|PermitRootLogin yes|g' /etc/ssh/sshd_config
sed -i 's|[#]*KbdInteractiveAuthentication .*|KbdInteractiveAuthentication yes|g' /etc/ssh/sshd_config
