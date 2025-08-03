# Makefile for Lip-Read project

# Determine OS-specific paths
VENV_DIR := .venv
ifeq ($(OS),Windows_NT)
	PYTHON := $(VENV_DIR)/Scripts/python.exe
else
	PYTHON := $(VENV_DIR)/bin/python
endif

.PHONY: setup run clean

chaplin/.git:
	git clone --depth 1 https://github.com/amanvirparhar/chaplin chaplin

$(VENV_DIR):
	python -m venv $(VENV_DIR)

setup: chaplin/.git $(VENV_DIR)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt
	@echo "Setup complete. Use 'make run' to start the demo."

run: setup
	$(PYTHON) chaplin/main.py

clean:
	rm -rf chaplin $(VENV_DIR)
