#!/usr/bin/env bash
# Simple setup and execution script for the Lip-Read project
set -e

# Ensure we are running on a Python version supported by Mediapipe
PY_VERSION=$(python3 -c 'import sys; print("{}.{}".format(*sys.version_info[:2]))')
case $PY_VERSION in
  3.10|3.11)
    ;; # supported
  *)
    echo "Error: Python $PY_VERSION detected. Please use Python 3.10 or 3.11." >&2
    exit 1
    ;;
esac

# Clone Chaplin repository if missing
if [ ! -d "chaplin/.git" ]; then
  echo "Downloading Chaplin model repository..."
  rm -rf chaplin
  git clone --depth 1 https://github.com/amanvirparhar/chaplin chaplin
fi

# Set the path to the Python 3.9 executable
# This path is hardcoded to bypass environment variable issues.
PYTHON_EXE="/c/Users/JB_Ma/AppData/Local/Programs/Python/Python39/python.exe"

# Create Python virtual environment if needed
if [ ! -d ".venv" ]; then
  "$PYTHON_EXE" -m venv .venv
fi
source .venv/Scripts/activate

# Install Python dependencies
"$PYTHON_EXE" -m pip install --upgrade pip
"$PYTHON_EXE" -m pip install -r requirements.txt
"$PYTHON_EXE" -m pip install -r chaplin/requirements.txt
"$PYTHON_EXE" -m pip install requests

# Python script to download files using requests
"$PYTHON_EXE" -c '
import requests
import os
from tqdm import tqdm

def download_file(url, output_path):
    print(f"Downloading {url} to {output_path}...")
    try:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        response = requests.get(url, stream=True, allow_redirects=True)
        response.raise_for_status()

        total_size = int(response.headers.get("content-length", 0))
        with open(output_path, "wb") as f, tqdm(
            desc=output_path,
            total=total_size,
            unit="B",
            unit_scale=True,
            unit_divisor=1024,
        ) as bar:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
                    bar.update(len(chunk))
        print("Download successful.")
    except Exception as e:
        print(f"Error downloading {url}: {e}")
        os.remove(output_path) if os.path.exists(output_path) else None

# Download model weights and config with corrected links from a new source.
if not os.path.isfile("chaplin/models/vsr_v2.ckpt"):
    download_file("https://storage.googleapis.com/chaplin-vsr/vsr_v2.ckpt", "chaplin/models/vsr_v2.ckpt")
if not os.path.isfile("chaplin/configs/vsr_v2.yaml"):
    download_file("https://storage.googleapis.com/chaplin-vsr/vsr_v2.yaml", "chaplin/configs/vsr_v2.yaml")

'

# Run the demo with the required Hydra config file
if [ "$1" != "--no-run" ]; then
  "$PYTHON_EXE" chaplin/main.py --config-path="configs" --config-name="vsr_v2.yaml" "$@"
else
  echo "Environment setup complete. Run the model with ./run.sh"
fi
