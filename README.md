# toby-plugins

Toby's personal Claude Code plugin marketplace.

## Plugins

### toby-essentials `v1.7.0`

Toby's personal toolkit: code analysis, TDD, Spring Boot init, Spring Boot 4 guide, PRD generation, AI delegation, cmux terminal control, and security hooks.

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

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `block-dangerous.sh` | PreToolUse (Bash) | Block `rm -rf` outside project dir (direct and indirect via `bash -c`, `eval`), path normalization for symlink bypass prevention |

---

### claude-orchestrator `v0.2.0`

Multi-Agent Orchestrator — delegate tasks to Codex CLI, Gemini CLI, and Claude subagent for parallel execution, auto-routing, DAG-based orchestration, and fallback.

#### Commands

| Command | Description |
|---------|-------------|
| `/doctor` | Diagnose agent availability, version, and configuration status |
| `/agents-status` | Show status table of all configured orchestrator agents |
| `/orchestrator-init` | Initialize `.claude/orchestrator.local.md` configuration with agent routing rules and fallback chains |
| `/review-parallel` | Run a parallel code review with multiple AI agents on a file, directory, or PR |

#### Skills

| Skill | Version | Description |
|-------|---------|-------------|
| `delegate` | 0.1.0 | Auto-route tasks to the optimal AI agent based on task type classification (large_context → Gemini, fast_generation → Codex, complex_reasoning → Claude) |
| `delegate-parallel` | 0.1.0 | Run multiple AI agents in parallel on read-only tasks — collect and compare results |
| `delegate-orchestrate` | 0.1.0 | Decompose complex tasks into a DAG, execute in waves with dependency injection (`{{task-N.result}}` placeholders) |
| `pipeline` | 0.1.0 | Chain agent outputs sequentially — Agent A output feeds Agent B input |
| `claude-subagent` | 0.1.0 | Delegate complex reasoning tasks to an isolated Claude Code session via `claude -p` |
| `codex-delegate` | 0.1.0 | Delegate tasks directly to OpenAI Codex CLI |
| `gemini-delegate` | 0.1.0 | Delegate tasks directly to Google Gemini CLI |
| `custom-agent-template` | 0.1.0 | Template for integrating new CLI tools as delegatable agents |

#### Agents

| Agent | Description |
|-------|-------------|
| `orchestrator-agent` | Autonomous multi-agent orchestration agent — decomposes complex multi-step tasks, routes subtasks to optimal agents, handles parallel execution and fallback |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `on-stop.js` | Stop | Auto-fallback to alternative agent on rate limit/API error; auto for read-only tasks, notification for write tasks |
| `post-edit-review.js` | PostToolUse (Edit/Write) | Configurable code review after file modifications — off/advisory/blocking modes with debouncing and high-risk directory detection |

## Installation

Add this marketplace in Claude Code:

```
/install-marketplace https://github.com/tobyilee/toby-plugins
```

Then install individual plugins from it.

## License

MIT
