#!/usr/bin/env bash

set -euo pipefail

URL="${LLAMA_API_URL:-http://llama-server.puff.lan:8080/v1/chat/completions}"
MODEL="${LLAMA_MODEL:-gemma-4-26B-A4B-it}"
SYSTEM_PROMPT="${LLAMA_SYSTEM_PROMPT:-you are a terminal expert designed to help answer questions about using command line tools. Keep your responses very terse, if possible answer just in bash / command line executable output. Do not wrap your response in markdown or code fences. Return only the raw output text.}"

if [ "$#" -eq 0 ]; then
  printf 'Usage: %s <query>\n' "$(basename "$0")" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  printf 'Error: jq is required for %s\n' "$(basename "$0")" >&2
  exit 1
fi

USER_PROMPT="$*"
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg system "$SYSTEM_PROMPT" \
  --arg user "$USER_PROMPT" \
  '{
    model: $model,
    messages: [
      { role: "system", content: $system },
      { role: "user", content: $user }
    ],
    temperature: 0.2,
    max_tokens: 300
  }')

RESPONSE=$(curl -s "$URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq -r '.choices[0].message.content')

# Strip a single outer fenced code block if the model adds one anyway.
if [[ "$RESPONSE" == '```'*$'\n'* ]]; then
  RESPONSE="${RESPONSE#*$'\n'}"
  RESPONSE="${RESPONSE%$'\n```'}"
fi

printf '%s\n' "$RESPONSE"
