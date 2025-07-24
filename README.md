# Wi-Fi Signal and Roaming Test Suite

This repository contains a suite of Bash and Python scripts for testing and analyzing Wi-Fi roaming behavior, signal strength, access point transitions, and latency in real environments such as campuses, offices, and multi-floor buildings.

Each script generates timestamped logs in structured directories, making it easy to collect and analyze performance data over time. New Python scripts allow you to visualize these changes in both static and animated formats.

---

## Contents

### Bash Scripts

#### `wifi_test.sh`

Performs a basic Wi-Fi scan and ping test for a specified location.

- Outputs:
  - Wi-Fi scan: `wifi_logs/wifi_scan_<location>_<timestamp>.txt`
  - Ping statistics: `wifi_logs/ping_<location>_<timestamp>.txt`
  - Summary: `wifi_logs/wifi_summary_log.csv`

- Captures:
  - SSID, BSSID, Frequency, Channel, Signal Percentage, Bitrate, Security
  - Average latency to 8.8.8.8 and packet loss

#### `v2-roaming.sh`

Monitors roaming behavior by logging Wi-Fi link information while walking through the environment.

- Logs recorded every 10 seconds to:  
  `wifi_roaming_logs/roaming_<location>_<timestamp>.csv`

- Displays real-time:
  - SSID, BSSID, frequency, signal strength, channel, bitrate

#### `v2-lock_to_ap_test.sh`

Locks the client to the currently connected BSSID and monitors its performance during a walk test.

- Clones the active profile, locks to the BSSID, and disables autoconnect
- Logs saved to:  
  `ap_lock_test_logs/aplock_<profile>_<location>_<timestamp>.csv`

#### `v3wifi_test.sh`

Improved version of `wifi_test.sh` with:

- Gateway-aware latency testing
- Automatic SSID/BSSID detection
- Better fault tolerance for missing data

---

### Python Scripts

#### `plot_roaming.py`

Generates a **static plot** of Wi-Fi signal strength over time, color-coded by BSSID to visualize roaming transitions.

- Loads the latest roaming CSV from `wifi_roaming_logs/`
- Saves PNG plot to `plots/<log_filename>.png`

#### `gif_roaming.py`

Generates an **animated GIF** that shows how signal strength changes over time across BSSIDs.

- Builds frame-by-frame plots using historical logs
- Saves animated output to `wifi_roaming.gif`

---

## Getting Started

Make all scripts executable:

```bash
chmod +x *.sh *.py
````

Install Python dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Example Usage

```bash
# Run roaming test
./v2-roaming.sh "FirstFloor"

# Plot signal strength
./plot_roaming.py

# Generate animated GIF
./gif_roaming.py
```

---

## Output Format

* CSV logs: roaming, AP lock, scans, latency
* PNG: static visualizations by BSSID
* GIF: animated roaming visual playback
* All filenames are timestamped and saved to appropriate directories

---

## Requirements

Linux system with:

* Bash tools: `nmcli`, `iw`, `ping`, `awk`, `grep`, `sed`, `bc`
* Python 3 with:

  * `pandas`
  * `matplotlib`
  * `imageio`

---

## Future Improvements

### Data Visualization

* Integrate BSSID channel overlays
* Interactive dashboard using `plotly` or `Dash`
* PDF report generation

### Distance Estimation

* Step-based or GPS/BLE-based estimation of movement
* Annotate logs with estimated distance from AP

### Automation

* Wrapper script or CLI to select and run test types
* Auto-sync or email logs after each run

---

## Best Practices

* Run longer tests inside `tmux`
* Connect to Wi-Fi before using `v2-lock_to_ap_test.sh`
* Use consistent naming for locations and profiles
* Keep `venv/` excluded using `.gitignore`

---

## License

MIT License

---

## Contributions

Pull requests and issues welcome — especially for visualization, reporting, and device compatibility testing.

