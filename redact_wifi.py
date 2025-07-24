#!/usr/bin/env python3
import argparse
import re
from pathlib import Path
from shutil import copyfile

def redact_wifi_file(input_path: Path, output_path: Path, backup_dir: Path):
    # Ensure backup directory exists
    backup_dir.mkdir(exist_ok=True)

    # Backup original file
    backup_path = backup_dir / input_path.name
    copyfile(input_path, backup_path)

    # Add backup_dir to .gitignore
    gitignore_path = Path(".gitignore")
    if gitignore_path.exists():
        with open(gitignore_path, "r+") as f:
            lines = f.read().splitlines()
            if f"{backup_dir}/" not in lines:
                f.write(f"\n{backup_dir}/\n")
    else:
        with open(gitignore_path, "w") as f:
            f.write(f"{backup_dir}/\n")

    # Read input file
    with open(input_path, "r") as f:
        data = f.read()

    # Redact MAC addresses
    data = re.sub(r"([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}", "XX:XX:XX:XX:XX:XX", data)

    # Redact personal SSIDs
    data = re.sub(r"\b(iPhone|Joeyboy|AirPort Extreme|NOKIA-[\w-]+|DIRECT-[\w-]+)\b", "REDACTED_SSID", data)

    # Write redacted file
    with open(output_path, "w") as f:
        f.write(data)

    return str(output_path), str(backup_path)

# CLI setup
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Redact sensitive Wi-Fi info from a scan log.")
    parser.add_argument("--input", required=True, help="Input file containing raw Wi-Fi scan")
    parser.add_argument("--output", help="Output redacted file path")
    parser.add_argument("--backup-dir", default="redacted_backup", help="Directory to store original unredacted file")

    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output) if args.output else Path(input_path.stem + "_redacted" + input_path.suffix)
    backup_dir = Path(args.backup_dir)

    redacted_result, backup_result = redact_wifi_file(input_path, output_path, backup_dir)

    print(f"✅ Redacted file saved at: {redacted_result}")
    print(f"📁 Original backup saved at: {backup_result}")

