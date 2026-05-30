# GCP Samples

<p align="center">
  <img src="https://img.icons8.com/?size=100&id=fpGM2cINbbu4&format=png&color=000000" alt="Google Cloud"/>
</p>

<p align="center">
  <strong>A curated collection of industrial-grade Google Cloud Platform samples</strong><br/>
  Terraform · Cloud Run · GKE · Security by Design · CI/CD
</p>

---

## 🚀 Getting Started

### Prerequisites

Install the required tools before running any sample:

**macOS (Homebrew)**

```bash
brew install terraform go-task/tap/go-task trivy pre-commit tflint terraform-docs gitleaks libpq
brew install --cask google-cloud-sdk
# On macOS, link libpq to get psql
echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

**Linux (apt + curl)**

```bash
sudo apt-get update && sudo apt-get install -y curl unzip python3-pip

# Terraform
curl -fsSL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip \
  -o terraform.zip && unzip terraform.zip && sudo mv terraform /usr/local/bin/

# Task
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

# tflint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# terraform-docs
curl -sSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/latest/download/terraform-docs-linux-amd64.tar.gz \
  && tar -xzf terraform-docs.tar.gz && sudo mv terraform-docs /usr/local/bin/

# gitleaks
curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64_tar.gz \
  | tar -xz && sudo mv gitleaks /usr/local/bin/

# pre-commit
pip install pre-commit

# gcloud SDK
curl https://sdk.cloud.google.com | bash && exec -l $SHELL
```

### Authenticate with GCP

```bash
gcloud auth application-default login
gcloud config set project <YOUR_PROJECT_ID>
```

---

## 📁 Samples

| Name | Description | README |
|---|---|---|
| [base](samples/base/) | Déploiement du réseau VPC de base avec sous-réseaux isolés. | [→ README](samples/base/README.md) |
| [cloudrun-simple-service](samples/cloudrun-simple-service/) | Service web Cloud Run Python déployé sur VPC privé avec Terraform. | [→ README](samples/cloudrun-simple-service/README.md) |
| [cloudrun-simple-job](samples/cloudrun-simple-job/) | Job Cloud Run Python pour exécution de batchs asynchrones. | [→ README](samples/cloudrun-simple-job/README.md) |
| [cloudrun-bastion](samples/cloudrun-bastion/) | Proxy SOCKS5 sur Cloud Run protégé par IAP via HTTPS Load Balancer avec Direct VPC Egress. | [→ README](samples/cloudrun-bastion/README.md) |
| [gke-base-sample](samples/gke-base-sample/) | Cluster GKE Autopilot privé avec Nginx interne sur ILB et NetworkPolicy. | [→ README](samples/gke-base-sample/README.md) |
| [gce-g2-gpu-instance](samples/gce-g2-gpu-instance/) | Instance GCE G2 avec GPU NVIDIA L4 pour exécuter des LLMs (Gemma/Ollama) via tunnel IAP privé. | [→ README](samples/gce-g2-gpu-instance/README.md) |
| [litellm-proxy-cloudrun](samples/litellm-proxy-cloudrun/) | Passerelle OpenAI-compatible LiteLLM sur Cloud Run pour Vertex AI (Gemini, Claude), avec master key en Secret Manager. | [→ README](samples/litellm-proxy-cloudrun/README.md) |

---

## 🗂️ Project Structure

```text
gcp-samples/
├── AGENT.md              # Shared AI agent config (persona, rules, skills, standards)
├── GEMINI.md             # LLM-specific instructions (Gemini CLI / Antigravity)
├── CLAUDE.md             # LLM-specific instructions (Claude Code)
├── .agents/              # Shared AI agent rules & skills (single source of truth)
│   ├── rules/            # Mandatory rules (security, guidelines)
│   └── skills/
│       ├── best-practice/ # Core engineering standards (Terraform, Taskfile, Pre-commit)
│       ├── community/     # Third-party skills (Hashicorp, drawio)
│       └── the-documentalist/ # Documentation standards
├── .claude/rules/        # Symlinks → .agents/rules/ (Claude Code compatibility)
├── samples/              # GCP use-case samples
│   ├── base/
│   ├── cloudrun-service/
│   ├── cloudrun-job/
│   ├── cloudrun-bastion/
│   └── gke-base-sample/
└── .pre-commit-config.yaml
```

---

## 📜 License

This project is intended for educational and demonstration purposes.
