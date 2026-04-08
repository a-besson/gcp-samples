# Cloud Run Simple Service

This sample demonstrates a production-grade Cloud Run service configured to listen on **Port 443** with mandatory **IAM Authentication** and automatic **Google SSL/DNS**.

## Architecture Highlights
- **VPC Integration**: Direct VPC Egress to the base VPC via remote state.
- **Port 443**: The container is configured to listen on port 443 (handling HTTP traffic from the GFE).
- **Security by Design**: Access is restricted to IAM-authenticated callers only.
- **E2E Testing**: Automated Terraform tests that deploy, authenticate, and verify the service.

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

# Test via the Global Load Balancer
LOAD_BALANCER_IP=$(cd infra && terraform output -raw load_balancer_ip)
# Note: It may take 5-10 minutes for the Load Balancer to become fully operational.
curl -i -v -H "Authorization: Bearer $(gcloud auth print-identity-token)" "http://$LOAD_BALANCER_IP"
```


---

## 🧪 Automated Testing

We use `terraform test` to ensure the service is correctly deployed and reachable from the outside with valid credentials.

```bash
task test
```

The test logic:
1. Performs a `terraform apply`.
2. Impersonates a test Service Account.
3. Performs an `http` call to the URL.
4. Asserts that the response status is `200 OK`.

---

## 📁 Project Structure
- `app/`: Python/Flask application listening on port 443.
- `infra/`: Terraform modules for GCP resources.
- `infra/tests/`: E2E terraform tests.
- `Taskfile.yml`: Orchestration commands.
