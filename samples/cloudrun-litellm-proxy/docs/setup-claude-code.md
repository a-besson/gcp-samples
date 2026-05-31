# 🤖 Configure Claude Code with LiteLLM Proxy

This guide explains how to connect **Claude Code** (CLI and VS Code extension) to your LiteLLM proxy running on Cloud Run, routing all Claude API calls through your private Vertex AI backend.

## Prerequisites

- LiteLLM proxy deployed and running (`task apply` completed)
- A valid LiteLLM virtual key issued for your user (`task provision-key`)
- Claude Code CLI installed: `npm install -g @anthropic-ai/claude-code`

---

## 1. Retrieve Your Connection Details

You will need two pieces of information from your LiteLLM proxy administrator:
1. The **Service URL** (e.g., `https://litellm-proxy-abc123xyz.run.app`)
2. Your personal **Virtual API Key** (starts with `sk-`)

> [!TIP]
> If you are the administrator, see the [User Management Guide](./user-management.md) for instructions on how to provision users and retrieve their virtual keys via Terraform.

---

## 2. Configure the CLI (shell session)

Claude Code uses the `ANTHROPIC_BASE_URL` and `ANTHROPIC_API_KEY` environment variables. Since LiteLLM accepts the Anthropic API format natively and authenticates via the custom `x-api-key` header, you can pass the virtual key directly as `ANTHROPIC_API_KEY`.

```bash
# Export the two required variables in your shell
export ANTHROPIC_BASE_URL="<YOUR_LITELLM_ENDPOINT>"
export ANTHROPIC_API_KEY="<YOUR_API_KEY>"

# Verify the proxy is reachable before starting claude
curl -sS -o /dev/null -w "HTTP %{http_code}\n" \
  -H "x-api-key: Bearer ${ANTHROPIC_API_KEY}" \
  "${ANTHROPIC_BASE_URL}/health/liveliness"
# Expected: HTTP 200

# Launch Claude Code
claude
```

> [!TIP]
> Add these exports to your `~/.zshrc` or `~/.bashrc` to make them persistent across sessions.

```bash
# Add to ~/.zshrc (persistent configuration)
cat >> ~/.zshrc << 'EOF'

# LiteLLM Proxy — Claude Code configuration
export ANTHROPIC_BASE_URL="<YOUR_LITELLM_ENDPOINT>"
export ANTHROPIC_API_KEY="<YOUR_API_KEY>"
EOF
```

---

## 3. Configure the VS Code Extension

The Claude Code VS Code extension respects the same environment variables as the CLI. If your shell is already configured (step 2), the extension picks them up automatically when VS Code is launched from a configured terminal.

For a **persistent VS Code configuration** independent of the shell environment, add the following to your VS Code `settings.json`:

```bash
# Open VS Code settings.json
code --open-url "vscode://settings/claude.apiBaseUrl"
```

Or edit `~/.config/Code/User/settings.json` manually:

```json
{
  "claude.apiBaseUrl": "<YOUR_LITELLM_ENDPOINT>",
  "claude.apiKey": "<YOUR_API_KEY>"
}
```

> [!NOTE]
> The VS Code extension reads `claude.apiBaseUrl` and `claude.apiKey` from settings. These override the shell environment variables.

---

## 4. Verify the Integration

```bash
# Quick test: send a message via Claude Code CLI
claude -p "Reply with exactly: LiteLLM proxy is working!"

# Expected output:
# LiteLLM proxy is working!
```

Check the proxy logs (if you have Google Cloud access) to confirm the request was routed through Vertex AI:

```bash
# Tail Cloud Run logs (last 10 minutes)
gcloud logging read \
  'resource.type="cloud_run_revision" AND resource.labels.service_name="litellm-proxy-sample"' \
  --project="<YOUR_GCP_PROJECT_ID>" \
  --freshness=10m \
  --format="value(textPayload)" \
  | grep -E "(model|claude|spend|success)" | head -20
```

---

## 5. Available Claude Models

| Model Alias | Vertex AI Backend | Context |
|---|---|---|
| `claude-opus-4-7` | `claude-opus-4@20250514` | 200K tokens — most capable |
| `claude-sonnet-4-6` | `claude-sonnet-4-5@20250514` | 200K tokens — balanced |
| `claude-haiku-4-5` | `claude-haiku-3-5@20241022` | 200K tokens — fastest |

> [!IMPORTANT]
> Model aliases are configured in the LiteLLM proxy `config.yaml`. Contact your admin to request access to additional models.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `401 Unauthorized` | Wrong or missing key | Verify `ANTHROPIC_API_KEY` starts with `sk-` and is valid |
| `404 Not Found` | Wrong base URL | Verify `ANTHROPIC_BASE_URL` points to your Cloud Run URL (no trailing slash) |
| `403 Forbidden` | Key has no budget or model access | Ask admin to check key budget and allowed models |
| `model not found` | Model alias not in your key's allowed list | Ask admin to add the model to your key |
