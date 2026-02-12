#!/bin/bash
cat /tmp/remote_battery_status 2>/dev/null || echo "Unknown, 0"
