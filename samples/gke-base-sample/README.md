# GKE Autopilot Private Cluster

> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)

Ce sample déploie un cluster **GKE Autopilot privé** sur le sous-réseau privé de la VPC de base, avec un service Nginx interne accessible uniquement depuis le réseau privé.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      GCP Project                             │
│                                                              │
│  ┌──── VPC: gcp-sample-base-vpc ────────────────────────┐   │
│  │                                                       │   │
│  │  ┌── subnet-public (10.0.0.0/22) ──┐                │   │
│  │  │  ❌ No access to nginx           │                │   │
│  │  └──────────────────────────────────┘                │   │
│  │                                                       │   │
│  │  ┌── subnet-priv-a (10.0.4.0/22) ──────────────┐    │   │
│  │  │                                               │    │   │
│  │  │  ┌── GKE Autopilot Cluster ──────────────┐   │    │   │
│  │  │  │                                        │   │    │   │
│  │  │  │  ┌─────────────────────────────────┐  │   │    │   │
│  │  │  │  │  nginx-internal (ILB :80)       │  │   │    │   │
│  │  │  │  │  ✅ Private subnet only          │  │   │    │   │
│  │  │  │  │  ❌ No internet / public access  │  │   │    │   │
│  │  │  │  └─────────────────────────────────┘  │   │    │   │
│  │  │  │                                        │   │    │   │
│  │  │  │  NetworkPolicy: 10.0.0.0/8 only       │   │    │   │
│  │  │  └────────────────────────────────────────┘   │    │   │
│  │  │                                               │    │   │
│  │  │  Control Plane: 172.16.0.0/28 (private)       │    │   │
│  │  └───────────────────────────────────────────────┘    │   │
│  │                                                       │   │
│  │  Cloud NAT → Egress for node updates                  │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  🔐 kubectl access: base VM (IAP SSH) or authorized networks │
└──────────────────────────────────────────────────────────────┘
```

### Points clés

- **GKE Autopilot** : Gestion automatisée des nœuds (Google gère scaling, patches, sécurité).
- **Private Nodes** : Aucun nœud n'a d'IP publique. Sortie internet via Cloud NAT (base).
- **Control Plane restreint** : endpoint public filtré par **Master Authorized Networks** (subnet-priv-a et les réseaux de `master_authorized_networks` uniquement ; la plage IAP TCP, partagée par tous les clients Google Cloud, n'est pas autorisée), endpoint DNS interne uniquement (`dns_allow_external_traffic = false`).
- **Nginx Internal Load Balancer** : Le service nginx écoute sur une IP privée du subnet-priv-a. **Non accessible depuis internet ni depuis le subnet-public.**
- **NetworkPolicy** : Ingress nginx restreint aux plages privées RFC 1918/6598 uniquement.
- **Security Posture** : Scan de vulnérabilités activé au niveau du cluster.
- **Pod Security** : Container non-root, filesystem read-only, seccomp, capabilities DROP ALL.

---

## 📁 Structure du projet

```
gke-base-sample/
├── Taskfile.yml           # Orchestration des commandes
├── README.md              # Documentation
├── TFDOCS.md              # Documentation Terraform auto-générée
├── k8s/
│   └── nginx.yaml         # Manifests K8s (Namespace, Deployment, Service, NetworkPolicy)
├── infra/
│   ├── providers.tf       # Providers Google + Google-Beta
│   ├── main.tf            # Activation des APIs
│   ├── variables.tf       # Variables d'entrée
│   ├── network.tf         # Référence réseau via remote state
│   ├── gke.tf             # Cluster GKE Autopilot (module officiel)
│   ├── outputs.tf         # Outputs + script kubectl
│   └── tests/
│       └── unit.tftest.hcl  # Tests Terraform
```

---

## 🚀 Getting Started

### Prérequis

1. Infrastructure `base` déployée (`task apply` dans `samples/base/`).
2. Variables configurées dans le fichier racine `.env`.
3. `kubectl` installé sur le poste local.

### Déploiement

```bash
# 1. Initialiser Terraform
task init

# 2. Vérifier le plan
task plan

# 3. Déployer le cluster GKE (~10-15 min)
task apply

# 4. Configurer kubectl
task get-credentials

# 5. Déployer nginx en interne
task deploy-nginx
```

### Vérification

```bash
# Vérifier les pods
kubectl get pods -n nginx-internal

# Vérifier le service (doit avoir une IP privée 10.x.x.x)
kubectl get svc -n nginx-internal

# Tester nginx depuis l'intérieur du cluster
task test-nginx

# Accéder à nginx en local via port-forward sécurisé
task port-forward
# Puis ouvrir http://localhost:8080
```

### Accès kubectl sécurisé

Le control plane GKE est protégé par **Master Authorized Networks**. Deux méthodes d'accès :

**Méthode 1 : Via IAP Tunnel (recommandé)**
```bash
# Depuis une VM du subnet privé via IAP
gcloud compute ssh vm-test-a-sample --zone europe-west9-a --tunnel-through-iap

# Puis sur la VM : --internal-ip cible l'endpoint privé du control plane
# (subnet-priv-a y est autorisé ; l'endpoint public verrait l'IP du Cloud NAT)
gcloud container clusters get-credentials gke-autopilot-sample --region europe-west9 --internal-ip
kubectl get nodes
```

**Méthode 2 : Depuis un réseau autorisé**
```bash
# Directement si votre IP est dans les master_authorized_networks
gcloud container clusters get-credentials gke-autopilot-sample --region europe-west9
kubectl get nodes
```

---

## 🧪 Tests

```bash
# Tests Terraform (plan-level validation)
task test
```

---

## 🛠️ Commandes utiles

| Commande | Description |
|---|---|
| `task plan` | Vérifier les changements Terraform |
| `task apply` | Déployer le cluster GKE |
| `task get-credentials` | Configurer kubectl |
| `task deploy-nginx` | Déployer nginx interne |
| `task test-nginx` | Tester la connectivité nginx |
| `task port-forward` | Tunnel local sécurisé vers nginx |
| `task undeploy-nginx` | Supprimer nginx du cluster |
| `task destroy` | Détruire le cluster GKE |

---

## 🔒 Sécurité

| Contrôle | Implémentation |
|---|---|
| Nœuds privés | `enable_private_nodes = true` |
| Control plane restreint | Master Authorized Networks (subnet-priv-a + `master_authorized_networks`), endpoint DNS interne |
| Pas d'IP externe sur services | `service_external_ips = false` |
| NetworkPolicy | Ingress nginx limité aux plages privées |
| Pod Security | Non-root, read-only FS, seccomp, no capabilities |
| Container image | `nginx-unprivileged` (non-root, Alpine) |
| Scan de vulnérabilités | Security posture BASIC activé |
| Accès kubectl | IAP tunnel ou réseau autorisé uniquement |
