#!/bin/bash

# Runs at every boot (the resource policy starts the VM every day): each
# install runs once, and every downloaded installer is pinned and checked
# against its SHA-256 before it runs as root.

# Google cuda_installer, checksum of the GitHub release asset (same file on GCS).
CUDA_INSTALLER_VERSION="v1.5.0"
CUDA_INSTALLER_SHA256="83d4d0367c7a59fb6dc52d9e41accecaf4fcdb00d3dffe737de534fa9e901e84"
# Ollama install script from the pinned release tag; OLLAMA_VERSION also pins
# the binaries it downloads.
OLLAMA_VERSION="0.40.15"
OLLAMA_INSTALL_SHA256="25f64b810b947145095956533e1bdf56eacea2673c55a7e586be4515fc882c9f"
MODEL="gemma4:26b"

# Logging

echo "Starting deployment of Gemma LLM..."

# Install NVIDIA Drivers (Official Google Unified Installer)
echo "Installing official Google Cloud GPU drivers..."
if ! command -v nvidia-smi &> /dev/null; then
    # Use the cloud-amd64 meta-package for stable headers on GCE
    apt-get update && apt-get install -y linux-headers-cloud-amd64 python3-pip curl
    mkdir -p /opt/google/cuda-installer/
    cd /opt/google/cuda-installer/ || exit 1
    curl -fSsL -O "https://storage.googleapis.com/compute-gpu-installation-us/installer/${CUDA_INSTALLER_VERSION}/cuda_installer.pyz"
    echo "${CUDA_INSTALLER_SHA256}  cuda_installer.pyz" | sha256sum -c - || { echo "cuda_installer.pyz checksum mismatch, aborting"; exit 1; }
    # Non-interactive installation (using NFB branch as required by Debian 12)
    python3 cuda_installer.pyz install_cuda --installation-branch=nfb
else
    echo "NVIDIA drivers already installed."
fi

# Install Ollama (once)
if ! command -v ollama &> /dev/null; then
    echo "Installing Ollama ${OLLAMA_VERSION}..."
    curl -fsSL -o /tmp/ollama-install.sh "https://raw.githubusercontent.com/ollama/ollama/v${OLLAMA_VERSION}/scripts/install.sh"
    echo "${OLLAMA_INSTALL_SHA256}  /tmp/ollama-install.sh" | sha256sum -c - || { echo "Ollama install script checksum mismatch, aborting"; exit 1; }
    OLLAMA_VERSION="${OLLAMA_VERSION}" sh /tmp/ollama-install.sh
else
    echo "Ollama already installed: $(ollama --version)"
fi

# Configure Ollama to listen on ALL interfaces (required for IAP tunnel)
echo "Configuring Ollama host..."
mkdir -p /etc/systemd/system/ollama.service.d
cat <<CONF > /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
CONF

systemctl daemon-reload
systemctl restart ollama

# Wait for the API before talking to it
for _ in $(seq 1 30); do
    curl -sf http://localhost:11434/api/version > /dev/null && break
    sleep 2
done

# Pre-download Gemma 4 26B (Ollama version), only if not present yet
if ! ollama list | awk 'NR > 1 {print $1}' | grep -qx "${MODEL}"; then
    echo "Pulling ${MODEL}..."
    ollama pull "${MODEL}"
fi

# Pre-load the model into memory
echo "Pre-loading ${MODEL} into GPU memory..."
curl -s http://localhost:11434/api/generate -d "{\"model\": \"${MODEL}\"}" > /dev/null

echo "Deployment complete!"
