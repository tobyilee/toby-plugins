#!/bin/bash
# PreToolUse hook: block recursive deletes outside the project directory.
# Allows recursive deletes only when every target resolves inside the project root.
# Detects flags: -r, -R, -rf, -fr, -Rf, --recursive, plus --no-preserve-root.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
HOOK_CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# realpath helper — prefer python3, fall back to /usr/bin/python, then to readlink/cd.
resolve_path() {
  local p="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$p"
  elif command -v python >/dev/null 2>&1; then
    python -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$p"
  elif command -v realpath >/dev/null 2>&1; then
    realpath "$p"
  else
    # Best-effort fallback using cd in a subshell — works for existing dirs only.
    ( cd "$(dirname "$p")" 2>/dev/null && printf '%s/%s\n' "$(pwd)" "$(basename "$p")" ) || printf '%s\n' "$p"
  fi
}

# 1) Block --no-preserve-root regardless of target — protects against accidental `rm -rf --no-preserve-root /`.
if echo "$COMMAND" | grep -qE 'rm[[:space:]]+([^|;&]*[[:space:]])?--no-preserve-root\b'; then
  echo "BLOCKED: rm --no-preserve-root is not allowed" >&2
  exit 2
fi

# 2) Block indirect rm via shell -c / eval (recursive variants only).
if echo "$COMMAND" | grep -qiE '(bash|sh|zsh|dash|ksh)[[:space:]]+-c[[:space:]]+.*rm[[:space:]]+(-[a-zA-Z]*[rR]|--recursive)\b'; then
  echo "BLOCKED: Indirect recursive rm via shell -c is not allowed" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qiE 'eval[[:space:]]+.*rm[[:space:]]+(-[a-zA-Z]*[rR]|--recursive)\b'; then
  echo "BLOCKED: Indirect recursive rm via eval is not allowed" >&2
  exit 2
fi

# 3) Detect any recursive rm (-r, -R, --recursive, with or without -f). If found, every
#    target must resolve inside the project directory.
if echo "$COMMAND" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)\b'; then
  PROJECT_DIR="${HOOK_CWD:-$(pwd)}"
  PROJECT_DIR=$(resolve_path "$PROJECT_DIR")
  BLOCKED=false
  BAD_PATH=""
  # Strip everything up through the rm + flag tokens, leaving target paths.
  TARGETS=$(echo "$COMMAND" | sed -E 's/^.*rm([[:space:]]+(-[a-zA-Z]+|--[a-zA-Z-]+))+[[:space:]]+//' | tr ' ' '\n')
  while IFS= read -r TARGET; do
    [ -z "$TARGET" ] && continue
    TARGET=$(echo "$TARGET" | sed -E "s/^['\"]|['\"]$//g")
    [ -z "$TARGET" ] && continue
    if [[ "$TARGET" = /* ]]; then
      ABS_PATH="$TARGET"
    else
      ABS_PATH="$PROJECT_DIR/$TARGET"
    fi
    ABS_PATH=$(resolve_path "$ABS_PATH")
    if [[ "$ABS_PATH" != "$PROJECT_DIR"/* ]]; then
      BLOCKED=true
      BAD_PATH="$ABS_PATH"
      break
    fi
  done <<< "$TARGETS"
  if $BLOCKED; then
    echo "BLOCKED: recursive rm outside project directory ($BAD_PATH not under $PROJECT_DIR)" >&2
    exit 2
  fi
fi

exit 0
