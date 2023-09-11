#!/bin/bash

VM_IMG=$1
PROCESS_NAME=normal-vm
SSH_PORT=20022

qemu-system-x86_64 -accel kvm \
		   -m 2G -smp 64 \
		   -name ${PROCESS_NAME},process=${PROCESS_NAME},debug-threads=on \
		   -cpu host,host-phys-bits,-kvm-steal-time,-arch-lbr \
		   -machine q35,hpet=off,kernel_irqchip=split,memory-backend=ram1 \
		   -object memory-backend-ram,id=ram1,size=2G,private=on \
		   -bios /usr/share/qemu/OVMF.fd \
		   -nographic -daemonize \
		   -nodefaults \
		   -device virtio-net-pci,netdev=nic0 -netdev user,id=nic0,hostfwd=tcp::${SSH_PORT}-:22 \
		   -drive file=${VM_IMG},if=none,id=virtio-disk0 \
		   -device virtio-blk-pci,drive=virtio-disk0 \
		   -device vhost-vsock-pci,guest-cid=3
