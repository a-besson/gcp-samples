# Base VPC Infrastructure

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Ce projet Terraform déploie l'infrastructure réseau de base (VPC) destinée à être partagée par les autres samples.

## 🏗️ Architecture

Le réseau est composé d'un VPC `gcp-sample-base-vpc` déployé dans la région `europe-west9` contenant les sous-réseaux suivants (IPv4 uniquement) :

- **`subnet-public`** : Plage `/22` (1024 IPs), sans accès privé Google par défaut.
- **`subnet-priv-a`** : Plage `/22` (1024 IPs), avec **Private Google Access** et une plage secondaire (`100.64.0.0/22`).
- **`subnet-priv-b`** : Plage `/22` (1024 IPs), avec **Private Google Access** et une plage secondaire (`100.64.4.0/22`).

### Composants additionnels
- **Cloud NAT & Router** : Permet aux ressources des sous-réseaux privés d'accéder à Internet (Egress) pour les mises à jour et outils.
- **Test VMs** : Deux instances `e2-micro` (`vm-test-a` et `vm-test-b`) déployées dans les zones `europe-west9-a/b` pour valider la connectivité.
- **IAP Gateway** : Configuration permettant l'accès SSH sécurisé via IAM sans IP publique.

## 📁 Structure du projet

Conforme au standard `Terraform Modular Structure` :

```
base/
├── Taskfile.yml
├── .pre-commit-config.yaml
├── infra/
│   ├── tests/
│   │   └── unit.tftest.hcl
│   ├── main.tf
│   ├── network.tf
│   ├── artifact_registry.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
│   └── .env (at project root)
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
   task init
   ```

2. Vérifier les changements avec un plan :
   ```bash
   task plan
   ```

3. Exécuter les tests unitaires :
   ```bash
   task test
   ```

4. Appliquer la configuration :
   ```bash
   task apply
   ```

### 🖥️ Accès aux VMs (Troubleshooting)

Comme les VMs n'ont pas d'IP publique, la connexion SSH se fait via **Identity-Aware Proxy (IAP)**.

1. Connectez-vous via le tunnel IAP :
   ```bash
   # Pour vm-test-a
   gcloud compute ssh vm-test-a --zone europe-west9-a --tunnel-through-iap

   # Pour vm-test-b
   gcloud compute ssh vm-test-b --zone europe-west9-b --tunnel-through-iap

   # Pour vm-test-public (Subnet Public)
   gcloud compute ssh vm-test-public --zone europe-west9-c --tunnel-through-iap
   ```

**Note** : Votre identité IAM doit avoir le rôle `roles/iap.tunnelResourceAccessor` pour établir le tunnel.

## 🛠️ Commandes utiles

- `task review` : Lancer les hooks pre-commit (Gitleaks, fmt, docs, validate).
- `task test` : Exécuter le framework `terraform test` sur le module `base/infra`.
- `task destroy` : Détruire l'infrastructure.
