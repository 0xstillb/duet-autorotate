# duet-autorotate

Host-side automatic display rotation workaround for a FydeOS tablet where Ash
automatic accelerometer discovery is broken.

## Quick commands

```sh
sudo /usr/local/duet-autorotate/duet-autorotate status
sudo /usr/local/duet-autorotate/duet-autorotate start
sudo /usr/local/duet-autorotate/duet-autorotate stop
sudo /usr/local/duet-autorotate/duet-autorotate enable
sudo /usr/local/duet-autorotate/duet-autorotate disable
```

`disable` is the global manual-orientation switch. The tracked angle is stored
in `/usr/local/duet-autorotate/state`.

## Persistent files

- `/usr/local/duet-autorotate/` — daemon, state, log, backups, and source bundle.
- `/usr/local/duet-autorotate/source/` — reusable installer and source files.
- `/etc/init/duet-autorotate.conf` — native Upstart service registration.
- `/home/chronos/user/MyFiles/Downloads/duet-autorotate-workaround.md` — technical documentation.

`/usr/local` is on the FydeOS stateful partition and normally survives reboot.
A fresh OS installation, Powerwash, or system image update may remove the
stateful files and the `/etc/init` service file. Back up the source bundle to
external storage before reinstalling. See `handoff.md`.

## Safety

The daemon uses only the known IIO raw sensor and the ChromeOS/Ash keyboard
accelerator through `/dev/uinput`. It does not modify Windows or NVMe
partitions.
