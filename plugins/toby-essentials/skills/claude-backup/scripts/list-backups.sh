#!/usr/bin/env bash
# List claude-backup snapshots under ~/.claude/backups/, newest first.
set -euo pipefail

BACKUP_ROOT="${CLAUDE_BACKUP_ROOT:-$HOME/.claude-backup}"

if [[ ! -d "$BACKUP_ROOT" ]]; then
  echo "No backup directory at $BACKUP_ROOT"
  exit 0
fi

shopt -s nullglob
entries=("$BACKUP_ROOT"/claude-*)
if [[ ${#entries[@]} -eq 0 ]]; then
  echo "No backups found in $BACKUP_ROOT"
  exit 0
fi

printf '%-8s  %-17s  %s\n' 'SIZE' 'CREATED' 'PATH'
for d in "${entries[@]}"; do
  [[ -d "$d" ]] || continue
  size=$(du -sh "$d" 2>/dev/null | awk '{print $1}')
  # claude-20260417-171500 -> 20260417-171500
  created=$(basename "$d" | sed 's/^claude-//')
  printf '%-8s  %-17s  %s\n' "$size" "$created" "$d"
done | sort -r -k2
