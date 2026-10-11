# 🏗️ Base VPC Infrastructure

> [📚 Terraform auto-generated documentation (TFDOCS.md)](./TFDOCS.md)

Foundational Terraform module that provisions the shared VPC network consumed by all other samples. Deploy this **before** any other sample.

---

## 🏗️ Architecture

A VPC `gcp-sample-base-vpc` is deployed in `europe-west9` with three subnets (IPv4 only):

| Subnet | CIDR | Type | Private Google Access |
|---|---|---|---|
| `subnet-public` | `/22` (1024 IPs) | Public | ❌ |
| `subnet-priv-a` | `/22` (1024 IPs) + secondary `100.64.0.0/22` | Private | ✅ |
| `subnet-priv-b` | `/22` (1024 IPs) + secondary `100.64.4.0/22` | Private | ✅ |

### Additional Components

| Component | Purpose |
|---|---|
| **Cloud NAT + Router** | Egress internet access for private subnet resources (updates, package installs) |
| **Firewall Rules** | IAP SSH (`35.235.240.0/20`) + least-privilege internal ports only |
| **Test VMs** | Two `e2-micro` instances (`vm-test-a`, `vm-test-b`) in zones `europe-west9-a/b` for connectivity validation |
| **IAP Gateway** | Secure SSH access via Identity-Aware Proxy (no public IP required) |
| **Artifact Registry** | Shared Docker registries for Cloud Run sample images |

### 🔒 Security Design

- **No public IPs** on VMs — SSH exclusively via IAP tunnel (`35.235.240.0/20`)
- **Least-privilege firewall**: internal rule restricts to explicit ports (22, 443, 5432, 8080, 8443, 9090) — no wildcard `0-65535`
- **Private Google Access** enabled on private subnets for API calls without internet egress

---

## 📁 Project Structure

```text
base/
├── Taskfile.yml
├── .pre-commit-config.yaml
├── infra/
│   ├── tests/
│   │   └── unit.tftest.hcl
│   ├── main.tf
│   ├── network.tf           # VPC, subnets, NAT, firewall rules
│   ├── compute.tf           # Test VMs (e2-micro)
│   ├── artifact_registry.tf # Shared Docker registries
│   ├── sa-iac.tf            # IaC service account
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
└── README.md
```

---

## 📦 Artifact Registry

| Repository | Format | Scanning |
|---|---|---|
| `cloudrun-simple-job` | Docker | ✅ Vulnerability scanning enabled |
| `cloudrun-simple-service` | Docker | ✅ Vulnerability scanning enabled |

---

## 🚀 Deployment

### Prerequisites

Ensure all tools are installed per the [root README](../../README.md): Terraform, Task, pre-commit, Trivy, KICS.

### Steps

```bash
# 1. Initialize Terraform (download providers and modules)
task init

# 2. Review planned changes
task plan

# 3. Run unit tests
task test

# 4. Apply the configuration
task apply
```

---

## 🖥️ VM Access (IAP)

VMs have no public IP. SSH is provided exclusively via **Identity-Aware Proxy**:

```bash
# Connect to vm-test-a (private subnet A)
gcloud compute ssh vm-test-a --zone europe-west9-a --tunnel-through-iap

# Connect to vm-test-b (private subnet B)
gcloud compute ssh vm-test-b --zone europe-west9-b --tunnel-through-iap

# Connect to vm-test-public (public subnet)
gcloud compute ssh vm-test-public --zone europe-west9-c --tunnel-through-iap
```

> [!IMPORTANT]
> Your IAM identity must have the `roles/iap.tunnelResourceAccessor` role to establish the IAP tunnel.

---

## 🛠️ Task Commands

| Command | Description |
|---|---|
| `task init` | Initialize Terraform providers and backend |
| `task plan` | Preview infrastructure changes |
| `task apply` | Apply the configuration |
| `task test` | Run `terraform test` unit tests |
| `task review` | Run pre-commit hooks (Gitleaks, fmt, docs, validate) |
| `task destroy` | Destroy all infrastructure |
