#!/usr/bin/env bash
# Cross-platform setup and execution script for the Lip-Read project
set -euo pipefail

declare -a PYTHON_CMD=()

find_supported_python() {
  local candidates=("python3.11" "python3.10" "python3" "python")
  local candidate version

  for candidate in "${candidates[@]}"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      version=$("$candidate" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
      case "$version" in
        3.10|3.11)
          PYTHON_CMD=("$candidate")
          return 0
          ;;
      esac
    fi
  done

  if command -v py >/dev/null 2>&1; then
    for minor in 11 10; do
      local version_spec="3.${minor}"
      if version=$(py -"${version_spec}" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")' 2>/dev/null); then
        case "$version" in
          3.10|3.11)
            PYTHON_CMD=("py" "-${version_spec}")
            return 0
            ;;
        esac
      fi
    done
  fi

  return 1
}

if ! find_supported_python; then
  echo "Error: Could not find Python 3.10 or 3.11. Please install one of these versions and make it available on your PATH." >&2
  exit 1
fi

PY_VERSION=$("${PYTHON_CMD[@]}" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
echo "Using Python $PY_VERSION (${PYTHON_CMD[*]})."

if [ ! -d "chaplin/.git" ]; then
  echo "Downloading Chaplin model repository..."
  rm -rf chaplin
  git clone --depth 1 https://github.com/amanvirparhar/chaplin chaplin
fi

if [ ! -d ".venv" ]; then
  echo "Creating virtual environment with ${PYTHON_CMD[*]}..."
  "${PYTHON_CMD[@]}" -m venv .venv
fi

case "${OSTYPE:-}" in
  msys*|cygwin*|win*)
    VENV_PY=".venv/Scripts/python.exe"
    ;;
  *)
    VENV_PY=".venv/bin/python"
    ;;
esac

if [ ! -x "$VENV_PY" ]; then
  echo "Error: Could not find a Python executable in the virtual environment (expected at $VENV_PY)." >&2
  exit 1
fi

echo "Installing project dependencies..."
"$VENV_PY" -m pip install --upgrade pip
"$VENV_PY" -m pip install -r requirements.txt
"$VENV_PY" -m pip install -r chaplin/requirements.txt

echo "Ensuring Chaplin weights and configuration are available..."
"$VENV_PY" - <<'PYCODE'
import os
from pathlib import Path

import requests
from tqdm import tqdm

FILES = {
    "https://storage.googleapis.com/chaplin-vsr/vsr_v2.ckpt": Path("chaplin/models/vsr_v2.ckpt"),
    "https://storage.googleapis.com/chaplin-vsr/vsr_v2.yaml": Path("chaplin/configs/vsr_v2.yaml"),
}


def download(url: str, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    print(f"Downloading {url} -> {destination}")
    response = requests.get(url, stream=True, allow_redirects=True, timeout=60)
    response.raise_for_status()
    total = int(response.headers.get("content-length", 0))

    with destination.open("wb") as file_handle, tqdm(
        total=total,
        unit="B",
        unit_scale=True,
        unit_divisor=1024,
        desc=str(destination),
    ) as progress_bar:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:
                file_handle.write(chunk)
                progress_bar.update(len(chunk))


for url, path in FILES.items():
    if path.is_file():
        continue
    try:
        download(url, path)
    except Exception as exc:  # noqa: BLE001 - surface download issues to the caller
        if path.exists():
            path.unlink()
        raise SystemExit(f"Failed to download {url}: {exc}") from exc
PYCODE

RUN_DEMO=1
ARGS=()
for arg in "$@"; do
  if [ "$arg" = "--no-run" ]; then
    RUN_DEMO=0
  else
    ARGS+=("$arg")
  fi
done

if [ "$RUN_DEMO" -eq 1 ]; then
  "$VENV_PY" chaplin/main.py --config-path="configs" --config-name="vsr_v2.yaml" "${ARGS[@]}"
else
  echo "Environment setup complete. Run the model later with ./run.sh"
fi
