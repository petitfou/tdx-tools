#!/bin/bash

cleanup() {
    rm -f /tmp/tdx-guest-*.log &> /dev/null
    rm -f /tmp/tdx-demo-*-monitor.sock &> /dev/null

    PID_VM=$(cat /tmp/tdx-demo-vm-pid.pid 2> /dev/null)
    PID_TD=$(cat /tmp/tdx-demo-td-pid.pid 2> /dev/null)

    [ ! -z "$PID_VM" ] && echo "Cleanup, kill normal vm PID: ${PID_VM}" && kill -TERM ${PID_VM} &> /dev/null
    [ ! -z "$PID_TD" ] && echo "Cleanup, kill TD vm PID: ${PID_TD}" && kill -TERM ${PID_TD} &> /dev/null
    sleep 3
}

cleanup
if [ "$1" = "clean" ]; then
    exit 0
fi

GUEST_IMAGE=${HOME}/tdx-guest.qcow2
TDVF_FIRMWARE=/usr/share/ovmf/OVMF.fd

cp ${GUEST_IMAGE} /tmp/tdx-guest-vm.qcow2
cp ${GUEST_IMAGE} /tmp/tdx-guest-td.qcow2

REMAINING_QEMUS=$(pidof qemu-system-x86_64)
if [ ! -z "$REMAINING_QEMUS" ]; then
    echo "Still remaining qemus ... ${REMAINING_QEMUS}"
    exit 1
fi

set -e

###################### RUN VM WITH TDX SUPPORT ##################################
VM_IMG=/tmp/tdx-guest-td.qcow2
SSH_PORT=10022
qemu-system-x86_64 -D /tmp/tdx-guest-td.log \
		   -accel kvm \
		   -m 2G -smp 64 \
		   -name ${PROCESS_NAME},process=${PROCESS_NAME},debug-threads=on \
		   -cpu host \
		   -object tdx-guest,id=tdx \
		   -machine q35,hpet=off,kernel_irqchip=split,memory-encryption=tdx,memory-backend=ram1 \
		   -object memory-backend-ram,id=ram1,size=2G,private=on \
		   -bios ${TDVF_FIRMWARE} \
		   -nographic -daemonize \
		   -nodefaults \
		   -device virtio-net-pci,netdev=nic0_td -netdev user,id=nic0_td,hostfwd=tcp::${SSH_PORT}-:22 \
		   -drive file=${VM_IMG},if=none,id=virtio-disk0 \
		   -device virtio-blk-pci,drive=virtio-disk0 \
		   -device vhost-vsock-pci,guest-cid=3 \
		   -monitor unix:/tmp/tdx-demo-td-monitor.sock,server,nowait \
		   -pidfile /tmp/tdx-demo-td-pid.pid

###################### RUN VM WITHOUT TDX SUPPORT ###############################
VM_IMG=/tmp/tdx-guest-vm.qcow2
SSH_PORT=20022
qemu-system-x86_64 -D /tmp/tdx-guest-vm.log \
		   -accel kvm \
		   -m 2G -smp 64 \
		   -name ${PROCESS_NAME},process=${PROCESS_NAME},debug-threads=on \
		   -cpu host \
		   -machine q35,hpet=off,kernel_irqchip=split,memory-backend=ram1 \
		   -object memory-backend-ram,id=ram1,size=2G,private=on \
		   -bios ${TDVF_FIRMWARE} \
		   -nographic -daemonize \
		   -nodefaults \
		   -device virtio-net-pci,netdev=nic0_vm -netdev user,id=nic0_vm,hostfwd=tcp::${SSH_PORT}-:22 \
		   -drive file=${VM_IMG},if=none,id=virtio-disk0 \
		   -device virtio-blk-pci,drive=virtio-disk0 \
		   -monitor unix:/tmp/tdx-demo-vm-monitor.sock,server,nowait \
		   -pidfile /tmp/tdx-demo-vm-pid.pid

PID_VM=$(cat /tmp/tdx-demo-vm-pid.pid)
PID_TD=$(cat /tmp/tdx-demo-td-pid.pid)

echo "TD VM, PID: ${PID_TD}, SSH : ssh -p 10022 root@localhost"
echo "Normal VM, PID: ${PID_VM}, SSH : ssh -p 20022 root@localhost"

# echo 'To get a memory dump'
# echo "  - TD VM: echo 'dump-guest-memory /tmp/td-memory-dump' | socat - unix-connect:/tmp/tdx-demo-td-monitor.sock"
# echo "  - TD VM: echo 'dump-guest-memory /tmp/vm-memory-dump' | socat - unix-connect:/tmp/tdx-demo-vm-monitor.sock"

# echo "example of secret to extract:"
# echo "  - strings /tmp/vm-memory-dump | grep -A10 'BEGIN OPENSSH PRIVATE KEY'"
# echo "  - strings /tmp/td-memory-dump | grep -A10 'BEGIN OPENSSH PRIVATE KEY'"
