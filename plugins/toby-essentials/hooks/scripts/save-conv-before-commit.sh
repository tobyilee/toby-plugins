#!/bin/bash
# Pre-commit hook: Ensure save-conversation is run before git commit
# Blocks git commit if no recent conversation log exists or if it's not staged.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only intercept commands that contain git commit (including chained: git add ... && git commit ...)
if ! echo "$COMMAND" | grep -qE '(^|\&\&|;|\|)\s*git\s+commit\b'; then
  echo "No git commit command detected, allowing execution."
  exit 0
fi

PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')
if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR=$(pwd)
fi

LOGDIR="$PROJECT_DIR/claudelogs"

# Check if claudelogs directory exists and has conv logs
if [ ! -d "$LOGDIR" ]; then
  cat >&2 <<'EOF'
{
  "decision": "deny",
  "reason": "git commit intercepted: no conversation log found",
  "systemMessage": "HOOK INSTRUCTION: Before running git commit, you MUST do the following steps in order:\n1. Run the save-conversation skill (invoke Skill tool with skill: 'toby-essentials:save-conversation')\n2. After the conversation log file is created, run: git add claudelogs/\n3. Then retry the original git commit command.\n\nDo NOT skip these steps. Do NOT ask the user for confirmation - just do it."
}
EOF
  exit 2
fi

# Find the most recent conv-*.md file
LATEST_LOG=$(ls -t "$LOGDIR"/conv-*.md 2>/dev/null | head -1)

if [ -z "$LATEST_LOG" ]; then
  cat >&2 <<'EOF'
{
  "decision": "deny",
  "reason": "git commit intercepted: no conversation log found",
  "systemMessage": "HOOK INSTRUCTION: Before running git commit, you MUST do the following steps in order:\n1. Run the save-conversation skill (invoke Skill tool with skill: 'toby-essentials:save-conversation')\n2. After the conversation log file is created, run: git add claudelogs/\n3. Then retry the original git commit command.\n\nDo NOT skip these steps. Do NOT ask the user for confirmation - just do it."
}
EOF
  exit 2
fi

# Check if the latest log was created recently (within last 5 minutes)
if [[ "$OSTYPE" == "darwin"* ]]; then
  FILE_TIME=$(stat -f %m "$LATEST_LOG")
else
  FILE_TIME=$(stat -c %Y "$LATEST_LOG")
fi
CURRENT_TIME=$(date +%s)
AGE=$(( CURRENT_TIME - FILE_TIME ))

if [ "$AGE" -gt 60 ]; then
  cat >&2 <<'EOF'
{
  "decision": "deny",
  "reason": "git commit intercepted: conversation log is older than 1 minute",
  "systemMessage": "HOOK INSTRUCTION: The latest conversation log is stale. Before running git commit, you MUST do the following steps in order:\n1. Run the save-conversation skill (invoke Skill tool with skill: 'toby-essentials:save-conversation')\n2. After the conversation log file is created, run: git add claudelogs/\n3. Then retry the original git commit command.\n\nDo NOT skip these steps. Do NOT ask the user for confirmation - just do it."
}
EOF
  exit 2
fi

# Check if the latest log is staged or already committed
RELATIVE_LOG=$(python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$LATEST_LOG" "$PROJECT_DIR")

cd "$PROJECT_DIR"
if ! git diff --cached --name-only | grep -qF "$RELATIVE_LOG"; then
  if ! git ls-files --error-unmatch "$RELATIVE_LOG" >/dev/null 2>&1; then
    cat >&2 <<EOF
{
  "decision": "deny",
  "reason": "git commit intercepted: conversation log not staged",
  "systemMessage": "HOOK INSTRUCTION: Conversation log exists but is not staged. Run: git add \"$RELATIVE_LOG\" and then retry the git commit."
}
EOF
    exit 2
  fi
fi

# All checks passed
exit 0
