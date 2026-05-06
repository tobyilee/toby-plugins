# toby-plugins

Toby's personal Claude Code plugin marketplace.

> **v2.0.0 (2026-05-06)** — The single `toby-essentials` plugin has been split into 5 focused plugins. See [CHANGELOG.md](CHANGELOG.md) for migration notes.

## Plugins

| Plugin | Version | What it's for |
|---|---|---|
| [`toby-multi-agent`](#toby-multi-agent) | `1.0.0` | Delegate to Codex/Gemini, or run them as a persistent team in cmux |
| [`toby-session`](#toby-session) | `1.0.0` | Session handoff/catchup, conversation logging |
| [`toby-claude-config`](#toby-claude-config) | `1.0.0` | Backup/restore `~/.claude`, permissions merge, security hooks |
| [`toby-codereview`](#toby-codereview) | `1.0.0` | `/code-quality`, `/code-explore`, PRD generation |
| [`toby-personal`](#toby-personal) | `1.0.0` | Toby-specific: Facebook style, Spring Boot, OMC tips, harness |

---

### toby-multi-agent

Multi-agent workspace. Delegate tasks to OpenAI Codex or Google Gemini, or spawn a persistent team in cmux panes alongside Claude. Default model versions live in [`plugins/toby-multi-agent/MODELS.md`](plugins/toby-multi-agent/MODELS.md).

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `codex-delegate` | 0.3.0 | Delegate tasks to OpenAI Codex CLI — background execution, context gathering, parallel delegation support |
| `gemini-delegate` | 0.3.0 | Delegate tasks to Google Gemini CLI — background execution, context gathering, parallel delegation support |
| `cmux` | 0.2.0 | Control the cmux terminal app — window/workspace/pane/surface management, browser automation, SSH, hooks integration |
| `toby-team-starter` | 0.1.0 | Spawn Codex (`--full-auto`) and Gemini (`--yolo`) in cmux panes alongside Claude |
| `toby-codex` | 0.1.0 | Send a task to the Codex cmux pane and collect the result as a file in `tobyteam/` — requires "toby codex" prefix |
| `toby-gemini` | 0.1.0 | Send a task to the Gemini cmux pane and collect the result as a file in `tobyteam/` — requires "toby gemini" prefix |
| `tdd-team` | 0.3.0 | 3-agent TDD team (Red/Green/Refactor) with task decomposition, progress tracking, user checkpoints |

---

### toby-session

Session lifecycle — handoff at end, catchup at start, conversation logs in between.

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `handoff` | 0.1.0 | Write a forward-looking handoff under `.claude/reports/handoff/handoff-<timestamp>.md` before ending a session — Summary, Decisions, Traps, line-numbered file refs, status-form Open Work, ~2K token budget |
| `catchup` | 0.1.0 | Resume from the latest handoff — Read-verifies every referenced file, cross-checks `git status` / `git log`, reports ✅Confirmed / ⚠️Shifted / ❌Missing, then **stops** for instruction |
| `save-conversation` | — | Save a conversation summary to markdown, with Korean→English prompt rewrites logged to monthly `prompt-{yyyymm}.md` |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `save-conv-before-commit.sh` | PreToolUse (Bash) | **Opt-in:** only enforced in repos that already have `conv-logs/` at their root. Blocks `git commit` unless a fresh conversation log is staged |

---

### toby-claude-config

Manage and protect your global `~/.claude` configuration.

#### Commands

| Command | Description |
|---------|-------------|
| `/claude-backup` | Create a timestamped backup of `~/.claude/` under `~/.claude-backup/claude-<YYYYMMDD-HHMMSS>/` |
| `/claude-backup-list` | List existing `~/.claude-backup/` snapshots, newest first, with size + timestamp |
| `/claude-restore` | Restore from a snapshot. Dry-run by default; `--apply` to overwrite, `--backup PATH` to target a specific snapshot |
| `/merge-permissions` | Merge local project `.claude/settings.local.json` permissions into global `~/.claude/settings.json` |

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `claude-backup` | 0.1.0 | Back up and restore the user-authored parts of `~/.claude/`. Snapshots under `~/.claude-backup/` (sibling of `~/.claude/`, survives reinstall). Restore is dry-run by default and additive |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `block-dangerous.sh` | PreToolUse (Bash) | Block `rm -rf` outside project dir (direct and indirect via `bash -c`, `eval`). Uses `realpath` to resolve symlinks |

---

### toby-codereview

Parallel-agent code analysis and product spec writing.

#### Commands

| Command | Description |
|---------|-------------|
| `/code-quality` | Evaluate code quality with 4 parallel agents, score 9 dimensions (readability, maintainability, testability, performance, security, …), generate markdown report |
| `/code-explore` | Deep codebase analysis with 5 parallel agents (structure, style, architecture, complexity, testing), generate comprehensive report |

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `prd` | 0.2.0 | Generate structured Product Requirements Documents — gather context, ask clarifying questions, produce actionable specs with user stories |

---

### toby-personal

Highly opinionated, Toby-specific. Install only if these match your workflow.

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `toby-facebook-style` | 0.1.0 | Draft social posts in Toby's Facebook voice — 반말 평서체, 한영 혼용, 4-pattern frame, distilled from 3,757 posts (2010–2026) |
| `omc-tips` | 0.2.0 | oh-my-claudecode (OMC) comprehensive quick-reference — mode selection, magic keywords, agents, skills, hooks, MCP tools |
| `use-harness` | 0.1.0 | Quick-start menu for pre-built harness use cases — 8 templates across 4 categories, launches via `harness:harness` |
| `spring-boot-init` | 0.1.0 | Spring Initializr API를 활용한 Spring Boot 프로젝트 생성 — Gradle Kotlin DSL 기반, 인터랙티브 버전/의존성 선택 |
| `spring-boot4-guide` | 0.1.0 | Spring Boot 4 / Spring Framework 7 개발 가이드 — migration, breaking changes, Jackson 3, Jakarta EE 11 |

---

## Templates

[`templates/_skill-template/`](templates/_skill-template) — boilerplate for creating new skills consistently across plugins. Copy, rename, edit frontmatter.

## Installation

Add this marketplace in Claude Code:

```
/install-marketplace https://github.com/tobyilee/toby-plugins
```

Then install the individual plugins you need.

## License

MIT
