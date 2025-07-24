#!/bin/bash

# Check for argument
if [ -z "$1" ]; then
  echo "Usage: $0 \"Location Name\""
  exit 1
fi

LOCATION="$1"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="./wifi_logs"
mkdir -p "$OUTPUT_DIR"

# Define output files
SCAN_FILE="${OUTPUT_DIR}/wifi_scan_${LOCATION// /_}_$TIMESTAMP.txt"
PING_FILE="${OUTPUT_DIR}/ping_${LOCATION// /_}_$TIMESTAMP.txt"
CSV_LOG="${OUTPUT_DIR}/wifi_summary_log.csv"

echo "[*] Running Wi-Fi scan for '$LOCATION'..."

# Run Wi-Fi scan
nmcli -f SSID,BSSID,FREQ,CHAN,SIGNAL,RATE,SECURITY dev wifi list > "$SCAN_FILE"

# Run ping test
echo "[*] Running ping test to 8.8.8.8..."
PING_STATS=$(ping -c 50 8.8.8.8 | tail -2)
echo "$PING_STATS" > "$PING_FILE"

# Parse signal stats from strongest matching SSID (assuming you're connected)
CONNECTED_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
SCAN_LINE=$(grep "$CONNECTED_SSID" "$SCAN_FILE" | head -1)

SSID=$(echo "$SCAN_LINE" | awk '{print $1}')
BSSID=$(echo "$SCAN_LINE" | awk '{print $2}')
FREQ=$(echo "$SCAN_LINE" | awk '{print $3}')
CHAN=$(echo "$SCAN_LINE" | awk '{print $4}')
SIGNAL=$(echo "$SCAN_LINE" | awk '{print $5}')
RATE=$(echo "$SCAN_LINE" | awk '{print $6}')
SECURITY=$(echo "$SCAN_LINE" | awk '{print $7}')

LATENCY=$(echo "$PING_STATS" | grep 'avg' | cut -d '/' -f5)
LOSS=$(echo "$PING_STATS" | grep 'packet loss' | awk '{print $6}')

# Append to summary CSV
if [ ! -f "$CSV_LOG" ]; then
  echo "Timestamp,Location,SSID,BSSID,Freq,Chan,Signal(%),Rate,Security,AvgLatency(ms),PacketLoss" > "$CSV_LOG"
fi

echo "$TIMESTAMP,\"$LOCATION\",$SSID,$BSSID,$FREQ,$CHAN,$SIGNAL,$RATE,$SECURITY,$LATENCY,$LOSS" >> "$CSV_LOG"

echo "[✓] Scan complete. Files saved in $OUTPUT_DIR"

