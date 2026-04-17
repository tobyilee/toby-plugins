#!/usr/bin/env bash
# Back up user-authored items under ~/.claude to a timestamped folder.
# See the skill's SKILL.md and references/include-exclude.md for scope.
set -euo pipefail

SOURCE="${CLAUDE_HOME:-$HOME/.claude}"
BACKUP_ROOT="${CLAUDE_BACKUP_ROOT:-$HOME/.claude-backup}"
TS="$(date +%Y%m%d-%H%M%S)"
DEST="$BACKUP_ROOT/claude-$TS"
MIRROR="$DEST/dotclaude"
LOG="$DEST/MANIFEST.txt"

if [[ ! -d "$SOURCE" ]]; then
  echo "Source directory not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$MIRROR"

# Top-level files to copy verbatim when present.
FILES=(
  "CLAUDE.md"
  "settings.json"
  "statusline.sh"
  "statusline-command.sh"
  ".omc-config.json"
)

# Top-level directories to copy with generic excludes applied inside.
DIRS=(
  "commands"
  "skills"
  "plans"
  "hud"
  "teams"
  ".omc"
  "agents"       # included if the user ever adds user-level subagents
)

# Plugin manifest files (in ~/.claude/plugins/) — small, critical for restore.
PLUGIN_FILES=(
  "installed_plugins.json"
  "known_marketplaces.json"
  "blocklist.json"
)

# Excludes applied inside every rsync'd directory. Caches and editor junk
# only. We intentionally keep .git inside marketplace clones so the restored
# clones remain functional git repos.
RSYNC_EXCLUDES=(
  --exclude='cache/'
  --exclude='node_modules/'
  --exclude='__pycache__/'
  --exclude='.DS_Store'
  --exclude='*.log'
)

# --- Manifest header -------------------------------------------------------
{
  echo "claude-backup manifest"
  echo "created_at:  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "source:      $SOURCE"
  echo "destination: $DEST"
  echo "hostname:    $(hostname -s 2>/dev/null || hostname)"
  echo "user:        ${USER:-$(id -un)}"
  echo
  echo "--- entries copied ---"
} > "$LOG"

copy_file() {
  local rel="$1"
  local src="$SOURCE/$rel"
  local dst="$MIRROR/$rel"
  # -e misses broken symlinks; -L catches them too
  if [[ -e "$src" || -L "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
    echo "FILE $rel" >> "$LOG"
    echo "  file  $rel"
  fi
}

copy_dir() {
  local rel="$1"
  local src="$SOURCE/$rel"
  local dst="$MIRROR/$rel"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    rsync -a "${RSYNC_EXCLUDES[@]}" "$src/" "$dst/"
    echo "DIR  $rel" >> "$LOG"
    echo "  dir   $rel"
  fi
}

echo "Source:      $SOURCE"
echo "Destination: $DEST"
echo

for f in "${FILES[@]}"; do copy_file "$f"; done
for d in "${DIRS[@]}"; do copy_dir "$d"; done

for f in "${PLUGIN_FILES[@]}"; do copy_file "plugins/$f"; done

# plugins/marketplaces/ — fat copy, but drop temp_* and caches.
if [[ -d "$SOURCE/plugins/marketplaces" ]]; then
  mkdir -p "$MIRROR/plugins/marketplaces"
  rsync -a \
    "${RSYNC_EXCLUDES[@]}" \
    --exclude='temp_*' \
    "$SOURCE/plugins/marketplaces/" "$MIRROR/plugins/marketplaces/"
  echo "DIR  plugins/marketplaces  (excl. temp_*, caches)" >> "$LOG"
  echo "  dir   plugins/marketplaces (excluding temp_* and caches)"
fi

echo >> "$LOG"
echo "--- excluded by policy ---" >> "$LOG"
cat >> "$LOG" <<'EOF'
Session / runtime:   projects/, sessions/, session-env/, shell-snapshots/,
                     file-history/, transcripts/, tasks/, history.jsonl,
                     .session-stats.json, security_warnings_state_*.json,
                     ide/, chrome/
Caches:              cache/, paste-cache/, plugins/cache/,
                     plugins/install-counts-cache.json
Plugin-generated:    plugins/data/, plugins/oh-my-claudecode/
Secrets (policy):    channels/  (bot tokens — re-run configure skills)
Telemetry:           telemetry/
Legacy snapshots:    .claude.YYYYMMDD one-off dirs from older upgrades
Temp marketplaces:   plugins/marketplaces/temp_*
Generic inside dirs: cache/, node_modules/, __pycache__/, *.log, .DS_Store
EOF

echo
echo "Backup complete."
if command -v du >/dev/null 2>&1; then
  du -sh "$DEST" | awk '{printf "Size: %s\n", $1}'
fi
echo "Path: $DEST"
