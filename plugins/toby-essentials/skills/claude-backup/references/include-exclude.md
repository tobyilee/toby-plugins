# What this skill backs up, and why

This reference exists so that future-you (or a future maintainer) can sanity-check
the include/exclude lists without having to re-derive them from scratch. The short
version: back up anything user-authored or install-manifest-shaped; skip anything
that is cache, session state, or regenerable by a plugin.

## The rules

A path is **backed up** if it meets all three:
1. It's user-authored, or it's a manifest that a plugin/marketplace needs to know about on restore.
2. Losing it would cost the user real work or real configuration.
3. Restoring it is safe — it won't leak secrets onto another machine or desync from a running process.

A path is **excluded** if any of the following hold:
- It's cache — regenerable by the tool that wrote it.
- It's session state — tied to a specific run of Claude Code and meaningless after the run ends.
- It's a bot token or similar credential (policy decision for this skill — re-run the relevant `configure` skill after restore).
- It's a file that a plugin recreates itself on demand.

(Self-nesting isn't a concern because the backup root lives at `~/.claude-backup/`, outside `~/.claude/`.)

## Included — top-level

| Path | Why |
|---|---|
| `CLAUDE.md` | Global user instructions. The one file no one wants to lose. |
| `settings.json` | Global settings **and hooks** — hooks live inside this file, not in a separate `hooks/` dir, so this one file is the backup for both. |
| `statusline.sh`, `statusline-command.sh` | User-authored statusline scripts. |
| `.omc-config.json` | OMC plugin user config. |
| `commands/` | User-level slash commands. |
| `skills/` | User-level skills. Many are symlinks (e.g. into `gstack/`); rsync preserves them verbatim. |
| `plans/` | User-authored plan documents. |
| `hud/` | HUD scripts. |
| `teams/` | Team configuration. |
| `.omc/` | OMC user config files. |
| `agents/` | User-level subagents. Currently unused on most machines, but included so the skill is forward-compatible when the user starts adding global subagents. |

## Included — under `plugins/`

| Path | Why |
|---|---|
| `plugins/installed_plugins.json` | Install manifest. Without this, Claude Code doesn't know which plugins are enabled. |
| `plugins/known_marketplaces.json` | Marketplace registry (URL + last-updated timestamp per marketplace). |
| `plugins/blocklist.json` | Plugin blocklist. |
| `plugins/marketplaces/` | Full marketplace clones (fat). Keeps `.git/` so the restored clones remain functional git repos. Excludes `temp_*` (install cruft) and any `cache/`, `node_modules/`, `__pycache__/` inside. |

## Excluded, grouped by reason

**Session / runtime** — tied to one conversation, meaningless after:
- `projects/` (can be hundreds of MB of transcripts)
- `sessions/`, `session-env/`, `shell-snapshots/`, `file-history/`
- `transcripts/`, `tasks/`, `history.jsonl`, `.session-stats.json`
- `security_warnings_state_*.json`
- `ide/`, `chrome/`

**Caches** — regenerable on demand:
- `cache/`, `paste-cache/`
- `plugins/cache/`, `plugins/install-counts-cache.json`
- Any `cache/`, `node_modules/`, `__pycache__/`, `*.log`, `.DS_Store` inside included directories (applied globally by rsync)

**Plugin-generated data** — each plugin rebuilds what it needs:
- `plugins/data/` — per-plugin persisted state
- `plugins/oh-my-claudecode/` — OMC-generated tree

**Secrets (policy)** — bot tokens shouldn't ride along on a copy:
- `channels/` — Discord/Telegram bot tokens and access config. Re-run `/discord:configure` and `/telegram:configure` after restoring on a new machine.

**Telemetry**:
- `telemetry/`

**Legacy one-off snapshots**:
- `.claude.YYYYMMDD` — dirs left by older upgrade flows

**Temp marketplaces**:
- `plugins/marketplaces/temp_*` — clone staging dirs

## Not mentioned above? It's not in the backup.

The backup logic is a strict allowlist — only the items explicitly named above are copied. New top-level entries under `~/.claude/` will NOT be included until the allowlist is updated. This is intentional: a deny-list would silently start shipping sensitive files the moment a plugin creates a new directory.

If you add a new user-level artifact that should be backed up, add it to the relevant array in `scripts/backup.sh` and extend this document.
