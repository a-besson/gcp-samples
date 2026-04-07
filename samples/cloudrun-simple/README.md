# Cloud Run Simple Example (Python + Terraform)

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Exemple industriel d'un service web et d'un job Cloud Run Python, attachés à un sous-réseau VPC privé.

## Getting Started

Pour tester le service Cloud Run déployé, vous pouvez exécuter les commandes suivantes pour récupérer son URL et l'authentifier :

```bash
SERVICE_NAME="hello-world-app"
REGION="europe-west1"
PROJECT_ID=$(gcloud config get-value project)

# Récupérer l'URL du service
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --format 'value(status.url)' \
  --project $PROJECT_ID)

echo "Service URL: $SERVICE_URL"

# Récupérer le token d'identité et appeler le service avec curl
ID_TOKEN=$(gcloud auth print-identity-token)
curl -i -H "Authorization: Bearer $ID_TOKEN" "$SERVICE_URL"
```

## Features

- **Dockerfile unique** : paramétré par `ARG APP_MODE` (`service` / `job`).
- **Direct VPC Egress** : conteneurs sur subnet privé, sans IP publique.
- **Google-managed encryption** : chiffrement au repos via clés gérées par Google.
- **Least privilege IAM** : Service Account dédié `cloudrun-runner`.
- **Intégration Continue (Taskfile)** : build, Terraform, Trivy, KICS automatisés via `task`.

## Architecture

![Architecture](architecture.drawio)

## Project Structure

```text
cloudrun-simple/
├── app/               # Code applicatif unifié
│   ├── Dockerfile     # ARG APP_MODE=service|job
│   ├── requirements.txt
│   ├── service.py     # Flask hello world
│   └── job.py         # Batch script
├── infra/             # Terraform
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── tests/
├── Taskfile.yml
├── README.md
└── TFDOCS.md
```

## Commandes Taskfile

Le projet utilise un `Taskfile.yml` pour automatiser les tâches (build, scans, terraform).

```bash
# Lancer tous les scans de sécurité
task scan-trivy
task scan-kics

# Lancer Terraform
task tf-init
task tf-plan
task tf-test

# Tout lancer
task all
```


## How to Test

```bash
# Tests unitaires Terraform
cd infra && terraform test

# Qualité du code (depuis la racine du repo)
pre-commit run --all-files
```
