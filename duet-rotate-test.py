#!/usr/bin/env python3
"""Send one ChromeOS screen-rotation accelerator through a temporary uinput keyboard."""
import argparse
import fcntl
import os
import struct
import time

UI_SET_EVBIT = 0x40045564
UI_SET_KEYBIT = 0x40045565
UI_DEV_CREATE = 0x5501
UI_DEV_DESTROY = 0x5502
EV_SYN = 0
EV_KEY = 1
SYN_REPORT = 0
KEY_LEFTCTRL = 29
KEY_LEFTSHIFT = 42
KEY_REFRESH = 173


def event(fd, typ, code, value):
    now = time.time()
    sec = int(now)
    usec = int((now - sec) * 1_000_000)
    os.write(fd, struct.pack("@llHHI", sec, usec, typ, code, value))


def sync(fd):
    event(fd, EV_SYN, SYN_REPORT, 0)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--count", type=int, default=1,
                    help="number of accelerator presses (default: 1)")
    args = ap.parse_args()
    if args.count < 1 or args.count > 4:
        ap.error("--count must be between 1 and 4")

    fd = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
    try:
        fcntl.ioctl(fd, UI_SET_EVBIT, EV_KEY)
        for key in (KEY_LEFTCTRL, KEY_LEFTSHIFT, KEY_REFRESH):
            fcntl.ioctl(fd, UI_SET_KEYBIT, key)

        name = b"duet-autorotate-test"
        uidev = bytearray(1116)
        uidev[:len(name)] = name
        struct.pack_into("@4H I", uidev, 80, 0x03, 0x1, 0x1, 0x1, 0)
        os.write(fd, uidev)
        fcntl.ioctl(fd, UI_DEV_CREATE)
        time.sleep(0.25)

        for _ in range(args.count):
            event(fd, EV_KEY, KEY_LEFTCTRL, 1)
            event(fd, EV_KEY, KEY_LEFTSHIFT, 1)
            event(fd, EV_KEY, KEY_REFRESH, 1)
            sync(fd)
            time.sleep(0.08)
            event(fd, EV_KEY, KEY_REFRESH, 0)
            event(fd, EV_KEY, KEY_LEFTSHIFT, 0)
            event(fd, EV_KEY, KEY_LEFTCTRL, 0)
            sync(fd)
            time.sleep(0.35)
    finally:
        try:
            fcntl.ioctl(fd, UI_DEV_DESTROY)
        except OSError:
            pass
        os.close(fd)


if __name__ == "__main__":
    main()
