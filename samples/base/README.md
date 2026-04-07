# Base VPC Infrastructure

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Ce projet Terraform déploie l'infrastructure réseau de base (VPC) destinée à être partagée par les autres samples.

## 🏗️ Architecture

Le réseau est composé d'un VPC `base-vpc` déployé dans la région `europe-west9` contenant les sous-réseaux suivants (IPv4 uniquement) :

- `subnet-public` : Plage /22 (1024 IPs), accès internet externe.
- `subnet-priv-a` : Plage /20 (4096 IPs), isolé par défaut.
- `subnet-priv-b` : Plage /20 (4096 IPs), isolé par défaut.

Conformément à la règle "Security by Design", les sous-réseaux privés n'ont pas de permissions globales de communication entre eux (pas de règle firewall globale `allow-internal`).

## 📁 Structure du projet

Conforme au standard `Terraform Modular Structure` :

```
base/
├── Taskfile.yml
├── .pre-commit-config.yaml
├── infra/
│   ├── main.tf
│   ├── network.tf
│   ├── artifact_registry.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
```

## 📦 Artifact Registry
- **`cloudrun-simple-job`**: Dépôt Docker (DOCKER) avec analyse des vulnérabilités activée pour l'image d'un Job Cloud Run.
- **`cloudrun-simple-service`**: Dépôt Docker (DOCKER) avec analyse des vulnérabilités activée pour l'image d'un Service Cloud Run.

## 🚀 Getting Started

### Prérequis

Assurez-vous que tous les outils (Task, Terraform, pre-commit, Trivy, KICS) sont installés selon les instructions du [README racine](../../README.md).

### Déploiement

1. Initialiser le projet :
   ```bash
   task tf-init
   ```

2. Vérifier les changements avec un plan :
   ```bash
   task tf-plan
   ```

3. Appliquer la configuration :
   ```bash
   task tf-apply
   ```

### Commandes utiles

- `task pre-commit` : Lancer les hooks pre-commit (Gitleaks, fmt, docs, validate).
- `task tf-destroy` : Détruire l'infrastructure.
