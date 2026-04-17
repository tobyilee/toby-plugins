---
description: List existing claude-backup snapshots under ~/.claude-backup/, newest first, with size and timestamp.
allowed-tools: Bash
---

## Task: List Claude config backups

Run the bundled `list-backups.sh` script below and present the result to the user. If there are no backups, tell them they can run `/toby-essentials:claude-backup` to create one.

### Execute

!bash "${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/list-backups.sh"
