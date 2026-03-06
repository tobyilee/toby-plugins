# toby-essentials

Toby's personal Claude Code plugin toolkit: code analysis, TDD, Spring scaffolding, PRD generation, AI delegation, and security hooks.

## Components

### Commands

| Command | Description |
|---------|-------------|
| `/code-quality` | Evaluate code quality with parallel agents, score 9 dimensions, generate report |
| `/code-explore` | Deep codebase analysis with 5 parallel agents, generate comprehensive report |
| `/merge-permissions` | Merge local project permissions into global Claude settings |

### Skills

| Skill | Description |
|-------|-------------|
| `prd` | Generate structured Product Requirements Documents with user stories |
| `tdd-team` | 3-agent TDD team (Red/Green/Refactor) for test-driven development |
| `spring-initializr` | Scaffold Spring Boot projects using start.spring.io API |
| `codex-delegate` | Delegate tasks to OpenAI Codex CLI in the background |
| `gemini-delegate` | Delegate tasks to Google Gemini CLI in the background |

### Hooks

| Hook | Event | Description |
|------|-------|-------------|
| `block-dangerous.sh` | PreToolUse (Bash) | Block `rm -rf` outside project dir, `.env` file access |
| `block-env-read.sh` | PreToolUse (Read) | Block reading `.env` files (`.env.local` allowed) |

## Installation

Add to your Claude Code plugin configuration:

```json
{
  "plugins": [
    {
      "type": "git",
      "url": "https://github.com/tobyilee/toby-essentials"
    }
  ]
}
```

## License

MIT
