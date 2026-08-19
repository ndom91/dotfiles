#!/usr/bin/env bash

set -euo pipefail

URL="${LLAMA_API_URL:-http://llama-dash.puff.lan/v1/chat/completions}"
MODEL="${LLAMA_MODEL:-qwen3.8-27b}"
SYSTEM_PROMPT="${LLAMA_SYSTEM_PROMPT:-you are a linux expert designed to help answer questions in the terminal. Keep your responses very terse, if possible answer just in bash / command line executable output. Do not wrap your response in markdown or code fences. Return only the raw output text.}"
LLAMA_DASH_KEY=$(op read op://Private/puffy-key/credential)

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

RESPONSE_BODY=$(mktemp)
trap 'rm -f "$RESPONSE_BODY"' EXIT

if HTTP_STATUS=$(curl -sS -o "$RESPONSE_BODY" -w '%{http_code}' "$URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LLAMA_DASH_KEY" \
  -d "$PAYLOAD"); then
  :
else
  CURL_STATUS=$?
  printf 'Error: request failed (curl exit %s)\n' "$CURL_STATUS" >&2
  if [ -s "$RESPONSE_BODY" ]; then
    cat "$RESPONSE_BODY" >&2
    printf '\n' >&2
  fi
  exit "$CURL_STATUS"
fi

if [[ ! "$HTTP_STATUS" =~ ^2[0-9][0-9]$ ]]; then
  printf 'Error: non-2xx response (HTTP %s)\n' "$HTTP_STATUS" >&2
  cat "$RESPONSE_BODY" >&2
  printf '\n' >&2
  exit 1
fi

RESPONSE=$(jq -r '.choices[0].message.content' <"$RESPONSE_BODY")

# Strip a single outer fenced code block if the model adds one anyway.
if [[ "$RESPONSE" == '```'*$'\n'* ]]; then
  RESPONSE="${RESPONSE#*$'\n'}"
  RESPONSE="${RESPONSE%$'\n```'}"
fi

printf '%s\n' "$RESPONSE"
