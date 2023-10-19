#!/bin/bash

VM_TYPE=$1
VM_PORT=10022
SECRET="SOME-SECRET-${RANDOM}"

if [ -z "$VM_TYPE" ]; then
		VM_TYPE=td
fi

# exit on any error
set -e

if [ "$VM_TYPE" = "vm" ]; then
		VM_PORT=20022
fi

echo $SECRET > tmp.txt

sudo apt install -y sshpass &> /dev/null

vm_exec() {
		sshpass -p "123456" ssh -p ${VM_PORT} -o StrictHostKeyChecking=no root@localhost $@
}

echo "Mount tmpfs on $VM_TYPE (port=$VM_PORT)"
vm_exec "mkdir -p /tmp/tmpfs"
vm_exec "umount /tmp/tmpfs || true"
vm_exec "mount -t tmpfs tmpfs /tmp/tmpfs"

echo "Inject secret $SECRET into $VM_TYPE"

# copy files into tmpfs folder
sshpass -p "123456" scp -P ${VM_PORT} tmp.txt root@localhost:/tmp/tmpfs/
vm_exec "sync"

rm -f /tmp/${VM_TYPE}-memory-dump

echo "Dump $VM_TYPE memory"
socat - unix-connect:/tmp/tdx-demo-${VM_TYPE}-monitor.sock &> /dev/null << EOF
dump-guest-memory /tmp/${VM_TYPE}-memory-dump
EOF

# verify
echo "Searching for ${SECRET}"
sleep 1
strings /tmp/${VM_TYPE}-memory-dump | grep "${SECRET}"
