# duet-autorotate

FydeOS host-side automatic display rotation workaround for the installed OS
on the internal disk. This is not a Live USB boot package.

## Install on a real FydeOS installation

Download this repository as a ZIP on the newly installed FydeOS system,
extract it under Downloads, then run: `sudo bash install-real-os.sh`.
The installer writes only the FydeOS system/service and stateful locations
listed below; it does not modify Windows or NVMe partitions.

```sh
sudo bash install-real-os.sh
```

If the installer reports that `/etc/init` is read-only, run this once and
repeat the installer:

```sh
sudo mount -o remount,rw /
sudo bash install-real-os.sh
```

## Commands

```sh
sudo /usr/local/duet-autorotate/duet-autorotate status
sudo /usr/local/duet-autorotate/duet-autorotate start
sudo /usr/local/duet-autorotate/duet-autorotate stop
sudo /usr/local/duet-autorotate/duet-autorotate enable
sudo /usr/local/duet-autorotate/duet-autorotate disable
```

`disable` is the global manual-orientation switch. The relative display angle
is tracked in `/usr/local/duet-autorotate/state`.

## Files after installation

- `/usr/local/duet-autorotate/` — daemon, state, log, backups, and persistent source bundle.
- `/usr/local/duet-autorotate/source/` — reusable offline reinstall files.
- `/etc/init/duet-autorotate.conf` — native Upstart service registration.
- `/home/chronos/user/MyFiles/Downloads/duet-autorotate-*.md` — handoff copies.

The `/usr/local` stateful filesystem normally survives a reboot. A fresh OS
installation, Powerwash, or system image update may erase stateful files and
the `/etc/init` service file, so keep a copy of this repository outside the
installed OS before reinstalling.

See [`REAL-OS-INSTALL.md`](REAL-OS-INSTALL.md) for the complete procedure and
[`handoff.md`](handoff.md) for recovery and rollback.
