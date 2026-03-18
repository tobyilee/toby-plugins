---
name: pipeline
description: >
  Chain agent outputs into other agent inputs for multi-step workflows.
  Use when the user says "pipeline", "chain agents", "에이전트 체인",
  "파이프라인", "step by step with different agents",
  "first have X do Y then have Z do W", or wants sequential
  multi-agent processing where one agent's output feeds the next.
version: 0.1.0
---

# Agent Pipeline

Chain multiple agents sequentially: Agent A output → Agent B input.

## Step 1: Define Pipeline Steps

Parse the user's request into ordered steps. Each step has:
- **agent**: which agent to use (codex, gemini, claude)
- **prompt_template**: the prompt, with `{{prev_result}}` for previous output

Example pipeline for "Gemini analyzes code, then Claude writes docs":
1. Gemini: "Analyze the code structure in src/ and list all modules with their purposes"
2. Claude: "Based on this analysis: {{prev_result}}\n\nWrite API documentation"

## Step 2: Execute Sequentially

Run each step, passing the previous result into the next prompt:

```
prev_result = ""
for each step:
  prompt = step.prompt_template.replace("{{prev_result}}", prev_result)
  result = execute(step.agent, prompt)
  if result.error:
    STOP — report partial results
  prev_result = result.content
```

### Execution Commands

For Codex steps:
```bash
RESULT="/tmp/pipeline-step{N}-codex-$(date +%s).md"
codex exec "$(cat <<'PROMPT'
{prompt with prev_result substituted}
PROMPT
)" --full-auto --ephemeral --skip-git-repo-check -C "<DIR>" -o "$RESULT" 2>&1
```

For Gemini steps:
```bash
RESULT="/tmp/pipeline-step{N}-gemini-$(date +%s).md"
gemini -p "$(cat <<'PROMPT'
{prompt with prev_result substituted}
PROMPT
)" -y -o text > "$RESULT" 2>&1
```

For Claude steps:
```bash
RESULT="/tmp/pipeline-step{N}-claude-$(date +%s).md"
claude -p "{prompt}" --output-format json --model sonnet \
  --permission-mode dontAsk --disable-slash-commands \
  --no-session-persistence > "$RESULT" 2>&1
```

## Step 3: Present Results

Show the pipeline execution trace:

```
Pipeline Execution (2 steps)
─────────────────────────────
Step 1: [Gemini] → Code analysis
  Duration: 15s | Tokens: 2,400
  ✓ Completed

Step 2: [Claude] → Documentation
  Input: {{prev_result}} from Step 1
  Duration: 8s | Tokens: 1,200
  ✓ Completed

Final Result:
{final step's output}
```

## Limits

- Maximum pipeline depth: `budget.max_delegation_depth` (default: 2)
- On step failure: stop pipeline, report partial results
- Each step runs synchronously (no parallel within pipeline)
