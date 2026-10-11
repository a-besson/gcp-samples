#!/bin/bash

# ==============================================================================
# Gemma-compatible CLI for Ollama Local (OpenAI-compatible)
# Author: Antigravity Agent
# ==============================================================================

set -e

# Default API values
API_KEY="${GEMINI_API_KEY:-sk-local-dummy}"
BASE_URL="${GOOGLE_AI_BASE_URL:-http://localhost:11434/v1}"

# Handle Modes (fast/thinking)
# Default is 'fast'
MODE="fast"
IF_FIRST_ARG=$1

if [[ "$IF_FIRST_ARG" == "fast" || "$IF_FIRST_ARG" == "thinking" ]]; then
    MODE="$IF_FIRST_ARG"
    shift # Remove mode from args
fi

# Determine model based on mode
if [[ "$MODE" == "thinking" ]]; then
    LLM_MODEL="${MODEL_THINKING:-${MODEL:-gemma4:26b}}"
    ICON="🧠"
else
    LLM_MODEL="${MODEL_FAST:-${MODEL:-gemma4:26b}}"
    ICON="⚡"
fi

# Usage help
if [ $# -lt 1 ]; then
    echo "Usage: $0 [fast|thinking] \"prompt\""
    echo "Example: $0 thinking \"Complex architectural question...\""
    exit 1
fi

PROMPT="$1"

# Prepare payload (OpenAI compatible format)
# We use jq to handle escaping of newlines and special characters in the prompt
TEMP_VAL=$( [[ "$MODE" == "thinking" ]] && echo "0.2" || echo "0.7" )

if command -v jq >/dev/null 2>&1; then
    PAYLOAD=$(jq -n \
        --arg model "$LLM_MODEL" \
        --arg content "$PROMPT" \
        --argjson temp "$TEMP_VAL" \
        '{model: $model, messages: [{role: "user", content: $content}], temperature: $temp}')
else
    # Fallback if jq is missing (less robust for multiline)
    PAYLOAD="{\"model\": \"$LLM_MODEL\", \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}], \"temperature\": $TEMP_VAL}"
fi

# Benchmark start
START_TIME=$(python3 -c 'import time; print(int(time.time() * 1000))')

# Execute request
echo "⏳ [$MODE] Querying $LLM_MODEL $ICON at $BASE_URL..."
RESPONSE=$(curl -s -X POST "$BASE_URL/chat/completions" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $API_KEY" \
     -d "$PAYLOAD")

# Benchmark end
END_TIME=$(python3 -c 'import time; print(int(time.time() * 1000))')
DURATION_MS=$((END_TIME - START_TIME))
DURATION_SEC=$(echo "scale=3; $DURATION_MS / 1000" | bc)

# Parse response (requires jq)
if command -v jq >/dev/null 2>&1; then
    CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

    if [ "$CONTENT" == "null" ]; then
        echo "❌ Error response from LLM:"
        echo "$RESPONSE" | jq .
        exit 1
    fi

    # Extract Token Usage
    PROMPT_TOKENS=$(echo "$RESPONSE" | jq -r '.usage.prompt_tokens // 0')
    COMPLETION_TOKENS=$(echo "$RESPONSE" | jq -r '.usage.completion_tokens // 0')
    TOTAL_TOKENS=$(echo "$RESPONSE" | jq -r '.usage.total_tokens // 0')

    # Calculate tokens per second
    if [ "$COMPLETION_TOKENS" -gt 0 ] && [ "$DURATION_MS" -gt 0 ]; then
        TPS=$(echo "scale=2; $COMPLETION_TOKENS / $DURATION_SEC" | bc)
    else
        TPS=0
    fi

    echo "🤖 Response ($MODE):"
    echo "--------------------------------------------------------------------------------"
    echo "$CONTENT"
    echo "--------------------------------------------------------------------------------"
    echo "📊 Performance Metrics:"
    echo "⏱️  Execution Time: ${DURATION_SEC}s"
    echo "🎫 Tokens: ${TOTAL_TOKENS} (Prompt: ${PROMPT_TOKENS}, Completion: ${COMPLETION_TOKENS})"
    echo "🚀 Speed: ${TPS} tokens/sec"
    echo "--------------------------------------------------------------------------------"
else
    echo "⚠️ Warning: 'jq' not found. Displaying raw JSON response."
    echo "$RESPONSE"
    echo "⏱️  Execution Time: ${DURATION_SEC}s"
fi
