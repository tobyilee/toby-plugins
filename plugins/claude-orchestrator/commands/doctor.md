---
name: doctor
description: Diagnose agent availability and configuration for the orchestrator plugin
---

# Orchestrator Doctor

Check the status of all configured AI agents.

## Instructions

Run these diagnostic checks and present results:

### 1. Check CLI Availability

```bash
echo "=== Codex CLI ==="
which codex && codex --version || echo "NOT INSTALLED"
echo ""
echo "=== Gemini CLI ==="
which gemini && gemini --version || echo "NOT INSTALLED"
echo ""
echo "=== Claude CLI ==="
which claude && claude --version || echo "NOT INSTALLED"
```

### 2. Check Configuration

Read `.claude/orchestrator.local.md` and report:
- Which agents are enabled/disabled
- Routing rules
- Fallback chain

### 3. Present Results

Format as a status table:

```
Orchestrator Agent Status
─────────────────────────
✓ codex:          installed (v{version})
✓ gemini:         installed (v{version})
✓ claude:         installed (v{version})
✗ {agent}:        NOT INSTALLED — run {install_command}

Configuration: .claude/orchestrator.local.md
  Routing default: {default_agent}
  Fallback chain:  {chain}
  Post-edit review: {enabled/disabled}
```

### 4. Suggest Fixes

For any issues found, suggest specific fix commands:
- Missing codex: `npm install -g @openai/codex && codex login`
- Missing gemini: `npm install -g @google/gemini-cli && gemini`
- Missing config: suggest running `/orchestrator-init`
