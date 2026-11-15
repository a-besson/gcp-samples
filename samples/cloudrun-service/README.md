# Cloud Run Simple Service

This sample demonstrates a production-grade Cloud Run service configured to listen on **Port 443** with mandatory **IAM Authentication** and automatic **Google SSL/DNS**.

## Architecture Highlights
- **VPC Integration**: Direct VPC Egress to the base VPC via remote state.
- **Port 443**: The container is configured to listen on port 443 (handling HTTP traffic from the GFE).
- **Security by Design**: Access is restricted to IAM-authenticated callers only.
- **HTTPS-only Load Balancer**: the global LB serves only HTTPS (no port 80), with a Google-managed certificate on a Cloud Endpoints `.cloud.goog` domain, so identity tokens never travel in clear text.
- **Testing**: offline Terraform tests (mock providers) and a `task e2e` smoke test that authenticates against the deployed service.

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have the `base` infrastructure applied and the project IDs configured in the root `.env`.

### 2. Provisioning
Use the provided `Taskfile` to automate the lifecycle:

```bash
# 1. Setup GCS state bucket and Artifact Registry
task setup

# 2. Build and Push the Docker Image
task build

# 3. Deploy the Service
task apply
```

### 3. Manual Testing (The "Moment of Truth")

Since the service requires IAM authentication, you must provide a valid Identity Token.

**Get the Service URL:**
```bash
EXPOSED_SERVICE_URL=$(cd infra && terraform output -raw exposed_service_url)
curl -i -v -H "Authorization: Bearer $(gcloud auth print-identity-token)" $EXPOSED_SERVICE_URL

INTERNAL_SERVICE_URL=$(cd infra && terraform output -raw internal_service_url)
curl -i -v -H "Authorization: Bearer $(gcloud auth print-identity-token)" $INTERNAL_SERVICE_URL

# Test via the Global Load Balancer (HTTPS, Cloud Endpoints domain)
LOAD_BALANCER_URL=$(cd infra && terraform output -raw load_balancer_url)
# Note: the Google-managed certificate can take up to 60 minutes to become active after a first apply.
curl -i -v -H "Authorization: Bearer $(gcloud auth print-identity-token)" "$LOAD_BALANCER_URL"
```


---

## 🧪 Automated Testing

`task test` runs `terraform test` **offline** (`mock_provider`, no GCP credentials, nothing is created): ingress settings, IAM-only invocation and naming.

```bash
task test
```

### 🔍 `task e2e` — Smoke Test on Already-Deployed Infrastructure

Unlike `task test` (offline, mock providers), `task e2e` assumes `task apply` has already run and exercises the real, already-deployed `exposed-service`:

```bash
task e2e
```

1. Unauthenticated request → expects `403`.
2. Request with an identity token impersonating `test_sa`, direct to Cloud Run → expects `200`.
3. Same token, via the HTTPS Load Balancer URL → expects `200` (the managed certificate can take up to 60 min after a first `apply`).

Runs under the operator's own identity, not the Taskfile's ambient `sa-iac` impersonation: it's the operator who is granted `roles/iam.serviceAccountTokenCreator` on `test_sa` (`infra/iam.tf`), needed to mint that identity token.

---

## 📁 Project Structure
- `app/`: Python/Flask application listening on port 443.
- `infra/`: Terraform modules for GCP resources.
- `infra/tests/`: offline Terraform tests (mock providers).
- `Taskfile.yml`: Orchestration commands.
