# GCP Samples

<p align="center">
  <img src="https://www.gstatic.com/devrel-devsite/prod/v0e0f589edd85502a40d78d7d0825db8ea5ef3b99ab4070381ee86977c9168730/cloud/images/cloud-logo.svg" alt="Google Cloud" width="200"/>
</p>

<p align="center">
  <strong>A curated collection of industrial-grade Google Cloud Platform samples</strong><br/>
  Terraform · Cloud Run · Security by Design · CI/CD
</p>

---

## 🚀 Getting Started

### Prerequisites

Install the required tools before running any sample:

**macOS (Homebrew)**

```bash
brew install terraform go-task/tap/go-task trivy pre-commit tflint terraform-docs gitleaks
brew install --cask google-cloud-sdk
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
| [cloudrun-simple](samples/cloudrun-simple/) | Service web et job Cloud Run Python déployés sur VPC privé avec Terraform, Trivy et KICS. | [→ README](samples/cloudrun-simple/README.md) |
| [cloudrun-bastion](samples/cloudrun-bastion/) | Proxy SOCKS5 sur Cloud Run protégé par IAP via HTTPS Load Balancer avec Direct VPC Egress. | [→ README](samples/cloudrun-bastion/README.md) |

---

## 🗂️ Project Structure

```text
gcp-samples/
├── .agents/          # AI agent configuration (skills, rules)
│   └── skills/
│       └── community/# Third-party and CLI-downloaded skills
├── samples/          # GCP use-case samples
│   ├── cloudrun-simple/
│   └── cloudrun-bastion/
└── .pre-commit-config.yaml
```

---

## 📜 License

This project is intended for educational and demonstration purposes.
