#!/bin/bash
set -eu

src_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
install_dir=/usr/local/duet-autorotate
source_dir="$install_dir/source"
stamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$install_dir/backups/$stamp"
doc=/home/chronos/user/MyFiles/Downloads/duet-autorotate-workaround.md
readme_doc=/home/chronos/user/MyFiles/Downloads/duet-autorotate-README.md
handoff_doc=/home/chronos/user/MyFiles/Downloads/duet-autorotate-handoff.md

if [ ! -w /etc/init ]; then
  echo "ERROR: /etc/init is not writable; run: sudo mount -o remount,rw /" >&2
  exit 2
fi

mkdir -p "$install_dir" "$backup_dir"

backup_file() {
  source=$1
  target=$2
  if [ -e "$source" ]; then
    mkdir -p "$(dirname -- "$target")"
    cp -a -- "$source" "$target"
  fi
}

for name in duet-autorotate config state disabled README.md handoff.md source; do
  backup_file "$install_dir/$name" "$backup_dir/$name"
done
backup_file /etc/init/duet-autorotate.conf "$backup_dir/etc-init-duet-autorotate.conf"
backup_file "$doc" "$backup_dir/downloads-duet-autorotate-workaround.md"
backup_file "$readme_doc" "$backup_dir/downloads-duet-autorotate-README.md"
backup_file "$handoff_doc" "$backup_dir/downloads-duet-autorotate-handoff.md"

install -m 0755 "$src_dir/duet-autorotate" "$install_dir/duet-autorotate"
install -m 0644 "$src_dir/config" "$install_dir/config"
install -m 0644 "$src_dir/README.md" "$install_dir/README.md"
install -m 0644 "$src_dir/handoff.md" "$install_dir/handoff.md"
install -d -m 0755 "$source_dir"
install -m 0755 "$src_dir/install.sh" "$source_dir/install.sh"
install -m 0755 "$src_dir/duet-autorotate" "$source_dir/duet-autorotate"
install -m 0755 "$src_dir/duet-rotate-test.py" "$source_dir/duet-rotate-test.py"
install -m 0644 "$src_dir/config" "$source_dir/config"
install -m 0644 "$src_dir/duet-autorotate.conf" "$source_dir/duet-autorotate.conf"
install -m 0644 "$src_dir/duet-autorotate-workaround.md" "$source_dir/duet-autorotate-workaround.md"
install -m 0644 "$src_dir/README.md" "$source_dir/README.md"
install -m 0644 "$src_dir/handoff.md" "$source_dir/handoff.md"
install -m 0644 "$src_dir/duet-autorotate.conf" /etc/init/duet-autorotate.conf
install -m 0644 "$src_dir/duet-autorotate-workaround.md" "$doc"
install -m 0644 "$src_dir/README.md" "$readme_doc"
install -m 0644 "$src_dir/handoff.md" "$handoff_doc"

if [ ! -e "$install_dir/state" ]; then
  printf '0\n' > "$install_dir/state"
  chmod 0600 "$install_dir/state"
fi

/sbin/initctl reload-configuration
if [ ! -e "$install_dir/disabled" ]; then
  /sbin/initctl start duet-autorotate || true
fi

echo "Installed duet-autorotate. Backup: $backup_dir"
echo "Check with: $install_dir/duet-autorotate status"
