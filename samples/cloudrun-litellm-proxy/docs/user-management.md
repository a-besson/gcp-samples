# 👥 User Management Guide

This guide covers the lifecycle management of **LiteLLM Virtual Keys** and **users** in the `cloudrun-litellm-proxy` sample.

---

## Overview

Users and their API keys are managed **as code** via a declarative `users.yaml` file at the root of the sample. Terraform reads this file and synchronizes virtual keys on every `terraform apply`.

```text
users.yaml  →  Terraform (litellm provider)  →  LiteLLM Proxy API  →  Cloud SQL
```

> [!TIP]
> All key operations are idempotent. Running `task apply` multiple times is safe — Terraform only creates, updates, or deletes keys that have changed.

---

## 1. Declaring Users (`users.yaml`)

Edit the [`users.yaml`](../users.yaml) file at the sample root:

```yaml
users:
  - name: alice
    budget: 10        # Max spend in USD per budget cycle
    duration: 7d      # Budget renewal cycle (e.g. "7d", "30d", "1h")
    models:           # Restrict to specific model aliases
      - claude-sonnet-4-6
      - gemini-2.5-flash
  - name: bob
    budget: 20
    duration: 30d
    # No `models` field → access to ALL available models
```

### Field Reference

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | ✅ | User alias — used as key alias and metadata |
| `budget` | number | ✅ | Maximum spend in USD for each budget cycle |
| `duration` | string | ✅ | Budget renewal period (`"7d"`, `"30d"`, `"1h"`) |
| `models` | list(string) | ❌ | Allowed model aliases. Omit or leave empty for unrestricted access |

---

## 2. Applying Changes

After editing `users.yaml`, synchronize keys with the proxy:

```bash
# Plan changes (review before applying)
task plan

# Apply changes (creates/updates/deletes keys)
task apply
```

> [!IMPORTANT]
> **First deployment:** On the very first `terraform apply`, Cloud Run is provisioned but keys are not created yet (the proxy isn't running). Run `task apply` a **second time** to provision the keys. All subsequent applies work in a single pass.

### Retrieving Generated Keys

After apply, retrieve the generated virtual keys:

```bash
cd infra

# Show all user keys (JSON format)
terraform output -json user_keys

# Extract a specific user's key
terraform output -json user_keys | jq -r '.alice.key'
```

> [!WARNING]
> Virtual keys are **sensitive** and stored in Terraform state. Treat the state file with the same security as the keys themselves.

---

## 3. User Lifecycle Operations

### Adding a User

1. Add the user entry to `users.yaml`:
   ```yaml
   users:
     # ... existing users ...
     - name: charlie
       budget: 15
       duration: 14d
       models:
         - gemini-2.5-flash
   ```
2. Run `task apply`.
3. Retrieve the key: `terraform output -json user_keys | jq -r '.charlie.key'`

### Modifying a User

Edit the user's fields in `users.yaml` and run `task apply`. Changes to `budget`, `duration`, or `models` are applied in-place without regenerating the key value.

### Removing a User

Remove the user entry from `users.yaml` and run `task apply`. Terraform deletes the key from LiteLLM — the key becomes immediately invalid.

### Rotating a Key

To force-regenerate a user's key value (e.g., if compromised):

```bash
cd infra

# Taint the specific key resource
terraform taint 'litellm_key.user["alice"]'

# Apply to regenerate
terraform apply -var="project_id=${PROJECT_ID}" -var="region=${REGION}" -var="image_service=${IMAGE_NAME}"
```

The old key is revoked and a new `sk-...` key is issued.

---

## 4. Manual Key Management (Admin API)

For ad-hoc operations outside of Terraform, you can use the LiteLLM Admin API directly with the master key:

```bash
# Load connection details
SERVICE_URL=$(cd infra && terraform output -raw service_url)
MASTER_KEY=$(gcloud secrets versions access latest --secret=litellm-master-key-sample)

# Create a key manually
curl -sS -X POST "${SERVICE_URL}/key/generate" \
  -H "x-api-key: Bearer ${MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "key_alias": "manual-user",
    "max_budget": 5,
    "budget_duration": "7d",
    "models": ["gemini-2.5-flash"],
    "metadata": {"user": "manual-user"}
  }' | jq .

# List all keys
for hash in $(curl -sS "${SERVICE_URL}/key/list" -H "x-api-key: Bearer ${MASTER_KEY}" | jq -r '.keys[]'); do
  curl -sS "${SERVICE_URL}/key/info?key=${hash}" -H "x-api-key: Bearer ${MASTER_KEY}" | \
    jq -c '{alias: .info.key_alias, user: .info.metadata.user, key_name: .info.key_name, spend: .info.spend, max_budget: .info.max_budget}'
done

# Delete a key
curl -sS -X POST "${SERVICE_URL}/key/delete" \
  -H "x-api-key: Bearer ${MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"keys": ["sk-..."]}' | jq .
```

> [!WARNING]
> Keys created manually are **not tracked by Terraform**. They will not appear in `terraform output` and will not be managed by `users.yaml`.

---

## 5. Auditing Budget & Spend

### Quick Spend Report

```bash
task query-spend
```

### Per-User Spend Query (BigQuery)

```bash
bq query --project_id=${PROJECT_ID} --use_legacy_sql=false '
SELECT
  DATE(created_at)        AS day,
  key_alias               AS user,
  model,
  SUM(input_tokens)       AS read_tokens,
  SUM(output_tokens)      AS write_tokens,
  ROUND(SUM(spend), 6)    AS cost_usd,
  ROUND(AVG(response_ms)) AS avg_latency_ms
FROM `'${PROJECT_ID}'.litellm_observability.litellm_logs`
WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY 1, 2, 3
ORDER BY day DESC, cost_usd DESC
LIMIT 50'
```

### Key Info (Current Budget Status)

Check a specific key's remaining budget:

```bash
SERVICE_URL=$(cd infra && terraform output -raw service_url)
MASTER_KEY=$(gcloud secrets versions access latest --secret=litellm-master-key-sample)
USER_KEY_HASH="sk-..."  # The key to inspect

curl -sS "${SERVICE_URL}/key/info?key=${USER_KEY_HASH}" \
  -H "x-api-key: Bearer ${MASTER_KEY}" | \
  jq '{alias: .info.key_alias, spend: .info.spend, max_budget: .info.max_budget, budget_duration: .info.budget_duration}'
```
