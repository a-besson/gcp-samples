# ⚙️ Cloud Run Simple Job

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Batch Python job exécuté sur **Cloud Run (v2)** avec isolation réseau via VPC privé. L'image Docker est stockée dans **Artifact Registry** et le job est déployé avec un service account dédié au moindre privilège.

---

## ✨ Features

- **Cloud Run Job (v2)** — Job batch Python exécuté jusqu'à complétion
- **Direct VPC Egress** — Tout le trafic transite par le VPC privé (`ALL_TRAFFIC`)
- **Artifact Registry** — Dépôt Docker privé `cloudrun-simple-job<name_suffix>`, créé par le sample [`base`](../base/README.md) (module officiel GCP)
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
│  │ (hello-world-job-*)   │  │
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
│  │ cloudrun-simple-job-* │  │
│  └──────────────────────┘  │
└────────────────────────────┘
```

---

## 🚀 Getting Started

### Prérequis

```bash
task deps-install   # depuis la racine du dépôt
```

Le réseau est lu depuis le state du sample [`base`](../base/README.md) : appliquez-le d'abord.

### Déploiement

1. **Configurer les variables** : copier `.env.example` en `.env` à la racine du dépôt et renseigner `PROJECT_ID` et `REGION`. L'image (`image_job`) est dérivée du `Taskfile.yml` (`<REGION>-docker.pkg.dev/<PROJECT_ID>/cloudrun-simple-job-sample/job:latest`) : aucune variable supplémentaire.

2. **Provisionner l'infrastructure** (`apply` construit et pousse d'abord l'image) :
```bash
task plan
task apply
```

3. **Tester l'infra** (tests Terraform) :
```bash
task test
```

4. **Test E2E** (déclenche une exécution réelle du job et attend qu'elle se termine avec succès) :
```bash
task e2e
```

5. **Déclencher le job manuellement** :
```bash
gcloud run jobs execute "$(cd infra && terraform output -raw job_name)" --region <REGION> --project <PROJECT_ID>
```

---

## 📋 Task Commands

Toutes les commandes se lancent depuis `samples/cloudrun-job/` (`task --list` pour la liste à jour).

| Commande | Description |
|---|---|
| `task setup` | Crée le bucket de state GCS et le dépôt Artifact Registry (idempotent) |
| `task build` | Build l'image Docker (Podman) et la pousse vers Artifact Registry |
| `task init` | Initialise Terraform avec le backend GCS |
| `task plan` | Calcule le plan Terraform |
| `task apply` | Applique l'infrastructure (construit et pousse l'image avant) |
| `task destroy` | Détruit l'infrastructure |
| `task test` | Lance les tests Terraform |
| `task e2e` | Test E2E sur l'infra déjà déployée : déclenche une exécution réelle du job, attend `Completed` |
| `task cyber-scan` | Scans de sécurité : KICS sur `infra/`, Trivy sur l'image construite |
| `task review` | Lance `pre-commit` sur tout le dépôt |

---

## 📁 Project Structure

```text
cloudrun-job/
├── app/
│   ├── Dockerfile        # Image Python slim (pip retiré, cf. Trivy)
│   └── job.py            # Logique du job batch
├── infra/
│   ├── cloudrun.tf       # Cloud Run Job v2
│   ├── iam.tf            # Service Account + IAM bindings
│   ├── main.tf           # Activation des APIs
│   ├── network.tf        # Data sources VPC/subnet
│   ├── outputs.tf        # Outputs utiles
│   ├── providers.tf      # Provider Google + versions
│   ├── variables.tf      # Variables d'entrée validées
│   └── tests/
│       └── unit_test.tftest.hcl
├── Taskfile.yml
└── TFDOCS.md
```
