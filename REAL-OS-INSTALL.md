# Real-disk FydeOS installation handoff

This procedure is for a normal FydeOS installation on the internal disk. It
does not depend on Live USB persistence and should not be run from a temporary
Live USB session.

## Before reinstalling FydeOS

1. Save this repository outside the OS being replaced. Use GitHub's **Code →
   Download ZIP**, or copy the repository to another computer/external disk.
2. Do not rely on `/tmp`, because it is cleared by reboot.
3. Keep the current working mapping and method documented in `handoff.md`.

Repository: `https://github.com/0xstillb/duet-autorotate`

## After FydeOS is installed to the internal disk

1. Boot the installed FydeOS normally and sign in. Verify the shell is the
   installed system, not a Live USB environment.
2. Download the private repository ZIP from GitHub and extract it in Downloads.
3. Open Terminal and change into the extracted repository directory.
4. Run the real-OS installer:

```sh
sudo bash install-real-os.sh
```

On this FydeOS build the root filesystem is normally read-only. If the
installer reports `/etc/init` read-only, allow the temporary writable remount
and retry:

```sh
sudo mount -o remount,rw /
sudo bash install-real-os.sh
```

The installer backs up replaced persistent files, installs the daemon and
Upstart job, preserves an existing `state` file, and creates a persistent
source bundle at `/usr/local/duet-autorotate/source/`.

## First-start calibration

The display must visibly be at the angle stored in `state` before enabling the
daemon. For a fresh installation use 0°:

```sh
sudo sh -c 'printf "0\n" > /usr/local/duet-autorotate/state'
sudo /usr/local/duet-autorotate/duet-autorotate enable
sudo /usr/local/duet-autorotate/duet-autorotate status
```

Expected status includes `enabled=yes` and `start/running`. Verify the log:

```sh
sudo tail -n 30 /usr/local/duet-autorotate/duet-autorotate.log
```

Do not manually use `Ctrl+Shift+Refresh` while the daemon is enabled. Disable
it first, because the accelerator is relative and manual rotation changes the
tracked angle.

## Verified mapping

Sensor: `/sys/bus/iio/devices/iio:device2`, `cros-ec-accel`, location `lid`.

| Physical position | Raw gravity direction | Display angle |
|---|---:|---:|
| Landscape upright | x positive | 0° |
| Portrait upright | y positive | 270° |
| Landscape inverted | x negative | 180° |
| Portrait inverted | y negative | 90° |
| Flat face-up | z positive, x/y small | no rotation |

The daemon uses magnitude thresholding, hysteresis, flat rejection, 700 ms
stability, and approximately 6.7 Hz polling.

## Normal reboot and OS update

A normal reboot should retain `/usr/local/duet-autorotate/` and the Upstart
registration. An OS update, Powerwash, or fresh installation may replace the
root system and remove `/etc/init/duet-autorotate.conf`; rerun the installer
from the saved repository ZIP if status is not running after the update.

## Disable / rollback

```sh
sudo /usr/local/duet-autorotate/duet-autorotate disable
sudo /sbin/initctl stop duet-autorotate || true
sudo mv /etc/init/duet-autorotate.conf /etc/init/duet-autorotate.conf.removed
sudo /sbin/initctl reload-configuration
sudo mv /usr/local/duet-autorotate /usr/local/duet-autorotate.removed
```

Timestamped recoverable backups are under
`/usr/local/duet-autorotate/backups/`. No Windows or NVMe partition is changed.
