#!/bin/bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit\b'; then
  exit 0
fi

MARKER="/tmp/.claude-save-conv-before-commit"

# If marker exists and is less than 5 minutes old, allow the commit (save-conv already done)
if [ -f "$MARKER" ]; then
  MARKER_AGE=$(( $(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || stat -c %Y "$MARKER" 2>/dev/null || echo 0) ))
  if [ "$MARKER_AGE" -lt 300 ]; then
    rm -f "$MARKER"
    exit 0
  else
    rm -f "$MARKER"
  fi
fi

# Block the commit and instruct Claude to save conversation first
cat >&2 <<'EOF'
{
  "decision": "deny",
  "reason": "git commit intercepted: save-conversation must run first",
  "systemMessage": "HOOK INSTRUCTION: Before running git commit, you MUST do the following steps in order:\n1. Run the save-conversation skill (invoke Skill tool with skill: 'toby-essentials:save-conversation')\n2. After the conversation log file is created, run: touch /tmp/.claude-save-conv-before-commit && git add claudelogs/\n3. Then retry the original git commit command.\n\nDo NOT skip these steps. Do NOT ask the user for confirmation - just do it."
}
EOF
exit 2
