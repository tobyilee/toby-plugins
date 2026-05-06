# Changelog

All notable changes to toby-plugins are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.0] - 2026-05-06

### Changed (BREAKING)

- **Plugin split.** `toby-essentials` is removed and replaced with **5 focused plugins**, each addressing a distinct usage pattern. Existing users must reinstall the plugins they want individually — there is no compatibility shim.

  | New plugin | Inherits | Rationale |
  |---|---|---|
  | `toby-multi-agent` | `codex-delegate`, `gemini-delegate`, `cmux`, `toby-team-starter`, `toby-codex`, `toby-gemini`, `tdd-team`, `MODELS.md` | All depend on cmux and/or share `MODELS.md` — they're effectively one workflow. |
  | `toby-session` | `handoff`, `catchup`, `save-conversation`, `save-conv-before-commit.sh` hook | Session lifecycle (start/end/log). The hook is paired with `save-conversation` and the `conv-logs/` workflow — must ship together. |
  | `toby-claude-config` | `claude-backup` skill + 3 commands, `/merge-permissions`, `block-dangerous.sh` hook | Everything that touches `~/.claude` or shell-permission boundaries. |
  | `toby-codereview` | `/code-quality`, `/code-explore`, `prd` skill | "Fan out parallel agents → markdown report" pattern. |
  | `toby-personal` | `toby-facebook-style`, `omc-tips`, `use-harness`, `spring-boot-init`, `spring-boot4-guide` | Personal/domain-specific. Install only if useful. |

- **History preservation:** all moves used `git mv`, so per-file history (`git log --follow`) traces back to the `toby-essentials` era unchanged.
- **`MODELS.md`** moved to `plugins/toby-multi-agent/MODELS.md`. The grep verification path in its update procedure now points to `plugins/toby-multi-agent/skills/`.
- **Skill template** moved out of any plugin: `plugins/toby-essentials/skills/_template/` → `templates/_skill-template/`. It's now a repo-level scaffold usable across all 5 plugins.
- **`marketplace.json`** lists 5 plugin entries instead of 1.
- **Versioning reset:** each new plugin starts at `1.0.0`. The `toby-essentials` `1.x` line is closed.

### Migration

To get back the same set of skills you had on `1.31.0`, install all 5 plugins. To shed what you don't use, install selectively — most users probably want `toby-multi-agent` + `toby-session` + `toby-claude-config`.

## [1.31.0] - 2026-05-06

### Fixed

