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

# sudo usermod -a -G kvm {user}
# qemu-system-x86_64 -enable-kvm -m 2048 -name process=tdxvm,debug-threads=on -nic user,model=virtio -drive file=tdx-guest.qcow2,media=disk,if=virtio -nographic -vga none -device virtio-net-pci,netdev=nic0 -netdev user,id=nic0,hostfwd=tcp::10022-:22 -daemonize

# qemu-system-x86_64 -accel kvm -m 64G -smp 64 -name process=tdxvm,debug-threads=on -cpu host,host-phys-bits,-kvm-steal-time,-arch-lbr -object tdx-guest,id=tdx -machine q35,hpet=off,kernel_irqchip=split,memory-encryption=tdx,memory-backend=ram1 -object memory-backend-ram,id=ram1,size=64G,private=on -bios /usr/share/qemu/OVMF.fd -nographic -vga none -chardev stdio,id=mux,mux=on,signal=off -device virtio-serial -device virtconsole,chardev=mux -serial chardev:mux -nodefaults -device virtio-net-pci,netdev=nic0 -netdev user,id=nic0,hostfwd=tcp::10022-:22 -drive file=/tmp/tdx-guest-td.qcow2,if=none,id=virtio-disk0 -device virtio-blk-pci,drive=virtio-disk0 -device vhost-vsock-pci,guest-cid=3 -monitor unix:/tmp/tdx-demo-td-monitor.sock,server,nowait

#./start-qemu.sh -i ./tdx-guest.qcow2 -k ./vmlinuz

# docker

docker run -v ${PWD}:${PWD} -w $PWD --device=/dev/kvm tdx-host ./run-docker.sh
