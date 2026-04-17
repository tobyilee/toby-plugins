---
description: Restore from a claude-backup snapshot back into ~/.claude. Defaults to --dry-run (non-destructive preview). Pass --apply to actually overwrite files. Pass --backup PATH to target a specific snapshot instead of the newest one.
argument-hint: [--apply] [--backup PATH]
allowed-tools: Bash
---

## Task: Restore Claude config from a backup

The restore script runs `rsync` from the backup's `dotclaude/` mirror back into `~/.claude/`. It is **additive**: files that exist today but are not in the backup are preserved (no `--delete`).

Run the script below with whatever arguments the user provided via `$ARGUMENTS`. Then:

- **If the dry run (`--apply` was NOT passed):** read the rsync `--itemize-changes` output. If there are meaningful file changes (beyond the bare directory-mtime markers like `.d..t....`), list the top ~10 and ask the user whether they want to re-run with `--apply`. If only directory-mtime markers appear, tell them the target is already in sync with this backup.
- **If the user passed `--apply`:** confirm the restore completed and remind them that their previous state was NOT auto-saved — they can run `/toby-essentials:claude-backup` before a restore next time to capture a safety snapshot first.

### Execute

!bash "${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/restore.sh" $ARGUMENTS
