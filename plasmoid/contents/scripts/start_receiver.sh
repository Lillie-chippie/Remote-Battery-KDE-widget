#!/bin/bash
# Start the battery receiver if not already running
# This script is called by the widget on startup

if ! pgrep -f "battery_receiver_daemon.py" > /dev/null 2>&1; then
    DIR="$(cd "$(dirname "$0")" && pwd)"
    nohup python3 "$DIR/battery_receiver_daemon.py" > /dev/null 2>&1 &
    echo "started"
else
    echo "running"
fi
