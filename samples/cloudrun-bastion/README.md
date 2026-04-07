# Cloud Run Bastion (SOCKS5 Proxy + IAP)

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Service Cloud Run faisant office de **proxy SOCKS5 bastion**, protégé par **Identity-Aware Proxy (IAP)**
via un HTTPS Load Balancer, avec **Direct VPC Egress** pour atteindre les ressources privées du VPC.

## Architecture

```
Developer ──HTTPS──► HTTPS Load Balancer ──► IAP ──► Cloud Run Bastion
                                                           │ (Direct VPC Egress)
                                                           ▼
                                                       Cloud SQL
                                                 (PostgreSQL Private IP)
```

![Architecture](architecture.drawio)

## Getting Started

### Pré-requis

```bash
# Copier et renseigner les variables Terraform
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

### Vérifier la sécurité

Avant de déployer, vous pouvez lancer les scans de vulnérabilités et d'IaC en local :

```bash
# Scan de l'image Docker (Trivy)
task scan-trivy

# Scan de l'infrastructure Terraform (KICS)
task scan-kics
```

### Déployer

```bash
task tf-init
task tf-plan
# Vérifier le plan, puis :
terraform -chdir=infra apply
```

### Créer le DNS

Après le premier `apply`, récupérer l'IP statique :

```bash
terraform -chdir=infra output load_balancer_ip
```

Créer un record DNS `A` pointant votre `domain` vers cette IP.
Attendre que le certificat SSL Google-managed se provisionne (~15 min).

### Utiliser le proxy SOCKS5

```bash
# Ouvrir un tunnel IAP authentifié vers Cloud Run (terminal 1)
gcloud run services proxy cloudrun-bastion \
  --project=<PROJECT_ID> \
  --region=europe-west1 \
  --port=1080

# Utiliser le proxy dans un autre terminal
export PGPASSWORD=$(terraform -chdir=infra output -raw db_password)
psql -h localhost -p 1080 -U testuser testdb

# Selon votre installation locale, vous pouvez utiliser tsocks ou proxychains
# ou curl si c'est une requête HTTP pure.
curl --socks5-hostname localhost:1080 http://<DB_PRIVATE_IP>:5432
```

## Features

- **SOCKS5 Proxy** : container Alpine + Dante, port 8080 (compatible Cloud Run).
- **IAP enforcement** : seuls les utilisateurs avec `roles/iap.httpsResourceAccessor` peuvent accéder.
- **Ingress restreint** : `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` — aucun accès internet direct.
- **Direct VPC Egress** : le container voit les ressources privées du VPC sans NAT.
- **Google-managed SSL** : certificat HTTPS provisionné et renouvelé automatiquement.
- **Cloud SQL Testbed** : une base PostgreSQL `db-f1-micro` provisionnée en IP privée via `Private Services Access` pour valider le proxy.
- **Least privilege IAM** : Service Account dédié `cloudrun-bastion-sa`.
- **CI (Taskfile)** : build, Trivy, KICS, Terraform automatisés.

## Project Structure

```text
cloudrun-bastion/
├── app/
│   ├── Dockerfile          # Alpine + dante-server, port 8080
│   └── sockd.conf          # Config Dante (no auth, IAP handles it)
├── infra/
│   ├── main.tf             # APIs + Artifact Registry
│   ├── providers.tf        # Provider Google + backend
│   ├── variables.tf        # Variables with validation
│   ├── outputs.tf          # IP, URL, proxy commands
│   ├── cloudrun.tf         # Cloud Run service (INTERNAL_LB ingress)
│   ├── network.tf          # Data VPC/subnet + Serverless NEG + Private Services Access
│   ├── sql.tf              # Cloud SQL (PostgreSQL), private IP, users
│   ├── loadbalancer.tf     # HTTPS LB + URL Map + Forwarding Rule
│   ├── ssl.tf              # Google-managed SSL certificate
│   ├── iap.tf              # IAP brand, client, IAM binding
│   ├── iam.tf              # Service Account + invoker binding
│   ├── TFDOCS.md           # Généré par terraform-docs
│   └── tests/
│       └── unit_test.tftest.hcl
├── Taskfile.yml
├── TFDOCS.md
└── README.md
```

## Commandes Taskfile

```bash
task build        # Build l'image Dante
task push         # Push vers Artifact Registry
task scan-trivy   # Scan vulnérabilités image
task scan-kics    # Scan IaC (Terraform + Dockerfile)
task tf-init      # Init Terraform
task tf-plan      # Plan Terraform
task tf-test      # Tests unitaires Terraform
task all          # Lance tout
```

## How to Test

```bash
# Tests unitaires Terraform (plan-only, sans credentials)
cd infra && terraform test

# Qualité du code (depuis la racine du repo)
pre-commit run --all-files
```
