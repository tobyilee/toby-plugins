# Phase 1 E2E Validation Guide

## Prerequisites

1. Codex CLI installed: `which codex`
2. Gemini CLI installed: `which gemini`
3. Claude CLI available: `which claude`

## Test 1: Plugin Loading

```bash
# Load plugin and verify it appears in init event
claude -p --output-format json \
  --plugin-dir ./claude-orchestrator \
  --model haiku \
  --permission-mode dontAsk \
  --no-session-persistence \
  "List the available skills from the orchestrator plugin" 2>&1 | head -1 | python3 -c "
import json, sys
data = json.loads(sys.stdin.readline())
if data.get('type') == 'system':
    skills = [s for s in data.get('skills', []) if 'orchestrator' in s or 'delegate' in s or 'codex' in s or 'gemini' in s]
    print('Found skills:', skills)
"
```

Expected: Skills including `codex-delegate`, `gemini-delegate`, `delegate`

## Test 2: /doctor Command

```bash
claude -p --plugin-dir ./claude-orchestrator \
  --model haiku --permission-mode dontAsk \
  "/doctor"
```

Expected: Status table showing available agents

## Test 3: /orchestrator-init Command

```bash
# In a temp directory
mkdir -p /tmp/test-orch && cd /tmp/test-orch
claude -p --plugin-dir /path/to/claude-orchestrator \
  --model haiku --permission-mode dontAsk \
  "/orchestrator-init"
cat .claude/orchestrator.local.md
```

Expected: Config file created with YAML frontmatter

## Test 4: /codex-delegate Skill

```bash
claude -p --plugin-dir ./claude-orchestrator \
  --model haiku --permission-mode dontAsk \
  "codex에게 'echo hello world' 실행 결과를 확인해달라고 위임해줘"
```

Expected: Codex CLI invoked in background, result presented

## Test 5: /gemini-delegate Skill

```bash
claude -p --plugin-dir ./claude-orchestrator \
  --model haiku --permission-mode dontAsk \
  "gemini에게 이 프로젝트의 README 파일을 분석해달라고 위임해줘"
```

Expected: Gemini CLI invoked in background, result presented

## Test 6: /delegate Skill (auto-routing)

```bash
claude -p --plugin-dir ./claude-orchestrator \
  --model haiku --permission-mode dontAsk \
  "delegate: review the code quality of lib/config-loader.js"
```

Expected: Task classified as "review", routed to appropriate agent

## Validation Checklist

- [ ] Plugin loads successfully (appears in init event)
- [ ] /doctor shows agent status
- [ ] /orchestrator-init creates config file
- [ ] codex-delegate triggers Codex CLI
- [ ] gemini-delegate triggers Gemini CLI
- [ ] delegate auto-routes based on task type
