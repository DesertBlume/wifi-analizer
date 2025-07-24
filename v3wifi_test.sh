#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 \"Location Name\""
  exit 1
fi

LOCATION="$1"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="./wifi_logs"
mkdir -p "$OUTPUT_DIR"

SCAN_FILE="${OUTPUT_DIR}/wifi_scan_${LOCATION// /_}_$TIMESTAMP.txt"
PING_FILE="${OUTPUT_DIR}/ping_${LOCATION// /_}_$TIMESTAMP.txt"
CSV_LOG="${OUTPUT_DIR}/wifi_summary_log.csv"

echo "[*] Running Wi-Fi scan for '$LOCATION'..."
nmcli -f SSID,BSSID,FREQ,CHAN,SIGNAL,RATE,SECURITY dev wifi list > "$SCAN_FILE"

# Get default gateway
GATEWAY_IP=$(ip route | awk '/^default/ {print $3}')
if [ -z "$GATEWAY_IP" ]; then
  echo "[!] Could not determine default gateway." | tee "$PING_FILE"
  GATEWAY_IP="N/A"
  LATENCY="N/A"
  LOSS="100%"
else
  echo "[*] Pinging default gateway at $GATEWAY_IP..."
  PING_STATS=$(ping -c 50 "$GATEWAY_IP" | tee "$PING_FILE" | tail -2)
  LATENCY=$(echo "$PING_STATS" | grep 'avg' | cut -d '/' -f5)
  LOSS=$(echo "$PING_STATS" | grep 'packet loss' | awk '{print $6}')
  [ -z "$LATENCY" ] && LATENCY="N/A"
  [ -z "$LOSS" ] && LOSS="100%"
fi

# Get connected SSID info
CONNECTED_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
SCAN_LINE=$(grep "$CONNECTED_SSID" "$SCAN_FILE" | head -1)

SSID=$(echo "$SCAN_LINE" | awk '{print $1}')
BSSID=$(echo "$SCAN_LINE" | awk '{print $2}')
FREQ=$(echo "$SCAN_LINE" | awk '{print $3}')
CHAN=$(echo "$SCAN_LINE" | awk '{print $4}')
SIGNAL=$(echo "$SCAN_LINE" | awk '{print $5}')
RATE=$(echo "$SCAN_LINE" | awk '{print $6}')
SECURITY=$(echo "$SCAN_LINE" | awk '{print $7}')

# Get signal strength in dBm
WIFI_INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')
SIGNAL_DBM=$(iw dev "$WIFI_INTERFACE" link | awk '/signal/ {print $2, $3}' 2>/dev/null)
[ -z "$SIGNAL_DBM" ] && SIGNAL_DBM="N/A"

# Log header if missing
if [ ! -f "$CSV_LOG" ]; then
  echo "Timestamp,Location,SSID,BSSID,Freq,Chan,Signal(%),Signal(dBm),Rate,Security,AvgLatency(ms),PacketLoss" > "$CSV_LOG"
fi

# Append entry
echo "$TIMESTAMP,\"$LOCATION\",$SSID,$BSSID,$FREQ,$CHAN,$SIGNAL,\"$SIGNAL_DBM\",$RATE,$SECURITY,$LATENCY,$LOSS" >> "$CSV_LOG"

echo "[✓] Scan complete. Files saved in $OUTPUT_DIR"

