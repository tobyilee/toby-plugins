# toby-plugins

Toby's personal Claude Code plugin marketplace.

## Plugins

### toby-essentials `v1.25.0`

Toby's personal toolkit: code analysis, TDD, Spring Boot init, Spring Boot 4 guide, PRD generation, AI delegation, cmux terminal control, multi-agent team (toby-codex, toby-gemini), and security hooks.

#### Commands

| Command | Description |
|---------|-------------|
| `/code-quality` | Evaluate code quality with 4 parallel agents, score 9 dimensions (readability, maintainability, testability, performance, security, etc.), generate markdown report |
| `/code-explore` | Deep codebase analysis with 5 parallel agents (structure, style, architecture, complexity, testing), generate comprehensive report |
| `/merge-permissions` | Merge local project `.claude/settings.local.json` permissions into global `~/.claude/settings.json` |

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `prd` | 1.0.0 | Generate structured Product Requirements Documents — gather context, ask clarifying questions, produce actionable specs with user stories |
| `tdd-team` | 0.3.0 | 3-agent TDD team (Red/Green/Refactor) with task decomposition, progress tracking (`[x]/[>]/[ ]`), and user checkpoints between cycles |
| `spring-boot-init` | — | Spring Initializr API를 활용한 Spring Boot 프로젝트 생성 — Gradle Kotlin DSL 기반, 인터랙티브 버전/의존성 선택 |
| `spring-boot4-guide` | 0.1.0 | Spring Boot 4 / Spring Framework 7 개발 가이드 — migration, breaking changes, Jackson 3, Jakarta EE 11, modularization |
| `codex-delegate` | 0.3.0 | Delegate tasks to OpenAI Codex CLI — background execution, context gathering, parallel delegation support |
| `gemini-delegate` | 0.3.0 | Delegate tasks to Google Gemini CLI — background execution, context gathering, parallel delegation support |
| `cmux` | 0.1.0 | Control the cmux terminal app — open browser panes, split panes, send notifications, manage workspaces, sidebar status/progress |
| `toby-team-starter` | 0.1.0 | Spawn Codex (`--full-auto`) and Gemini (`--yolo`) in cmux panes alongside Claude — duplicate detection via pane title labeling |
| `toby-codex` | 0.1.0 | Send a task to the Codex cmux pane and collect the result as a file in `tobyteam/` — requires "toby codex" prefix |
| `toby-gemini` | 0.1.0 | Send a task to the Gemini cmux pane and collect the result as a file in `tobyteam/` — requires "toby gemini" prefix |
| `save-conversation` | — | Save a summary of the current conversation to a markdown file, with Korean→English prompt rewrites logged to monthly `prompt-{yyyymm}.md` — trigger with "save conv", "대화 저장", etc. |
| `omc-tips` | 0.2.0 | oh-my-claudecode (OMC) comprehensive quick-reference — mode selection, magic keywords, 19 agents (3-tier), 37 skills, hooks, MCP tools, and practical examples |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `block-dangerous.sh` | PreToolUse (Bash) | Block `rm -rf` outside project dir (direct and indirect via `bash -c`, `eval`), path normalization for symlink bypass prevention |
| `save-conv-before-commit.sh` | PreToolUse (Bash) | Ensure conversation log is saved before git commit — blocks commit if no recent conversation log exists or is not staged |

## Installation

Add this marketplace in Claude Code:

```
/install-marketplace https://github.com/tobyilee/toby-plugins
```

Then install individual plugins from it.

## License

MIT
