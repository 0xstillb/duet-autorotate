# duet-autorotate handoff / reinstall notes

This file is for reusing the workaround after an OS reinstall or update.

## Verified mapping

Sensor: `/sys/bus/iio/devices/iio:device2`, name `cros-ec-accel`, location
`lid`. Raw channels: `in_accel_x_raw`, `in_accel_y_raw`, and
`in_accel_z_raw`.

| Physical position | Raw gravity direction | Display angle |
|---|---:|---:|
| Landscape upright | x positive | 0° |
| Portrait upright | y positive | 270° |
| Landscape inverted | x negative | 180° |
| Portrait inverted | y negative | 90° |
| Flat face-up | z positive, x/y small | no rotation |

The daemon applies a magnitude gate, in-plane axis hysteresis, 45-degree
dominance hysteresis, flat rejection, 700 ms stability, and approximately
6.7 Hz polling.

## Rotation method

The verified display method on this FydeOS build is the ChromeOS/Ash
`Ctrl+Shift+Refresh` accelerator. The daemon creates a temporary virtual
keyboard through `/dev/uinput` and sends the relative accelerator as needed.
The `state` file must match the actual display angle.

## What survives a reboot

`/usr/local/duet-autorotate/` is on the stateful `/usr/local` filesystem and
normally survives a normal reboot. The Upstart registration is
`/etc/init/duet-autorotate.conf`; it normally survives a reboot after the
root filesystem was remounted writable, but may be replaced by an OS update,
Powerwash, or fresh OS installation. The Downloads copies may also be erased.

## Backup before reinstall

Copy the complete directory `/usr/local/duet-autorotate/` to an external USB
or another computer. Do not rely only on `/tmp`, because it is not persistent.

## Reinstall after a fresh FydeOS install

Copy the saved source bundle back to `/usr/local/duet-autorotate/source/`, then
run as root:

```sh
sudo mount -o remount,rw /
sudo bash /usr/local/duet-autorotate/source/install.sh
```

A fresh installation should be at 0° before enabling the daemon. If the
current display is visibly at another angle, correct it with the test helper or
write the actual angle to `state` before running `enable`. Example for 0°:

```sh
sudo /usr/local/duet-autorotate/duet-autorotate disable
sudo sh -c 'printf "0\n" > /usr/local/duet-autorotate/state'
sudo /usr/local/duet-autorotate/duet-autorotate enable
```

Use `90`, `180`, or `270` only when that is the display angle currently shown.

## Verification

```sh
sudo /usr/local/duet-autorotate/duet-autorotate status
sudo tail -n 30 /usr/local/duet-autorotate/duet-autorotate.log
```

Expected status contains `enabled=yes` and `start/running`.

## Rollback

```sh
sudo /usr/local/duet-autorotate/duet-autorotate disable
sudo /sbin/initctl stop duet-autorotate || true
sudo mv /etc/init/duet-autorotate.conf /etc/init/duet-autorotate.conf.removed
sudo /sbin/initctl reload-configuration
sudo mv /usr/local/duet-autorotate /usr/local/duet-autorotate.removed
```

The installer creates timestamped recoverable backups under
`/usr/local/duet-autorotate/backups/`. These commands do not touch Windows or
NVMe partitions.

## Operating note

Do not manually use the rotation accelerator while the daemon is enabled.
Disable it first so the relative tracked angle remains correct.
