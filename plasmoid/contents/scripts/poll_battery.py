#!/usr/bin/env python3
import time
import os
import signal
import sys

# File where the receiver writes the data
STATUS_File = "/tmp/remote_battery_status"

def handle_exit(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_exit)
signal.signal(signal.SIGINT, handle_exit)

print("Starting battery polling service...", flush=True)

while True:
    try:
        if os.path.exists(STATUS_File):
            with open(STATUS_File, "r") as f:
                content = f.read().strip()
                # Print to stdout, which QML can read via DataSource
                print(content, flush=True)
        else:
            print("Waiting...", flush=True)
    except Exception as e:
        print(f"Error: {e}", flush=True)
    
    time.sleep(2)
