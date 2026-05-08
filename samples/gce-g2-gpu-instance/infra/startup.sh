#!/bin/bash

# Logging

echo "Starting deployment of Gemma LLM..."

# Install NVIDIA Drivers (Official Google Unified Installer)
echo "Installing official Google Cloud GPU drivers..."
if ! command -v nvidia-smi &> /dev/null; then
    # Use the cloud-amd64 meta-package for stable headers on GCE
    apt-get update && apt-get install -y linux-headers-cloud-amd64 python3-pip curl
    mkdir -p /opt/google/cuda-installer/
    cd /opt/google/cuda-installer/
    curl -fSsL -O https://storage.googleapis.com/compute-gpu-installation-us/installer/v1.5.0/cuda_installer.pyz
    # Non-interactive installation (using NFB branch as required by Debian 12)
    python3 cuda_installer.pyz install_cuda --installation-branch=nfb
else
    echo "NVIDIA drivers already installed."
fi

# Install Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Configure Ollama to listen on ALL interfaces (required for IAP tunnel)
echo "Configuring Ollama host..."
mkdir -p /etc/systemd/system/ollama.service.d
cat <<EOF > /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
EOF

systemctl daemon-reload
systemctl restart ollama

# Pre-download Gemma 4 26B (Ollama version)
echo "Pulling Gemma 4 26B model..."
ollama pull gemma4:26b

# Pre-load the model into memory
echo "Pre-loading gemma4:26b into GPU memory..."
curl -s http://localhost:11434/api/generate -d '{"model": "gemma4:26b"}' > /dev/null

echo "Deployment complete!"
