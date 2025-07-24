#!/usr/bin/env python3

import os
import glob
import pandas as pd
import matplotlib.pyplot as plt
import imageio.v2 as imageio

def load_latest_csv(folder):
    files = glob.glob(os.path.join(folder, "roaming_*.csv"))
    if not files:
        print("No roaming CSV files found in", folder)
        return None
    files.sort()
    return files[-1]

def generate_frames(df, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    frames = []

    bssids = df["BSSID"].unique()
    for i in range(1, len(df) + 1):
        fig, ax = plt.subplots(figsize=(12, 6))
        for bssid in bssids:
            bssid_df = df.iloc[:i]
            bssid_df = bssid_df[bssid_df["BSSID"] == bssid]
            ax.plot(bssid_df["Timestamp"], bssid_df["Signal(dBm)"], marker='o', label=bssid)

        ax.set_title(f"Wi-Fi Signal Strength Up To {df.iloc[i-1]['Timestamp']}")
        ax.set_xlabel("Timestamp")
        ax.set_ylabel("Signal (dBm)")
        ax.legend(loc='upper left', bbox_to_anchor=(1.05, 1))
        ax.grid(True)
        plt.xticks(rotation=45)
        plt.tight_layout()

        frame_path = os.path.join(output_dir, f"frame_{i:03}.png")
        plt.savefig(frame_path)
        plt.close(fig)
        frames.append(imageio.imread(frame_path))

    return frames

def create_gif(frames, gif_path):
    imageio.mimsave(gif_path, frames, fps=4)
    print(f"GIF saved to {gif_path}")

if __name__ == "__main__":
    folder = "wifi_roaming_logs"
    latest_csv = load_latest_csv(folder)
    if latest_csv:
        print(f"Loading: {latest_csv}")
        df = pd.read_csv(latest_csv)

        df["Timestamp"] = pd.to_datetime(df["Timestamp"])
        df["Signal(dBm)"] = (
            df["Signal(dBm)"]
            .astype(str)
            .str.replace('"', '', regex=False)
            .str.extract(r"(-?\d+)")[0]
            .astype(float)
        )

        gif_output_dir = "frames"
        gif_path = "wifi_roaming.gif"

        frames = generate_frames(df, gif_output_dir)
        create_gif(frames, gif_path)