- **Hook (`block-dangerous.sh`):** Recursive-`rm` regex now also catches `-R`, `--recursive`, and `--no-preserve-root`. Adds a `python3 → python → realpath → shell` chain so the hook keeps working in environments without `python3` (e.g. Alpine). Refactored into a `resolve_path` helper.
- **Hook (`save-conv-before-commit.sh`):** Switched output protocol to `decision: "block"` JSON on stdout + `exit 0` (current Claude Code hook spec) instead of stderr-JSON + exit 2. `git commit --amend` now passes through (amends edit existing commits and don't need a new conversation log). Replaced `xargs -0 ls -t` (filename-unsafe) with a `find -print0` + `stat` loop. Staleness window relaxed 3 min → 5 min.
- **Skill (`toby-codex`, `toby-gemini`):** Result directory now anchored to `git rev-parse --show-toplevel` (with `pwd` fallback) — no more results landing in subdirectories. Removed the literal heredoc fragment from the prompt template (Codex/Gemini were copying `[your response here]` verbatim). Added a multi-line `cmux send` safety note covering the `$(cat …)` newline-collapse trap. Hardcoded 30-min watcher timeout is now `TOBY_CODEX_TIMEOUT_SEC` / `TOBY_GEMINI_TIMEOUT_SEC` (default 1800 s).
- **Skill (`toby-team-starter`):** Replaced `cmux send "command\n"` with `cmux send "command"` + `cmux send-key … enter` for both Codex and Gemini pane launches — consistent with `toby-codex`/`toby-gemini`, no reliance on `cmux send` interpreting backslash-`n`.
- **Skill (`save-conversation`):** `git rev-parse --show-toplevel` now falls back to `pwd` when not in a git repo (previously could write to `/conv-logs/...`). Replaced the `find … | xargs ls -t` previous-save lookup with a filename-safe `stat` loop.
- **Skill (`tdd-team`):** "Test already passes → skip GREEN, go to REFACTOR" reframed as a STOP condition — a passing test in RED indicates either the behavior already exists (skip the cycle) or the test is wrong (rewrite). Falling through to REFACTOR is a TDD anti-pattern.
- **Skill (`omc-tips`):** Removed hardcoded counts ("19 specialized agents, 37 skills, 20 lifecycle hooks") in favor of `omc list-agents` / `omc list-skills` / `omc list-hooks` callouts — counts drift fast across OMC versions.

### Changed

- **Skill (`prd`):** Frontmatter converted to YAML folded `>` block (matches the rest of the plugin). Added 8 Korean trigger phrases. Version normalized 1.0.0 → 0.2.0 to match the plugin-wide 0.x convention.
- **Skill (`claude-backup`):** Frontmatter description converted to YAML folded `>` block for consistency.
- **Skill template (`_template/SKILL.md.template`):** Added bilingual trigger example, project-root path convention, and a "Style Conventions for This Plugin" section so new skills inherit the house style.

## [1.30.0] - 2026-04-23

### Added
- **Two new session-management skills** forming a handoff/catchup pair, operationalizing the "Document & Clear" pattern (Tier 2 of the session-handoff strategy):
  - `handoff` (`v0.1.0`) — writes a forward-looking session handoff to `.claude/reports/handoff/handoff-<timestamp>.md` with Summary, Key Decisions, Traps to Avoid, Working Agreements, line-numbered file refs, status-form Open Work, and a verifying "Prompt for New Chat". Enforces the ~2K-token budget and "no imperatives in Open Work" rule via a pre-save checklist step in the skill workflow.
  - `catchup` (`v0.1.0`) — at the start of a new session, reads the newest `handoff-*.md`, Read-verifies every referenced file, cross-checks against `git status` / `git log`, classifies each claim as ✅Confirmed / ⚠️Shifted / ❌Missing / ❓Ambiguous, then **stops** for user instruction. Structurally enforces the "handoff is hypothesis, not fact" rule — the report cannot be produced without the verification pass.
- Both skills are `user-invocable: true` (`/toby-essentials:handoff`, `/toby-essentials:catchup`).
- README blurb updated: 15 → 17 skills, mention of `session handoff/catchup` added.

## [1.29.0] - 2026-04-17

### Added
- **New skill `claude-backup`** (`v0.1.0`) — back up and restore the user-authored parts of `~/.claude/`: global `CLAUDE.md`, `settings.json` (hooks live here too), user-level commands/skills/subagents, installed plugin manifests, and cloned marketplace repos. Explicit allowlist; caches, session state, plugin-generated data, and bot tokens are excluded by policy. Backups are timestamped under `~/.claude-backup/` — a **sibling** of `~/.claude/` rather than inside it, so snapshots survive a full reinstall that deletes `~/.claude/`.
- **Three slash-command wrappers** for the skill:
  - `/toby-essentials:claude-backup` — create a timestamped backup
  - `/toby-essentials:claude-backup-list` — list existing snapshots newest-first
  - `/toby-essentials:claude-restore [--apply] [--backup PATH]` — restore; dry-run by default (shows rsync itemized diff), `--apply` to commit, additive (no `--delete` — restoring can never remove work added since the snapshot)
- Symlinks inside `~/.claude/skills/` (e.g. `autoplan -> gstack/autoplan`) are preserved verbatim via `rsync -a` rather than dereferenced.

## [1.28.0] - 2026-04-17

### Fixed
- **Security:** `block-dangerous.sh` now resolves symlinks via `realpath` instead of `normpath`. Previously a symlink inside the project pointing to `/etc` would bypass the `rm -rf` guard. Also: project directory is now read from the hook's JSON `cwd` field (with `pwd` fallback) instead of relying on the shell's cwd.
- **Bug:** `save-conv-before-commit.sh` error message said "older than 1 minute" but the threshold was 3 minutes (180 s). Message now matches code.
- **UX:** `save-conv-before-commit.sh` is now **opt-in per project** — if the repo doesn't have a `conv-logs/` directory at its root, the hook exits 0 (allows commit) instead of blocking. Previously every `git commit` in every unrelated repo was intercepted.

### Changed
- **Consistency:** `tdd-team` skill `name` field changed from `"TDD Team"` to `"tdd-team"` (kebab-case, matches directory name and every other skill).
- **Removed fragile sleeps:** `toby-team-starter` replaced two `sleep 0.5` shell-init waits with a `cmux read-screen` IPC round-trip. Respects the project's "no sleep" convention for cmux skills.
- **Stale-info hedge:** `omc-tips` now carries a "Last verified against OMC v4.12.x" banner so readers know when the agent/skill counts need re-checking.

### Added
- `spring-boot-init` skill gained a `version: 0.1.0` frontmatter field (previously missing).
- New `plugins/toby-essentials/MODELS.md` — single source of truth for default Codex/Gemini model versions. Reduces upgrade edits from 11 lines to 1 table + the referenced skills.
- New `plugins/toby-essentials/skills/_template/SKILL.md.template` — boilerplate for creating new skills consistently.
- `CHANGELOG.md` (this file).

## [1.27.0] - 2026-04-15

Version bump. See git log for details.

## [1.26.0] - 2026-04-10

Version bump. See git log for details.

## [1.25.0] and earlier

See `git log plugins/toby-essentials/.claude-plugin/plugin.json`.
