#!/bin/bash

LOCATION="$1"
if [ -z "$LOCATION" ]; then
  echo "Usage: $0 \"Location Label (e.g. Floor1_RoamingTest)\""
  exit 1
fi

# Setup
OUTPUT_DIR="./wifi_roaming_logs"
mkdir -p "$OUTPUT_DIR"
CSV_FILE="${OUTPUT_DIR}/roaming_${LOCATION}_$(date +"%Y-%m-%d_%H-%M-%S").csv"
WIFI_INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')

# Header
echo "Timestamp,SSID,BSSID,Freq,Chan,Signal(%),Signal(dBm),Bitrate,Location" > "$CSV_FILE"

# Intro
echo ""
echo "===================================================="
echo "   🚶 Wi-Fi Roaming Test Tracker Started"
echo "===================================================="
echo ""
echo "Instructions:"
echo " 1. Start walking around slowly."
echo " 2. Pause in different locations (hallways, offices, corners)."
echo " 3. Watch for AP switches (BSSID changes)."
echo ""
echo "❗ Press Ctrl+C to stop logging when you're done."
echo ""

# Start tracking
while true; do
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

  # Get link info
  LINK_INFO=$(iw dev "$WIFI_INTERFACE" link)

  SSID=$(echo "$LINK_INFO" | awk -F': ' '/SSID/ {print $2}')
  BSSID=$(echo "$LINK_INFO" | awk -F' ' '/Connected to/ {print $3}')
  FREQ=$(echo "$LINK_INFO" | awk '/freq:/ {print $2}')
  SIGNAL_DBM=$(echo "$LINK_INFO" | awk '/signal:/ {print $2, $3}')
  BITRATE=$(echo "$LINK_INFO" | awk -F': ' '/tx bitrate/ {print $2}')
  SIGNAL_PERCENT=$(nmcli -f active,ssid,signal dev wifi | grep "^yes" | awk '{print $3}')

  # Channel mapping from frequency
  if [[ "$FREQ" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    if (( $(echo "$FREQ < 2500" | bc -l) )); then
      CHAN=$(printf "%.0f" "$(echo "($FREQ - 2407)/5" | bc -l)")
    elif (( $(echo "$FREQ > 4900" | bc -l) )); then
      CHAN=$(printf "%.0f" "$(echo "($FREQ - 5000)/5" | bc -l)")
    else
      CHAN="Unknown"
    fi
  else
    CHAN="N/A"
  fi

  # Fallbacks
  [ -z "$SSID" ] && SSID="N/A"
  [ -z "$BSSID" ] && BSSID="N/A"
  [ -z "$FREQ" ] && FREQ="N/A"
  [ -z "$CHAN" ] && CHAN="N/A"
  [ -z "$SIGNAL_DBM" ] && SIGNAL_DBM="N/A"
  [ -z "$SIGNAL_PERCENT" ] && SIGNAL_PERCENT="N/A"
  [ -z "$BITRATE" ] && BITRATE="N/A"

  # Log entry
  echo "$TIMESTAMP,$SSID,$BSSID,$FREQ,$CHAN,$SIGNAL_PERCENT,\"$SIGNAL_DBM\",$BITRATE,\"$LOCATION\"" >> "$CSV_FILE"

  # Console feedback
  echo "[$TIMESTAMP] SSID: $SSID | BSSID: $BSSID | Freq: $FREQ MHz | Chan: $CHAN | Signal: $SIGNAL_DBM ($SIGNAL_PERCENT%)"

  sleep 10
done

