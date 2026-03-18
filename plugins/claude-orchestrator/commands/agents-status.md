---
name: agents-status
description: Show status of all configured orchestrator agents
---

# Agent Status

Show the current status of all configured AI agents.

## Instructions

1. Read `.claude/orchestrator.local.md` for agent configuration
2. Check each agent's availability:
   ```bash
   which codex && codex --version || echo "codex: NOT AVAILABLE"
   which gemini && gemini --version || echo "gemini: NOT AVAILABLE"
   which claude && claude --version || echo "claude: NOT AVAILABLE"
   ```
3. Display a concise status summary with routing info
