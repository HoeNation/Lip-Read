# Lip-Reading AI Project (Unified)

This project is a complete setup for real-time lip-reading using the Chaplin model and optional integration with language models (LLMs) via Ollama.

## 🚀 Quick Start

```bash
git clone <REPO_URL>
cd Lip-Read
./run.sh
```

The `run.sh` script automatically downloads the Chaplin repository, creates a Python virtual environment, installs the required Python packages, and launches the demo. To prepare the environment without running the model, use:

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
- **Python 3.10+**: https://www.python.org/downloads/windows/
- **PyTorch (Deep Learning Engine)**: https://pytorch.org/get-started/locally/
- **Ollama (LLM support)**: https://ollama.com/download/windows

## 📁 Manual Setup
1. Install dependencies using files in the `install/` folder.
2. Clone the repo and create a virtual environment.
3. Download the Chaplin repository into `chaplin/` and run `chaplin/main.py` to begin.
