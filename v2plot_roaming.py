#!/usr/bin/env python3

import os
import glob
import pandas as pd
import matplotlib.pyplot as plt

def load_latest_csv(folder):
    files = glob.glob(os.path.join(folder, "roaming_*.csv"))
    if not files:
        print("No roaming CSV files found in", folder)
        return None
    files.sort()
    return files[-1]  # Most recent file

def clean_and_plot(csv_path):
    print(f"Loading file: {csv_path}")
    df = pd.read_csv(csv_path)

    # Parse timestamps
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])

    # Clean signal dBm values
    df["Signal(dBm)"] = (
        df["Signal(dBm)"]
        .astype(str)
        .str.replace('"', '', regex=False)
        .str.extract(r"(-?\d+)")[0]
        .astype(float)
    )

    # Plot signal strength over time, colored by BSSID
    plt.figure(figsize=(14, 7))
    bssids = df["BSSID"].unique()

    for bssid in bssids:
        bssid_df = df[df["BSSID"] == bssid]
        plt.plot(
            bssid_df["Timestamp"],
            bssid_df["Signal(dBm)"],
            marker='o',
            linestyle='-',
            label=bssid
        )

    plt.title("Wi-Fi Signal Strength Over Time (Color-coded by BSSID)")
    plt.xlabel("Timestamp")
    plt.ylabel("Signal Strength (dBm)")
    plt.xticks(rotation=45)
    plt.legend(title="BSSID", bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.grid(True)
    plt.tight_layout()

    # Create output directory if it doesn't exist
    output_dir = "plots"
    os.makedirs(output_dir, exist_ok=True)

    # Create dynamic output filename
    base_name = os.path.basename(csv_path).replace(".csv", "")
    output_path = os.path.join(output_dir, f"{base_name}.png")

    # Save the figure
    plt.savefig(output_path)
    print(f"Plot saved to {output_path}")

if __name__ == "__main__":
    folder = "wifi_roaming_logs"
    latest_csv = load_latest_csv(folder)
    if latest_csv:
        clean_and_plot(latest_csv)

