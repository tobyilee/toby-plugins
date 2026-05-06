#!/bin/bash
# PreToolUse hook for Bash: ensure save-conversation runs before `git commit`.
# Opt-in: only active in projects that already have conv-logs/ at their root.
# Emits a deny decision JSON to stdout and exits 0 (current Claude Code hook spec).

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only intercept commands that contain `git commit` (including chained / piped forms).
# Skip --amend: amends edit an existing commit and don't need a new conversation log.
if ! echo "$COMMAND" | grep -qE '(^|&&|;|\|)[[:space:]]*git[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi
if echo "$COMMAND" | grep -qE 'git[[:space:]]+commit[[:space:]]+([^|;&]*[[:space:]])?--amend\b'; then
  exit 0
fi

PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')
[ -z "$PROJECT_DIR" ] && PROJECT_DIR=$(pwd)

PROJECT_ROOT=$(git -C "$PROJECT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$PROJECT_DIR")
LOGDIR="$PROJECT_ROOT/conv-logs"

# Opt-in: projects without conv-logs/ don't use this workflow.
[ -d "$LOGDIR" ] || exit 0

# Find the most recent conv-*.md by mtime — avoid xargs+ls (filename-unsafe).
LATEST_LOG=""
LATEST_MTIME=0
while IFS= read -r -d '' f; do
  if [[ "$OSTYPE" == "darwin"* ]]; then
    m=$(stat -f %m "$f")
  else
    m=$(stat -c %Y "$f")
  fi
  if (( m > LATEST_MTIME )); then
    LATEST_MTIME=$m
    LATEST_LOG="$f"
  fi
done < <(find "$LOGDIR" -name 'conv-*.md' -type f -print0 2>/dev/null)

emit_deny() {
  local reason="$1"
  local message="$2"
  jq -n --arg r "$reason" --arg m "$message" '{
    decision: "block",
    reason: $r,
    systemMessage: $m
  }'
  exit 0
}

if [ -z "$LATEST_LOG" ]; then
  emit_deny \
    "git commit intercepted: no conversation log found" \
    "HOOK INSTRUCTION: Before running git commit, you MUST do the following steps in order:
1. Run the save-conversation skill (invoke Skill tool with skill: 'toby-session:save-conversation')
2. Then retry the original git commit command.

Do NOT skip these steps. Do NOT ask the user for confirmation - just do it."
fi

CURRENT_TIME=$(date +%s)
AGE=$(( CURRENT_TIME - LATEST_MTIME ))

# 5 minutes — long enough to commit immediately after a save without races, short enough
# to ensure the saved log actually reflects this session's tail.
if [ "$AGE" -gt 300 ]; then
  emit_deny \
    "git commit intercepted: conversation log is older than 5 minutes" \
    "HOOK INSTRUCTION: The latest conversation log is stale. Before running git commit, you MUST do the following steps in order:
1. Run the save-conversation skill (invoke Skill tool with skill: 'toby-session:save-conversation')
2. Then retry the original git commit command.

Do NOT skip these steps. Do NOT ask the user for confirmation - just do it."
fi

# Resolve relative path without depending on python.
RELATIVE_LOG="${LATEST_LOG#$PROJECT_ROOT/}"

cd "$PROJECT_ROOT" || exit 0
if ! git diff --cached --name-only | grep -qF "$RELATIVE_LOG"; then
  if ! git ls-files --error-unmatch "$RELATIVE_LOG" >/dev/null 2>&1; then
    emit_deny \
      "git commit intercepted: conversation log not staged" \
      "HOOK INSTRUCTION: Conversation log exists but is not staged. Run: git add \"$RELATIVE_LOG\" and then retry the git commit."
  fi
fi

exit 0
