---
description: Create a timestamped backup of ~/.claude user config (CLAUDE.md, settings.json, user-level commands/skills/subagents, installed plugin manifests and marketplace clones). Writes to ~/.claude-backup/claude-<YYYYMMDD-HHMMSS>/.
allowed-tools: Bash
---

## Task: Create a Claude config backup

Run the bundled `backup.sh` script below and then summarize the result to the user in one short paragraph: destination path, total size, and a one-line reminder that restore defaults to `--dry-run` so it's safe.

If the script exits non-zero, surface the error plainly — do not claim success. The script is idempotent and safe to re-run.

### Execute

!bash "${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/backup.sh"
