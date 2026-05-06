---
name: claude-backup
version: 0.1.0
description: >
  Use this skill whenever the user wants to back up or restore their global Claude Code
  configuration under ~/.claude — global CLAUDE.md, settings.json, user-level
  commands/skills/subagents, installed plugin marketplaces, and install manifests.
  Trigger on "claude backup", "backup claude", "backup my claude config", "snapshot claude",
  "restore claude", "claude 백업", "클로드 백업", "claude 복구", "claude 복원",
  "설정 백업", "글로벌 설정 백업", "내 claude 설정 저장", "claude 설정 복원",
  "plugin 백업", "설치된 플러그인 백업", "백업으로 되돌려", "이전 백업으로 복원",
  "원래 상태로 되돌려", "backup ~/.claude", "restore my plugins",
  "migrate claude to another machine".
  Also trigger when the user is about to do something risky to their global Claude config
  (big settings edit, plugin overhaul, reinstalling Claude Code) and mentions wanting a
  snapshot/checkpoint first, or when they mention losing plugins and wanting the previous
  state back. Do NOT trigger for project-level backups, git stashes, or generic
  "backup my repo" — this skill is specifically for the ~/.claude user directory.
---

# claude-backup

Back up the user-authored parts of `~/.claude/` to a timestamped folder and restore from it later.

## When to use

- The user wants a checkpoint before changing plugins, settings, or hooks.
- The user wants to move their Claude Code setup to another machine.
- The user lost or corrupted a file under `~/.claude/` and wants the previous state.
- The user says "back up my claude config" / "restore claude" in any phrasing.

## How to use

Three scripts live in `scripts/`. Run them directly from bash — each is self-contained and idempotent. The `toby-essentials` plugin also ships three slash-command wrappers for explicit invocation when natural-language triggering isn't desirable:

- `/toby-essentials:claude-backup` → runs `backup.sh`
- `/toby-essentials:claude-backup-list` → runs `list-backups.sh`
- `/toby-essentials:claude-restore [--apply] [--backup PATH]` → runs `restore.sh` with passthrough args

### Create a backup
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/backup.sh
```
Writes to `~/.claude-backup/claude-<YYYYMMDD-HHMMSS>/`. Prints the path and total size at the end. Exits non-zero only if the source dir is missing or a copy fails. The backup root lives **outside** `~/.claude/` deliberately — it survives a full reinstall that deletes `~/.claude/`.

### List existing backups
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/list-backups.sh
```
Prints size, creation timestamp, and path for each backup under `~/.claude-backup/`, newest first.

### Restore
```bash
# Dry run against the newest backup (default — shows what would change, does nothing)
bash ${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/restore.sh

# Dry run against a specific backup
bash ${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/restore.sh --backup ~/.claude-backup/claude-20260417-171500

# Actually overwrite live files
bash ${CLAUDE_PLUGIN_ROOT}/skills/claude-backup/scripts/restore.sh --apply
```
**Restore is additive**, not destructive: it overwrites files present in the backup, but does NOT delete files that exist today but weren't in the backup. That means you can never lose work you've added since the last snapshot by restoring.

## What's inside a backup

Each backup mirrors the `~/.claude/` layout under a `dotclaude/` subfolder, so restore is a one-line `rsync`:

```
~/.claude-backup/claude-20260417-171500/
├── MANIFEST.txt                # human-readable: timestamp, source, entries copied
└── dotclaude/
    ├── CLAUDE.md
    ├── settings.json           # contains your hooks + permissions
    ├── statusline.sh
    ├── statusline-command.sh
    ├── .omc-config.json
    ├── commands/               # user-level slash commands
    ├── skills/                 # user-level skills (symlinks preserved)
    ├── plans/                  # authored plan documents
    ├── hud/                    # HUD scripts
    ├── teams/                  # team configs
    ├── .omc/                   # OMC user config
    └── plugins/
        ├── installed_plugins.json
        ├── known_marketplaces.json
        ├── blocklist.json
        └── marketplaces/       # cloned marketplace repos, fat (excl. caches + temp_*)
```

## What is NOT backed up, and why

The skill deliberately excludes anything that is regenerable, session-scoped, or not user-authored. Restoring these would either be wasteful (caches rebuild themselves), stale (session state), or a security risk (bot tokens):

- **Session / runtime:** `projects/`, `sessions/`, `session-env/`, `shell-snapshots/`, `file-history/`, `transcripts/`, `tasks/`, `history.jsonl`, `.session-stats.json`, `security_warnings_state_*.json`, `ide/`, `chrome/`
- **Caches:** `cache/`, `paste-cache/`, `plugins/cache/`, `plugins/install-counts-cache.json`, plus any `cache/`, `node_modules/`, `__pycache__/`, `*.log`, `.DS_Store` inside copied dirs
- **Plugin-generated data:** `plugins/data/`, `plugins/oh-my-claudecode/` (these are rebuilt by plugins on demand)
- **Secrets:** `channels/` (Discord/Telegram bot tokens) — re-run `/discord:configure` and `/telegram:configure` after restore on a new machine
- **Telemetry:** `telemetry/`
- **Legacy one-off snapshots:** `.claude.YYYYMMDD` dirs left by older upgrade flows
- **Temp marketplaces:** `plugins/marketplaces/temp_*`

(The backup root itself lives at `~/.claude-backup/`, outside `~/.claude/`, so there's no self-nesting concern.)

See `references/include-exclude.md` for the full rationale, including why hooks and user-level subagents don't have their own backup entries (hooks live inside `settings.json`; user-level subagents would live in `~/.claude/agents/` if present — the script picks that up automatically).

## Behaviour notes (for agent users of this skill)

- **Where:** default backup root is `~/.claude-backup/` (a sibling of `~/.claude/`, not inside it). Override by setting `CLAUDE_BACKUP_ROOT=/some/other/path` in the environment.
- **Source override:** set `CLAUDE_HOME` to point at a non-default Claude home.
- **Idempotent:** running `backup.sh` twice makes two independent, timestamped folders. It never mutates prior backups.
- **Safety of restore:** `restore.sh` without `--apply` performs an rsync dry run and prints an itemized change list. Review it before re-running with `--apply`.
- **After restore on a new machine:** you may need to re-link any absolute paths that the old machine had (e.g. `skills/*` symlinks into a `gstack/` that you also need to clone). The backup preserves the symlinks verbatim; the link targets must still exist on the destination machine.

## Conversation patterns

When the user asks for a backup, prefer just running `backup.sh` and reporting the resulting path + size. Don't prompt for preferences unless they ask about scope — the allowlist is stable and is the whole point of the skill.

When the user asks to restore, default to `--dry-run` and show them the itemized change list. Only run `--apply` after they confirm. If they also want to capture today's state before overwriting (safety snapshot), run `backup.sh` first, then `restore.sh --apply`.
