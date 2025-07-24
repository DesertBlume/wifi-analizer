#!/bin/bash

# Usage: ./lock_to_ap_test.sh <locked_profile_name> "Location Label"
LOCKED_PROFILE="$1"
LOCATION="$2"

if [ -z "$LOCKED_PROFILE" ] || [ -z "$LOCATION" ]; then
  echo "Usage: $0 <locked_profile_name> \"Location Label (e.g. OneAP_Test_FirstFloor)\""
  exit 1
fi

# Setup
OUTPUT_DIR="./ap_lock_test_logs"
mkdir -p "$OUTPUT_DIR"
CSV_FILE="${OUTPUT_DIR}/aplock_${LOCKED_PROFILE}_${LOCATION// /_}_$(date +"%Y-%m-%d_%H-%M-%S").csv"

WIFI_INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')
LINK_INFO=$(iw dev "$WIFI_INTERFACE" link)

# Get active connection name (with credentials)
ACTIVE_PROFILE=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$WIFI_INTERFACE" | cut -d: -f1)
SSID=$(echo "$LINK_INFO" | awk -F': ' '/SSID/ {print $2}')
BSSID=$(echo "$LINK_INFO" | awk '/Connected to/ {print $3}')

if [ -z "$SSID" ] || [ -z "$BSSID" ] || [ -z "$ACTIVE_PROFILE" ]; then
  echo "[!] You must be connected to Wi-Fi to create a locked profile."
  exit 1
fi

# Delete old locked profile if it exists
nmcli connection delete "$LOCKED_PROFILE" &>/dev/null

# Clone active profile and lock to current BSSID
echo "[*] Cloning '$ACTIVE_PROFILE' -> '$LOCKED_PROFILE' and locking to $BSSID"
nmcli connection clone "$ACTIVE_PROFILE" "$LOCKED_PROFILE"
nmcli connection modify "$LOCKED_PROFILE" wifi.bssid "$BSSID"
nmcli connection modify "$LOCKED_PROFILE" connection.autoconnect no

# Disconnect current and bring up locked profile
echo "[*] Switching to locked connection ($LOCKED_PROFILE)..."
nmcli connection down "$ACTIVE_PROFILE" &>/dev/null
nmcli connection up "$LOCKED_PROFILE"

# Log header
echo "Timestamp,SSID,BSSID,Freq,Chan,Signal(%),Signal(dBm),Bitrate,Location" > "$CSV_FILE"

echo ""
echo "=================================================================="
echo "   🔒 Locked to BSSID: $BSSID"
echo "   📡 Starting signal strength walk test for '$LOCATION'"
echo "   📁 Logging to: $CSV_FILE"
echo "=================================================================="
echo "❗ Walk around and press Ctrl+C when finished."
echo ""

# Logging loop
while true; do
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  LINK_INFO=$(iw dev "$WIFI_INTERFACE" link)

  SSID_NOW=$(echo "$LINK_INFO" | awk -F': ' '/SSID/ {print $2}')
  BSSID_NOW=$(echo "$LINK_INFO" | awk '/Connected to/ {print $3}')
  FREQ=$(echo "$LINK_INFO" | awk '/freq:/ {print $2}')
  SIGNAL_DBM=$(echo "$LINK_INFO" | awk '/signal:/ {print $2, $3}')
  BITRATE=$(echo "$LINK_INFO" | awk -F': ' '/tx bitrate/ {print $2}')
  SIGNAL_PERCENT=$(nmcli -f active,ssid,signal dev wifi | grep "^yes" | awk '{print $3}')

  # Channel mapping
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
  [ -z "$SSID_NOW" ] && SSID_NOW="N/A"
  [ -z "$BSSID_NOW" ] && BSSID_NOW="N/A"
  [ -z "$FREQ" ] && FREQ="N/A"
  [ -z "$CHAN" ] && CHAN="N/A"
  [ -z "$SIGNAL_DBM" ] && SIGNAL_DBM="N/A"
  [ -z "$SIGNAL_PERCENT" ] && SIGNAL_PERCENT="N/A"
  [ -z "$BITRATE" ] && BITRATE="N/A"

  echo "$TIMESTAMP,$SSID_NOW,$BSSID_NOW,$FREQ,$CHAN,$SIGNAL_PERCENT,\"$SIGNAL_DBM\",$BITRATE,\"$LOCATION\"" >> "$CSV_FILE"
  echo "[$TIMESTAMP] Signal: $SIGNAL_DBM ($SIGNAL_PERCENT%) | Chan: $CHAN | Freq: $FREQ | BSSID: $BSSID_NOW"

  sleep 10
done

