#!/bin/bash
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ "$(id -u)" -ne 0 ]; then
  echo "Run with: sudo bash install-real-os.sh" >&2
  exit 1
fi
if [ ! -w /etc/init ]; then
  echo "ERROR: /etc/init is read-only; run: sudo mount -o remount,rw /" >&2
  exit 2
fi
exec bash "$script_dir/install.sh"
