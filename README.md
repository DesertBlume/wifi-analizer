# Wi-Fi Analyzer & Roaming Test Suite

A collection of Bash and Python tools to capture, analyze, and visualize Wi-Fi signal strength, roaming behavior, and latency across different environments (e.g., campuses, offices, multi-floor buildings).

Designed for real-world testing, this suite makes it easy to log, review, and anonymize wireless scan data in a structured, reproducible way.

---

## 📂 Contents

- **Bash Scripts**
  - `wifi_test.sh` — quick scan + ping at a specific location
  - `v2-roaming.sh` — logs roaming behavior over time
  - `v2-lock_to_ap_test.sh` — locks to a single AP during movement
  - `v3wifi_test.sh` — enhanced scan with gateway and signal checks

- **Python Scripts**
  - `plot_roaming.py` — static plots of signal vs. time
  - `gif_roaming.py` — animated GIFs of roaming behavior
  - `redact_wifi.py` — redacts MACs & personal SSIDs from logs before publishing

---

## 🔧 Setup

```bash
# Make all scripts executable
chmod +x *.sh *.py

# Set up Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
````

---

## 🧪 Script Overviews

### `wifi_test.sh`

Performs a single Wi-Fi scan and ping test at a specified location.

* Output:

  * `wifi_logs/wifi_scan_<location>_<timestamp>.txt`
  * `wifi_logs/ping_<location>_<timestamp>.txt`
  * `wifi_logs/wifi_summary_log.csv`

* Captures:

  * SSID, BSSID, frequency, signal %, bitrate, security
  * Average latency to 8.8.8.8 and packet loss

---

### `v2-roaming.sh`

Logs signal strength and roaming transitions every 10 seconds as you move.

* Output: `wifi_roaming_logs/roaming_<location>_<timestamp>.csv`
* Ideal for walk tests across floors or buildings.

---

### `v2-lock_to_ap_test.sh`

Locks the device to a specific BSSID (AP) to test sticky performance.

* Disables autoconnect, clones current network profile, logs signal and stability.
* Output: `ap_lock_test_logs/aplock_<profile>_<location>_<timestamp>.csv`

---

### `v3wifi_test.sh`

Improved Wi-Fi test script with:

* Gateway detection
* Better SSID/BSSID parsing
* Fault tolerance and improved logging

---

## 📊 Visualization Tools

### `plot_roaming.py`

Static plot of signal strength vs. time, color-coded by BSSID.

* Loads latest roaming CSV
* Output: `plots/<filename>.png`

---

### `gif_roaming.py`

Creates animated signal strength GIFs that show AP transitions visually.

* Uses historical roaming logs
* Output: `wifi_roaming.gif`

---

## 🔒 Privacy & Data Cleanup

### `redact_wifi.py`

Redacts **sensitive data** from raw Wi-Fi logs before pushing to GitHub or sharing publicly.

* Replaces all MAC addresses (BSSIDs) with `XX:XX:XX:XX:XX:XX`
* Redacts personal SSIDs like `iPhone`, `Joeyboy`, `AirPort Extreme`, `DIRECT-*`, `NOKIA-*` with `REDACTED_SSID`
* Backs up the original unmodified file to a `.gitignore`d folder (`redacted_backup/`)

#### 🔧 Usage

```bash
./redact_wifi.py --input wifi_data.txt
```

Optional:

```bash
--output wifi_cleaned.txt       # Custom output name
--backup-dir .backups           # Custom backup folder
```

---

## 📁 Output Format Summary

| Script                  | Output Type   | Directory                              |
| ----------------------- | ------------- | -------------------------------------- |
| `wifi_test.sh`          | txt, csv      | `wifi_logs/`                           |
| `v2-roaming.sh`         | csv           | `wifi_roaming_logs/`                   |
| `v2-lock_to_ap_test.sh` | csv           | `ap_lock_test_logs/`                   |
| `plot_roaming.py`       | png           | `plots/`                               |
| `gif_roaming.py`        | gif           | root (`wifi_roaming.gif`)              |
| `redact_wifi.py`        | redacted txt  | wherever you choose                    |
|                         | original copy | `redacted_backup/` (auto `.gitignore`) |

---

## 💡 Best Practices

* Use consistent names for `location` and `profile` when running tests
* Run long scans in `tmux` to avoid interruptions
* Use `redact_wifi.py` before pushing to GitHub to protect privacy
* Use a GPS tracker or floor plan for enhanced mapping
* Add custom filters to `redact_wifi.py` if you're scanning personal networks

---

## 📈 Future Improvements

* Real-time dashboards using `plotly` or `Dash`
* Automatic PDF report generation
* Distance estimation using step counts or GPS
* Auto-upload logs to Google Drive or S3
* Central wrapper CLI (`wifi-cli`) for all scripts

---

## ✅ Requirements

* **Linux-based OS**
* **Bash tools**: `nmcli`, `iw`, `ping`, `awk`, `grep`, `sed`, `bc`
* **Python 3**

  * `pandas`
  * `matplotlib`
  * `imageio`

---

## 👥 Contributions

Pull requests welcome! Especially around:

* Better visualization options
* Vendor-specific quirks
* Cross-platform support

---

## 📜 License

MIT License — free to use and adapt.

