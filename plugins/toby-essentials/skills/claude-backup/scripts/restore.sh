#!/usr/bin/env bash
# Restore a claude-backup snapshot back into ~/.claude.
# Default is a dry run. Pass --apply to actually overwrite.
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: restore.sh [--apply] [--backup PATH]

Restores files from a claude-backup snapshot into ~/.claude. By default this
is a DRY RUN: it uses rsync --dry-run and prints an itemized change list but
does not modify any file. Pass --apply to perform the restore.

Restore is additive: files that exist today but are not in the backup are
preserved (no --delete). This means restoring cannot remove work added after
the snapshot was taken.

Options:
  --backup PATH   Path to the backup folder (claude-YYYYMMDD-HHMMSS).
                  Defaults to the newest folder under ~/.claude-backup/.
  --apply         Actually perform the restore. Without this flag, nothing
                  on disk changes.
  --help, -h      Show this help.

Environment:
  CLAUDE_HOME         Override the restore target (default: $HOME/.claude)
  CLAUDE_BACKUP_ROOT  Override the backup root (default: $HOME/.claude-backup)
USAGE
}

TARGET="${CLAUDE_HOME:-$HOME/.claude}"
BACKUP_ROOT="${CLAUDE_BACKUP_ROOT:-$HOME/.claude-backup}"
BACKUP=""
APPLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --backup) BACKUP="${2:-}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$BACKUP" ]]; then
  BACKUP="$(ls -1dt "$BACKUP_ROOT"/claude-* 2>/dev/null | head -1 || true)"
fi

if [[ -z "$BACKUP" || ! -d "$BACKUP" ]]; then
  echo "No backup found under $BACKUP_ROOT" >&2
  echo "Run backup.sh first, or pass --backup PATH." >&2
  exit 1
fi

MIRROR="$BACKUP/dotclaude"
if [[ ! -d "$MIRROR" ]]; then
  echo "Backup appears incomplete — missing: $MIRROR" >&2
  exit 1
fi

mkdir -p "$TARGET"

echo "Backup:  $BACKUP"
echo "Target:  $TARGET"
if [[ $APPLY -eq 1 ]]; then
  echo "Mode:    APPLY (files will be overwritten in place)"
else
  echo "Mode:    DRY RUN (no files will be modified)"
fi
echo

RSYNC_FLAGS=(-a --itemize-changes)
if [[ $APPLY -eq 0 ]]; then
  RSYNC_FLAGS+=(--dry-run)
fi

rsync "${RSYNC_FLAGS[@]}" "$MIRROR/" "$TARGET/"

echo
if [[ $APPLY -eq 0 ]]; then
  echo "Dry run complete. No files were modified."
  echo "Re-run with --apply to perform the restore."
else
  echo "Restore complete."
fi
