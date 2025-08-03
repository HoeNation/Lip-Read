FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir requests

# Clone Chaplin repository and install its requirements
RUN git clone --depth 1 https://github.com/amanvirparhar/chaplin chaplin \
    && pip install --no-cache-dir -r chaplin/requirements.txt

# Download model weights and configuration
RUN python - <<'PYCODE'
import requests, os
from tqdm import tqdm

def download(url, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    r = requests.get(url, stream=True)
    r.raise_for_status()
    total = int(r.headers.get('content-length', 0))
    with open(path, 'wb') as f, tqdm(total=total, unit='B', unit_scale=True, unit_divisor=1024, desc=path) as bar:
        for chunk in r.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)
                bar.update(len(chunk))

download('https://storage.googleapis.com/chaplin-vsr/vsr_v2.ckpt', 'chaplin/models/vsr_v2.ckpt')
download('https://storage.googleapis.com/chaplin-vsr/vsr_v2.yaml', 'chaplin/configs/vsr_v2.yaml')
PYCODE

# Copy project files
COPY . .

CMD ["python", "chaplin/main.py", "--config-path=configs", "--config-name=vsr_v2.yaml"]
