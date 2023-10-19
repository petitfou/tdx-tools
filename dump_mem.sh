#!/bin/bash

VMTYPE=$1

MEM_DUMP_FILE=/tmp/${VMTYPE}-memory-dump

rm -f ${MEM_DUMP_FILE}

set -e

socat - unix-connect:/tmp/tdx-demo-${VMTYPE}-monitor.sock << EOF
dump-guest-memory /tmp/${VMTYPE}-memory-dump
EOF

echo "Dump ${VMTYPE} memory into ${MEM_DUMP_FILE}"

