# toby-plugins

Toby's personal Claude Code plugin marketplace.

## Plugins

### toby-essentials

Code analysis, TDD, Spring Boot init, Spring Boot 4 guide, PRD generation, AI delegation, cmux terminal control, and security hooks.

#### Commands

| Command | Description |
|---------|-------------|
| `/code-quality` | Evaluate code quality with parallel agents, score 9 dimensions, generate report |
| `/code-explore` | Deep codebase analysis with 5 parallel agents, generate comprehensive report |
| `/merge-permissions` | Merge local project permissions into global Claude settings |

#### Skills

| Skill | Description |
|-------|-------------|
| `prd` | Generate structured Product Requirements Documents with user stories |
| `tdd-team` | 3-agent TDD team (Red/Green/Refactor) with task decomposition and progress tracking (v0.3.0) |
| `spring-boot-init` | Spring Initializr API를 활용한 Spring Boot 프로젝트 생성 — Gradle Kotlin DSL 기반, 인터랙티브 의존성 선택 |
| `codex-delegate` | Delegate tasks to OpenAI Codex CLI with context gathering and parallel delegation support (v0.3.0) |
| `gemini-delegate` | Delegate tasks to Google Gemini CLI with context gathering and parallel delegation support (v0.3.0) |
| `cmux` | Control the cmux terminal app from Claude Code — open browser panes, split panes, send notifications, manage workspaces |
| `spring-boot4-guide` | Guide for developing with Spring Boot 4 and Spring Framework 7 — migration, breaking changes, Jackson 3, modularization |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `block-dangerous.sh` | PreToolUse (Bash) | Block `rm -rf` outside project dir, `.env` file access |

### claude-orchestrator

Multi-Agent Orchestrator — delegate tasks to Codex CLI, Gemini CLI, and Claude subagent for parallel execution, auto-routing, and fallback.

#### Commands

| Command | Description |
|---------|-------------|
| `/agents-status` | Show status of all configured orchestrator agents |
| `/doctor` | Diagnose agent availability and configuration |
| `/orchestrator-init` | Initialize orchestrator configuration for the current project |
| `/review-parallel` | Run a parallel code review with multiple AI agents |

#### Skills

| Skill | Description |
|-------|-------------|
| `delegate` | Auto-route tasks to the optimal AI agent |
| `delegate-parallel` | Run multiple AI agents in parallel |
| `delegate-orchestrate` | Decompose complex tasks into multi-step workflows with dependency graph |
| `pipeline` | Chain agent outputs into other agent inputs for multi-step workflows |
| `codex-delegate` | Delegate tasks to OpenAI Codex CLI |
| `gemini-delegate` | Delegate tasks to Google Gemini CLI |
| `claude-subagent` | Delegate complex reasoning tasks to a separate Claude Code session |
| `custom-agent-template` | Template for creating custom agent delegation skills |

#### Agents

| Agent | Description |
|-------|-------------|
| `orchestrator-agent` | Autonomous multi-agent orchestration agent for complex multi-step task decomposition |

#### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `on-stop.js` | Stop | Post-stop processing |
| `post-edit-review.js` | PostToolUse (Edit/Write) | Review edits after file modifications |

## Installation

Add this marketplace in Claude Code:

```
/install-marketplace https://github.com/tobyilee/toby-plugins
```

Then install individual plugins from it.

## License

MIT
