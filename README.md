# GCP Samples

<p align="center">
  <img src="https://img.icons8.com/?size=100&id=fpGM2cINbbu4&format=png&color=000000" alt="Google Cloud"/>
</p>

<p align="center">
  <strong>Google Cloud Platform Samples</strong><br/>
  Terraform · Cloud Run · GKE · Security by Design · CI/CD
</p>

---

## 🚀 Getting Started

### Prerequisites

Install the required tools before running any sample:

**macOS (Homebrew)**

```bash
brew install terraform go-task/tap/go-task trivy pre-commit terraform-docs gitleaks libpq
# tflint is a Homebrew cask (terraform-linters/tap), not a formula
brew install --cask google-cloud-sdk terraform-linters/tap/tflint
# On macOS, link libpq to get psql
echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

**Linux (apt + curl)**

```bash
sudo apt-get update && sudo apt-get install -y curl unzip python3-pip

# Terraform
curl -fsSL https://releases.hashicorp.com/terraform/1.16.5/terraform_1.16.5_linux_amd64.zip \
  -o terraform.zip && unzip terraform.zip && sudo mv terraform /usr/local/bin/

# Task
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

# tflint (the old install_linux.sh one-liner was retired; verified binary download instead)
curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip \
  && curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/checksums.txt \
  && sha256sum --ignore-missing -c checksums.txt \
  && unzip tflint_linux_amd64.zip && sudo mv tflint /usr/local/bin/

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

### Configure and run

```bash
cp .env.example .env      # then set PROJECT_ID, REGION and the TF_VAR_* values (never commit .env)
task --list               # root commands
```

| Root command | Role |
|---|---|
| `task init` | Installs the system dependencies (Homebrew) |
| `task apply-all` / `task destroy-all` | Deploys / destroys `base` first, then the samples in parallel (**billable**: check the FinOps notes of each sample first) |
| `task test-all` | Terraform tests of every sample |
| `task review` | `pre-commit run --all-files` |

`gce-g2-gpu-instance` (GPU) is deliberately outside `apply-all`/`destroy-all`/`test-all`: deploy it on its own from its folder. Each sample also has its own `Taskfile.yml` (`cd samples/<name> && task --list`). Deploy [`base`](samples/base/) first: the other samples read its VPC.

---

## 📁 Samples

| Name | Description | README |
|---|---|---|
| [alb-internal](samples/alb-internal/) | API Spring Boot 4/Java 25 sur Cloud Run derrière un ALB régional interne, Cloud Armor, IAP et Cloud SQL PostgreSQL CMEK via PSC. | [→ README](samples/alb-internal/README.md) |
| [base](samples/base/) | Déploiement du réseau VPC de base avec sous-réseaux isolés. | [→ README](samples/base/README.md) |
| [cloudrun-service](samples/cloudrun-service/) | Service web Cloud Run Python déployé sur VPC privé avec Terraform. | [→ README](samples/cloudrun-service/README.md) |
| [cloudrun-job](samples/cloudrun-job/) | Job Cloud Run Python pour exécution de batchs asynchrones. | [→ README](samples/cloudrun-job/README.md) |
| [cloudrun-bastion](samples/cloudrun-bastion/) | Bastion HTTP Proxy (Tinyproxy) sur Cloud Run protégé par IAP via HTTPS Load Balancer avec Direct VPC Egress. | [→ README](samples/cloudrun-bastion/README.md) |
| [gke-base-sample](samples/gke-base-sample/) | Cluster GKE Autopilot privé avec Nginx interne sur ILB et NetworkPolicy. | [→ README](samples/gke-base-sample/README.md) |
| [gce-g2-gpu-instance](samples/gce-g2-gpu-instance/) | Instance GCE G2 avec GPU NVIDIA L4 pour exécuter des LLMs (Gemma/Ollama) via tunnel IAP privé. | [→ README](samples/gce-g2-gpu-instance/README.md) |

---

## 🗂️ Project Structure

```text
gcp-samples/
├── AGENTS.md             # Single agent instruction file (Claude Code, Gemini CLI, Antigravity)
│                         # Global rules & skills live at the workstation level, not in this repo.
├── Taskfile.yml          # Root orchestration (apply-all, destroy-all, test-all, review)
├── CHANGELOG.md          # One "Daily Log" entry per day
├── .env.example          # Template of the shared .env read by every Taskfile
├── samples/              # GCP use-case samples
│   ├── alb-internal/
│   ├── base/
│   ├── cloudrun-service/
│   ├── cloudrun-job/
│   ├── cloudrun-bastion/
│   ├── gce-g2-gpu-instance/
│   └── gke-base-sample/
├── .github/workflows/    # CI (no cloud credentials): see "CI" below
├── .pre-commit-config.yaml   # Hygiene, gitleaks, Terraform fmt/validate/docs/tflint, conventional commits
├── .tflint.hcl           # Shared TFLint config (pre-commit + CI)
├── kics.config           # Shared KICS config (task/CI)
├── trivy.yaml            # Shared Trivy config (CI)
└── .trivyignore.yaml     # Scoped, justified Trivy exceptions
```

---

## 🔁 CI

GitHub Actions workflows live in `.github/workflows/` and run **on pull requests only** (no `push` trigger). CI is offline: it never runs `plan`, `apply` or e2e tests and holds no cloud credentials (the only secrets are `DHI_USERNAME`/`DHI_TOKEN`, used to pull Docker Hardened Images for the container scan).

| Workflow | Role |
|---|---|
| `build-<sample>.yml` (x7: `base`, `alb-internal`, `cloudrun-bastion`, `cloudrun-job`, `cloudrun-service`, `gce-g2-gpu-instance`, `gke-base-sample`) | One per sample, filtered on `samples/<sample>/**`: `terraform fmt` → `init -backend=false` + `validate` (every root) → `tflint` → `terraform test` (offline mock providers, `alb-internal` only) and, for `alb-internal`, `mvn compile/test/package/verify` |
| `_build-sample.yml` | Reusable workflow called by every `build-*` |
| `check-quality.yml` | Repo-wide `pre-commit run --all-files` (gitleaks, fmt, validate, tflint, generated `TFDOCS.md`) |
| `check-cyber.yml` | Repo-wide KICS, Trivy `config` + `fs` (vuln, secret) and a Trivy image scan per Dockerfile/Containerfile |

Adding a sample means adding a `build-<sample>.yml` caller (copy an existing one). Actions are pinned by commit SHA and every workflow uses `permissions: contents: read`. Run the same checks locally with `pre-commit run --all-files`, `actionlint` and `trivy config --config trivy.yaml .`. Commit messages must follow Conventional Commits (`conventional-pre-commit`, run `pre-commit install` once: it installs the `pre-commit` and `commit-msg` hooks).

---

## 📜 License

This project is intended for educational and demonstration purposes.
