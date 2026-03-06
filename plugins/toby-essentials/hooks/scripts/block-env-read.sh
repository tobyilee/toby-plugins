#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# .env 파일 Read 차단 (.env.local은 허용)
if echo "$FILE_PATH" | grep -qE '\.env$'; then
  echo "BLOCKED: Reading .env files is prohibited" >&2
  exit 2
fi

# .env.production, .env.staging 등 차단 (.env.local만 허용)
if echo "$FILE_PATH" | grep -qE '\.env\.' && ! echo "$FILE_PATH" | grep -qE '\.env\.local$'; then
  echo "BLOCKED: Reading .env files is prohibited (only .env.local is allowed)" >&2
  exit 2
fi

exit 0
