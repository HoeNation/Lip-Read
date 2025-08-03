#!/usr/bin/env bash
# Simple setup and execution script for the Lip-Read project
set -e

# Clone Chaplin repository if missing
if [ ! -d "chaplin/.git" ]; then
  echo "Downloading Chaplin model repository..."
  rm -rf chaplin
  git clone --depth 1 https://github.com/amanvirparhar/chaplin chaplin
fi

# Create Python virtual environment if needed
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install -r chaplin/requirements.txt

if [ "$1" != "--no-run" ]; then
  python chaplin/main.py "$@"
else
  echo "Environment setup complete. Run the model with ./run.sh"
fi
