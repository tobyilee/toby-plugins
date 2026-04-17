# Changelog

All notable changes to toby-plugins are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
