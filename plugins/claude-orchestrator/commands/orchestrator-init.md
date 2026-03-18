---
name: orchestrator-init
description: Initialize orchestrator configuration for the current project
---

# Initialize Orchestrator Configuration

Create the `.claude/orchestrator.local.md` configuration file.

## Instructions

1. Check if `.claude/orchestrator.local.md` already exists
2. If it exists, ask the user if they want to overwrite
3. If not, create it with the default configuration template

### Default Config Template

Write the following to `.claude/orchestrator.local.md`:

```yaml
---
agents:
  codex:
    enabled: true
    binary: codex
    default_model: ""
    sandbox: "workspace-write"
    timeout_ms: 300000
    max_concurrent: 3
  gemini:
    enabled: true
    binary: gemini
    default_model: ""
    sandbox: true
    yolo: true
    timeout_ms: 300000
    max_concurrent: 2
  claude_subagent:
    enabled: true
    default_model: sonnet
    permission_mode: dontAsk
    disable_skills: true
    no_session_persistence: true
    max_budget_usd: 1.00

routing:
  large_context: gemini
  fast_generation: codex
  complex_reasoning: claude_subagent
  simple_edit: codex
  review: gemini
  default: claude_subagent

fallback_chain:
  - claude_subagent
  - codex
  - gemini

budget:
  max_concurrent_agents: 5
  max_delegation_depth: 2
---

## Orchestrator Configuration

Edit the YAML above to customize agent settings and routing rules.
```

### After Creation

Print next steps:
1. Edit the config to match your environment
2. Run `/doctor` to verify agent availability
3. Try `/delegate "your task"` to auto-route a task
