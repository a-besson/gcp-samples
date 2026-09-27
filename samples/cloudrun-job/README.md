# ⚙️ Cloud Run Simple Job

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Batch Python job exécuté sur **Cloud Run (v2)** avec isolation réseau via VPC privé. L'image Docker est stockée dans **Artifact Registry** et le job est déployé avec un service account dédié au moindre privilège.

---

## ✨ Features

- **Cloud Run Job (v2)** — Job batch Python exécuté jusqu'à complétion
- **Direct VPC Egress** — Tout le trafic transite par le VPC privé (`ALL_TRAFFIC`)
- **Artifact Registry** — Dépôt Docker privé managé via le module officiel GCP
- **IAM Least Privilege** — Service account dédié avec `logWriter` + `artifactregistry.reader`
- **Terraform Tests** — Validation unitaire de l'infrastructure avant déploiement

---

## 🏗️ Architecture

```
┌────────────────────────────┐
│     GCP Project            │
│                            │
│  ┌──────────────────────┐  │
│  │   Cloud Run Job       │  │
│  │   (hello-world-job)   │  │
│  │  ┌───────────────┐   │  │
│  │  │  job.py        │   │  │
│  │  └───────────────┘   │  │
│  │   VPC Direct Egress   │  │
│  └──────────┬───────────┘  │
│             │               │
│  ┌──────────▼───────────┐  │
│  │   VPC (base)          │  │
│  │   Subnet privé        │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │  Artifact Registry    │  │
│  │  cloudrun-simple-job  │  │
│  └──────────────────────┘  │
└────────────────────────────┘
```

---

## 🚀 Getting Started

### Prérequis

```bash
task deps-install   # depuis la racine du dépôt
```

### Déploiement

1. **Configurer les variables** dans le fichier `.env` à la racine du projet :
```env
PROJECT_ID="votre-project-id"
REGION="europe-west9"
IMAGE_JOB="europe-west9-docker.pkg.dev/your-project/cloudrun-simple-job/app:latest"
NETWORK="your-vpc-name"
SUBNET="your-subnet-name"
```

2. **Builder et pousser l'image** :
```bash
task build
task push
```

3. **Provisionner l'infrastructure** :
```bash
task tf-plan
task tf-apply
```

4. **Tester l'infra** :
```bash
task tf-test
```

5. **Test E2E** (déclenche une exécution réelle du job et attend qu'elle se termine avec succès) :
```bash
task e2e
```

6. **Déclencher le job manuellement** :
```bash
gcloud run jobs execute hello-world-job --region europe-west9 --project YOUR_PROJECT_ID
```

---

## 📋 Task Commands

| Commande | Description |
|---|---|
| `task build` | Build l'image Docker du job |
| `task push` | Push l'image vers Artifact Registry |
| `task scan-trivy` | Scan de vulnérabilités sur l'image |
| `task scan-kics` | Scan KICS de l'IaC Terraform |
| `task tf-init` | Initialise Terraform |
| `task tf-plan` | Calcule le plan Terraform |
| `task tf-apply` | Applique l'infrastructure |
| `task tf-destroy` | Détruit l'infrastructure |
| `task tf-test` | Lance les tests unitaires Terraform |
| `task e2e` | Test E2E sur l'infra déjà déployée : déclenche une exécution réelle du job, attend `Completed` |
| `task all` | Exécute tous les scans + tests + plan |

---

## 📁 Project Structure

```text
cloudrun-simple-job/
├── app/
│   ├── Dockerfile        # Image Python slim
│   └── job.py            # Logique du job batch
├── infra/
│   ├── cloudrun.tf       # Cloud Run Job v2
│   ├── iam.tf            # Service Account + IAM bindings
│   ├── main.tf           # APIs + Artifact Registry module
│   ├── network.tf        # Data sources VPC/subnet
│   ├── outputs.tf        # Outputs utiles
│   ├── providers.tf      # Provider Google + versions
│   ├── variables.tf      # Variables d'entrée validées
│   ├── .env (at project root)
│   └── tests/
│       └── unit_test.tftest.hcl
├── Taskfile.yml
└── TFDOCS.md
```
