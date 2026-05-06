# toby-plugins

Toby's personal Claude Code plugin marketplace.

## Plugins

### toby-essentials `v1.31.0`

Toby's personal toolkit — 17 skills spanning code analysis, TDD, Spring Boot init & Boot-4 migration guide, PRD generation, AI delegation (Codex/Gemini), cmux terminal control, multi-agent team (toby-codex, toby-gemini), OMC quick-reference, harness templates, Facebook-style writing, conversation logging, session handoff/catchup, ~/.claude config backup/restore, and opt-in security hooks.

Default model versions for Codex/Gemini live in [`plugins/toby-essentials/MODELS.md`](plugins/toby-essentials/MODELS.md) — a single source of truth to reduce upgrade friction. Release notes live in [`CHANGELOG.md`](CHANGELOG.md).

#### Commands

| Command | Description |
|---------|-------------|
| `/code-quality` | Evaluate code quality with 4 parallel agents, score 9 dimensions (readability, maintainability, testability, performance, security, etc.), generate markdown report |
| `/code-explore` | Deep codebase analysis with 5 parallel agents (structure, style, architecture, complexity, testing), generate comprehensive report |
| `/merge-permissions` | Merge local project `.claude/settings.local.json` permissions into global `~/.claude/settings.json` |
| `/claude-backup` | Create a timestamped backup of `~/.claude/` under `~/.claude-backup/claude-<YYYYMMDD-HHMMSS>/` (global config, commands, skills, plugin manifests, marketplace clones). Excludes caches, session state, and bot tokens. |
| `/claude-backup-list` | List existing `~/.claude-backup/` snapshots, newest first, with size + timestamp |
| `/claude-restore` | Restore from a `~/.claude-backup/` snapshot. Dry-run by default; pass `--apply` to overwrite, `--backup PATH` to target a specific snapshot |

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `prd` | 1.0.0 | Generate structured Product Requirements Documents — gather context, ask clarifying questions, produce actionable specs with user stories |
| `tdd-team` | 0.3.0 | 3-agent TDD team (Red/Green/Refactor) with task decomposition, progress tracking (`[x]/[>]/[ ]`), and user checkpoints between cycles |
| `spring-boot-init` | 0.1.0 | Spring Initializr API를 활용한 Spring Boot 프로젝트 생성 — Gradle Kotlin DSL 기반, 인터랙티브 버전/의존성 선택 |
| `spring-boot4-guide` | 0.1.0 | Spring Boot 4 / Spring Framework 7 개발 가이드 — migration, breaking changes, Jackson 3, Jakarta EE 11, modularization |
| `codex-delegate` | 0.3.0 | Delegate tasks to OpenAI Codex CLI — background execution, context gathering, parallel delegation support |
| `gemini-delegate` | 0.3.0 | Delegate tasks to Google Gemini CLI — background execution, context gathering, parallel delegation support |
| `cmux` | 0.2.0 | Control the cmux terminal app — window/workspace/pane/surface management, read-screen, send input, browser automation (DOM, network interception, viewport emulation), SSH, markdown viewer, wait-for synchronization, notifications, sidebar metadata, hooks integration |
| `toby-team-starter` | 0.1.0 | Spawn Codex (`--full-auto`) and Gemini (`--yolo`) in cmux panes alongside Claude — duplicate detection via pane title labeling |
| `toby-codex` | 0.1.0 | Send a task to the Codex cmux pane and collect the result as a file in `tobyteam/` — requires "toby codex" prefix |
| `toby-gemini` | 0.1.0 | Send a task to the Gemini cmux pane and collect the result as a file in `tobyteam/` — requires "toby gemini" prefix |
| `save-conversation` | — | Save a summary of the current conversation to a markdown file, with Korean→English prompt rewrites logged to monthly `prompt-{yyyymm}.md` — trigger with "save conv", "대화 저장", etc. |
| `handoff` | 0.1.0 | Write a forward-looking handoff under `.claude/reports/handoff/handoff-<timestamp>.md` before ending a session — Summary, Key Decisions, Traps to Avoid, line-numbered file refs, **status-form** Open Work, and a verifying "Prompt for New Chat". ~2K token budget |
| `catchup` | 0.1.0 | Resume from the latest handoff — Read-verifies every referenced file, cross-checks against `git status` / `git log`, reports ✅Confirmed / ⚠️Shifted / ❌Missing claims, then **stops** for instruction. Handoff is hypothesis, not fact |
| `omc-tips` | 0.2.0 | oh-my-claudecode (OMC) comprehensive quick-reference — mode selection, magic keywords, 19 agents (3-tier), 37 skills, hooks, MCP tools, and practical examples |
| `use-harness` | 0.1.0 | Quick-start menu for pre-built harness use cases — 8 templates across 4 categories (Research, Content, Media, Engineering), category→use case two-step selection, launches via harness:harness |
| `toby-facebook-style` | 0.1.0 | Draft social posts in Toby's Facebook voice — 반말 평서체, 한영 혼용, 4-pattern frame (기술 관찰 / URL 코멘트 / 일상 에세이 / 한마디), distilled from 3,757 posts (2010–2026) |
| `claude-backup` | 0.1.0 | Back up and restore the user-authored parts of `~/.claude/` (CLAUDE.md, settings.json, user-level commands/skills/subagents, installed plugin manifests, marketplace clones). Timestamped snapshots under `~/.claude-backup/`; restore is dry-run by default and additive (never deletes new work). |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `block-dangerous.sh` | PreToolUse (Bash) | Block `rm -rf` outside project dir (direct and indirect via `bash -c`, `eval`). Uses `realpath` to resolve symlinks — a symlink inside the project pointing outside cannot bypass the guard. Project dir is read from hook JSON `cwd` (fallback: `pwd`). |
| `save-conv-before-commit.sh` | PreToolUse (Bash) | **Opt-in:** only enforced in repos that already have `conv-logs/` at their root. When active, blocks `git commit` unless a fresh (≤3 min) conversation log is staged. Projects without `conv-logs/` are unaffected. |

## Installation

Add this marketplace in Claude Code:

```
/install-marketplace https://github.com/tobyilee/toby-plugins
```

Then install individual plugins from it.

## License

MIT
