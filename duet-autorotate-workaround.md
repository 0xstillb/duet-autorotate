# duet-autorotate workaround

## Verified sensor mapping

Sensor: `/sys/bus/iio/devices/iio:device2`, name `cros-ec-accel`, location `lid`.

The raw channels are `in_accel_x_raw`, `in_accel_y_raw`, and
`in_accel_z_raw`.

| Physical tablet position | Verified raw pattern | Display rotation |
| --- | --- | ---: |
| Landscape upright | `x` about `+9700` | 0° |
| Portrait upright | `y` about `+9800` | 270° |
| Landscape inverted | `x` about `-9200` | 180° |
| Portrait inverted | `y` about `-9000` | 90° |
| Face-up flat | `z` about `+10000`, small x/y | no rotation |

The daemon uses a gravity-vector magnitude gate, an in-plane-axis gate,
dominance hysteresis around the 45-degree boundaries, and 700 ms stability
before acting. It polls at 6.7 Hz. Flat positions are ignored.

## Rotation method

This FydeOS build has no usable `xrandr` or Ash rotation D-Bus method. The
verified command-line method is the ChromeOS/Ash keyboard accelerator
Ctrl+Shift+Refresh. The daemon creates a temporary virtual keyboard through
`/dev/uinput` and sends that accelerator the required number of times to move
between 0/90/180/270 degrees.

The accelerator is relative, so `state` tracks the last known display angle.
Do not manually rotate the display while the daemon is enabled. If the tracked
state becomes wrong, stop the daemon, set `state` to the actual current angle,
then start it again.

## Files created

- `/usr/local/duet-autorotate/duet-autorotate` — daemon and control command
- `/usr/local/duet-autorotate/config` — polling/stability settings
- `/usr/local/duet-autorotate/state` — tracked angle
- `/usr/local/duet-autorotate/disabled` — present only when globally disabled
- `/usr/local/duet-autorotate/duet-autorotate.pid` — runtime PID
- `/usr/local/duet-autorotate/duet-autorotate.log` — rate-limited log
- `/usr/local/duet-autorotate/backups/<timestamp>/` — installer backups
- `/etc/init/duet-autorotate.conf` — native Upstart service
- this document in the Downloads folder

## Commands

```sh
sudo /usr/local/duet-autorotate/duet-autorotate start
sudo /usr/local/duet-autorotate/duet-autorotate stop
sudo /usr/local/duet-autorotate/duet-autorotate status
sudo /usr/local/duet-autorotate/duet-autorotate enable
sudo /usr/local/duet-autorotate/duet-autorotate disable
sudo tail -f /usr/local/duet-autorotate/duet-autorotate.log
```

`disable` leaves the current display angle unchanged and prevents automatic
rotation until `enable` is used.

## Rollback / uninstall

The installer backs up every persistent file it replaces before installation.
To stop and remove the service without touching Windows/NVMe partitions:

```sh
sudo /sbin/initctl stop duet-autorotate || true
sudo mv /etc/init/duet-autorotate.conf /etc/init/duet-autorotate.conf.removed
sudo /sbin/initctl reload-configuration
sudo mv /usr/local/duet-autorotate /usr/local/duet-autorotate.removed
```

These moves are recoverable. To restore a prior version, copy the desired
files from the timestamped backup directory back to their original paths,
restore `/etc/init/duet-autorotate.conf`, reload Upstart, and start the job.

## Live USB persistence

On a non-persistent Live USB, changes under `/usr/local`, `/etc/init`, and the
user Downloads directory may disappear after reboot. Keep this staging package
and the recorded backup on the USB, enable Live USB persistence if supported,
or rerun the installer after each boot. The daemon does not modify Windows or
NVMe partitions.

## Persistent reinstall bundle

The installer also keeps a reusable copy of the installer, daemon, service
file, test helper, and documentation at `/usr/local/duet-autorotate/source/`.
See `README.md` and `handoff.md` there for reboot, OS update, and Live USB
persistence notes.
