import socket
import os
import time
import argparse

def get_battery_info():
    """Reads battery info from /sys/class/power_supply/"""
    # Try to find a battery (usually BAT0 or BAT1)
    base_path = "/sys/class/power_supply/"
    batteries = [f for f in os.listdir(base_path) if f.startswith("BAT")]
    
    if not batteries:
        return "No battery found, 0"
    
    bat = batteries[0]
    try:
        with open(os.path.join(base_path, bat, "capacity"), "r") as f:
            capacity = f.read().strip()
        with open(os.path.join(base_path, bat, "status"), "r") as f:
            status = f.read().strip()
        return f"{status}, {capacity}"
    except Exception as e:
        return f"Error: {e}, 0"

def main():
    parser = argparse.ArgumentParser(description="Send battery info via UDP.")
    parser.add_argument("ip", help="Receiver IP address")
    parser.add_argument("--port", type=int, default=5555, help="UDP port (default: 5555)")
    parser.add_argument("--interval", type=int, default=60, help="Interval in seconds (default: 60)")
    args = parser.parse_args()

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    print(f"Sending battery info to {args.ip}:{args.port} every {args.interval} seconds...")
    while True:
        data = get_battery_info()
        print(f"Sending: {data}")
        sock.sendto(data.encode(), (args.ip, args.port))
        time.sleep(args.interval)

if __name__ == "__main__":
    main()
