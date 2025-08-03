# Lip-Reading AI Project (Unified)

This project is a complete setup for real-time lip-reading using the Chaplin model and optional integration with language models (LLMs) via Ollama.

## 🧰 Simple Setup

Clone the repository and run the setup script (requires Python 3.10 or 3.11 due to Mediapipe's wheel support):

```bash
git clone <REPO_URL>
cd Lip-Read
./run.sh
```

The `run.sh` script downloads the Chaplin model, creates a Python virtual environment, installs dependencies, and launches the demo. To prepare the environment without starting the demo, run:

```bash
./run.sh --no-run
```

### Windows 11 with Make

If you're using Git Bash or another environment with `make`, you can set up and run the demo using:

```bash
make setup   # downloads Chaplin and installs dependencies
make run     # launches the lip-reading demo
```

## 🔗 Components
- **Chaplin (Core Model)**: https://github.com/amanvirparhar/chaplin
- **CUDA Toolkit (GPU acceleration)**: https://developer.nvidia.com/cuda-downloads
- **Git**: https://git-scm.com/download/win
- **Python 3.10 or 3.11**: https://www.python.org/downloads/windows/
- **PyTorch (Deep Learning Engine)**: https://pytorch.org/get-started/locally/
- **Ollama (LLM support)**: https://ollama.com/download/windows

## 🔍 Detailed Walkthrough
1. **Clone the project**
   ```bash
   git clone <REPO_URL>
   cd Lip-Read
   ```
2. **Download the Chaplin model**
   - `run.sh` checks for `chaplin/` and clones [Chaplin](https://github.com/amanvirparhar/chaplin) if missing.
3. **Create a virtual environment**
   Use Python 3.10 or 3.11 explicitly if your system's default is newer:
   ```bash
   python3.10 -m venv .venv  # or python3.11
   source .venv/bin/activate
   ```
4. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   pip install -r chaplin/requirements.txt
   ```
5. **Run the demo**
   ```bash
   python chaplin/main.py
   ```
   Running `./run.sh` executes these steps automatically and starts the model unless you pass `--no-run`.

## 🐳 Docker

A Dockerfile is included to run the demo inside a container.

Build the image:

```bash
docker build -t lip-read .
```

Run the demo:

```bash
docker run --rm -it lip-read
```

To upload the image to Docker Hub:

```bash
docker tag lip-read <your-username>/lip-read:latest
docker push <your-username>/lip-read:latest
```
