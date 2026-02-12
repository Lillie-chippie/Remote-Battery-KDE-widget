#!/usr/bin/env python3
"""Battery receiver daemon - listens for UDP battery data and writes to /tmp/remote_battery_status"""
import socket
import os
import signal
import sys

TMP_FILE = "/tmp/remote_battery_status"
PORT = 5555

def handle_exit(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_exit)
signal.signal(signal.SIGINT, handle_exit)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

try:
    sock.bind(("0.0.0.0", PORT))
except OSError as e:
    # Port already in use — another instance is running
    sys.exit(0)

while True:
    try:
        data, addr = sock.recvfrom(1024)
        decoded = data.decode().strip()
        with open(TMP_FILE, "w") as f:
            f.write(decoded)
        os.chmod(TMP_FILE, 0o644)
    except Exception:
        pass
