# ✨ Configure Gemini CLI & Antigravity CLI with LiteLLM Proxy

This guide explains how to connect **Gemini CLI** (`gemini`) and **Antigravity CLI** (`antigravity` / `agy`) to your LiteLLM proxy on Cloud Run, routing all Gemini and Claude model calls through your private Vertex AI backend.

## Prerequisites

- LiteLLM proxy deployed and running (`task apply` completed)
- A valid LiteLLM virtual key issued for your user (`task provision-key`)
- `gemini-cli` installed: `npm install -g @google/gemini-cli` (or `pip install google-gemini-cli`)
- `antigravity` / `agy` CLI installed per the Antigravity SDK documentation

---

## 1. Retrieve Your Connection Details

```bash
# Navigate to the infra directory
cd samples/cloudrun-litellm-proxy/infra

# Get the Cloud Run service URL
SERVICE_URL=$(terraform output -raw service_url)
echo "Service URL: ${SERVICE_URL}"

# Get admin master key (admin only)
MASTER_KEY=$(gcloud secrets versions access latest --secret=litellm-master-key-sample)

# Create a personal virtual key for gemini-cli / antigravity-cli
USER_KEY=$(curl -sS -X POST "${SERVICE_URL}/key/generate" \
  -H "x-api-key: Bearer ${MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "key_alias": "gemini-cli-'"${USER}"'",
    "max_budget": 20,
    "budget_duration": "7d",
    "models": ["gemini-2.5-flash", "gemini-2.5-pro", "gemma-3-27b"],
    "metadata": {"user": "'"${USER}"'", "client": "gemini-cli"}
  }' | jq -r '.key')
echo "User Key: ${USER_KEY}"
```

---

## 2. Configure Gemini CLI

The Gemini CLI supports the OpenAI-compatible API format via the `GEMINI_API_BASE` and `GEMINI_API_KEY` environment variables (or the `--base-url` / `--api-key` flags).

### Option A — Environment Variables (recommended)

```bash
# Export required variables in your shell session
export GEMINI_API_BASE="$(cd samples/cloudrun-litellm-proxy/infra && terraform output -raw service_url)/v1"
export GEMINI_API_KEY="sk-your-virtual-key-here"  # Replace with your issued key

# Verify connectivity
curl -sS -o /dev/null -w "HTTP %{http_code}\n" \
  -H "x-api-key: Bearer ${GEMINI_API_KEY}" \
  "${GEMINI_API_BASE%/v1}/health/liveliness"
# Expected: HTTP 200

# Run Gemini CLI — it will use the proxy automatically
gemini
```

> [!TIP]
> Add to your `~/.zshrc` for persistent configuration:
> ```bash
> cat >> ~/.zshrc << 'EOF'
>
> # LiteLLM Proxy — Gemini CLI configuration
> export GEMINI_API_BASE="https://your-cloudrun-url.run.app/v1"  # Replace with your URL
> export GEMINI_API_KEY="sk-your-virtual-key-here"               # Replace with your key
> EOF
> ```

### Option B — CLI Flags (one-shot)

```bash
gemini \
  --base-url "$(cd samples/cloudrun-litellm-proxy/infra && terraform output -raw service_url)/v1" \
  --api-key "sk-your-virtual-key-here" \
  --model "gemini-2.5-flash" \
  -p "Hello from LiteLLM proxy!"
```

---

## 3. Configure Antigravity CLI (agy)

The Antigravity CLI (`agy`) uses the OpenAI-compatible API endpoint. Configure it by pointing to the LiteLLM proxy base URL and providing a virtual key via the custom `x-api-key` header.

### Option A — Environment Variables

```bash
# Export required variables
export OPENAI_API_BASE="$(cd samples/cloudrun-litellm-proxy/infra && terraform output -raw service_url)/v1"
export OPENAI_API_KEY="sk-your-virtual-key-here"  # Replace with your issued key

# Override the default header to use x-api-key (required for Cloud Run GFE bypass)
export OPENAI_API_HEADER="x-api-key=Bearer ${OPENAI_API_KEY}"

# Run Antigravity CLI
agy
```

### Option B — Configuration File

Create or edit `~/.config/antigravity/config.yaml`:

```bash
mkdir -p ~/.config/antigravity
cat > ~/.config/antigravity/config.yaml << EOF
api:
  base_url: "https://your-cloudrun-url.run.app/v1"  # Replace with your URL
  api_key: "sk-your-virtual-key-here"               # Replace with your key
  headers:
    x-api-key: "Bearer sk-your-virtual-key-here"    # Custom auth header
  default_model: "gemini-2.5-flash"
EOF
```

### Option C — Verify with a Direct API Call

```bash
SERVICE_URL=$(cd samples/cloudrun-litellm-proxy/infra && terraform output -raw service_url)
USER_KEY="sk-your-virtual-key-here"

curl -sS -X POST "${SERVICE_URL}/v1/chat/completions" \
  -H "x-api-key: Bearer ${USER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.5-flash",
    "messages": [{"role": "user", "content": "Reply with: Proxy working!"}]
  }' | jq -r '.choices[0].message.content'
# Expected: Proxy working!
```

---

## 4. Available Gemini & Gemma Models

| Model Alias | Vertex AI Backend | Context | Best For |
|---|---|---|---|
| `gemini-2.5-flash` | `gemini-2.5-flash` | 1M tokens | Speed & cost-efficiency |
| `gemini-2.5-pro` | `gemini-2.5-pro` | 1M tokens | Complex reasoning |
| `gemma-3-27b` | `google/gemma3` (Model Garden) | 128K tokens | Open-weight, self-hostable |

> [!IMPORTANT]
> **Gemma requires GPU endpoint access.** Request Model Garden access for `google/gemma3` in `europe-west4` before using `gemma-3-27b`.

---

## 5. Monitor Your Usage

After running queries, you can inspect your token usage and cost in BigQuery:

```bash
PROJECT_ID=$(cd samples/cloudrun-litellm-proxy/infra && terraform output -raw project_id 2>/dev/null || echo "YOUR_PROJECT_ID")

bq query --project_id="${PROJECT_ID}" --use_legacy_sql=false "
SELECT
  DATE(created_at)        AS day,
  model,
  key_alias,
  SUM(input_tokens)       AS read_tokens,
  SUM(output_tokens)      AS write_tokens,
  ROUND(SUM(spend), 6)    AS cost_usd
FROM \`${PROJECT_ID}.litellm_observability.litellm_logs\`
WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY 1, 2, 3
ORDER BY day DESC, cost_usd DESC
LIMIT 20"
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `401 Unauthorized` | Wrong or missing key | Verify key starts with `sk-` and is passed in `x-api-key` header |
| `404 model not found` | Model alias wrong or not allowed | Check allowed models list: `curl ... /key/info?key=sk-...` |
| `429 Rate Limit` | Budget exhausted | Ask admin to reset budget or increase `max_budget` |
| `503 Service Unavailable` | Cloud Run cold start | Retry after 10-15s; or increase `min_instances` |
