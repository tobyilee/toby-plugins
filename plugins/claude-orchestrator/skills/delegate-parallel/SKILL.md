---
name: delegate-parallel
description: >
  Run multiple AI agents in parallel. Use when the user says
  "parallel delegate", "병렬로 위임", "여러 에이전트에게 동시에",
  "run agents in parallel", "get multiple perspectives",
  "다양한 관점에서", "동시에 실행", "compare agents",
  or wants to run the same or different tasks on multiple agents
  simultaneously. Best for read-only tasks like review, analysis, research.
version: 0.1.0
---

# Parallel Delegate

Run multiple AI agents simultaneously and collect results.

**IMPORTANT:** Only use for **read-only** tasks (review, research, analysis).
Do NOT run write/refactor tasks in parallel — file conflicts are possible.

## Step 1: Plan Parallel Tasks

Analyze the user's request and decompose into parallel subtasks.
Each subtask gets a label and target agent:

Example decomposition for "review this PR from multiple perspectives":
- `codex-review`: Codex → code style, bugs, patterns
- `gemini-review`: Gemini → architecture, full-context analysis

## Step 2: Check Agent Availability

```bash
which codex >/dev/null 2>&1 && echo "codex:ok" || echo "codex:missing"
which gemini >/dev/null 2>&1 && echo "gemini:ok" || echo "gemini:missing"
```

Skip unavailable agents.

## Step 3: Execute in Parallel

Run all agents simultaneously using background processes:

```bash
# Create temp directory for results
RESULT_DIR="/tmp/parallel-$(date +%s)"
mkdir -p "$RESULT_DIR"

# Launch Codex in background
codex exec "$(cat <<'PROMPT1'
<CODEX_TASK_PROMPT>
PROMPT1
)" --full-auto --ephemeral --skip-git-repo-check \
  -C "<WORKING_DIR>" \
  -o "$RESULT_DIR/codex-result.md" \
  > "$RESULT_DIR/codex-stdout.log" 2>&1 &
PID_CODEX=$!

# Launch Gemini in background
gemini -p "$(cat <<'PROMPT2'
<GEMINI_TASK_PROMPT>
PROMPT2
)" -y \
  --include-directories "<WORKING_DIR>" \
  -o text \
  > "$RESULT_DIR/gemini-result.md" 2>&1 &
PID_GEMINI=$!

# Wait for all to complete
echo "Waiting for agents: codex=$PID_CODEX gemini=$PID_GEMINI"
wait $PID_CODEX
CODEX_EXIT=$?
wait $PID_GEMINI
GEMINI_EXIT=$?

echo "=== Results ==="
echo "codex: exit=$CODEX_EXIT"
echo "gemini: exit=$GEMINI_EXIT"
echo "RESULT_DIR=$RESULT_DIR"
```

**IMPORTANT:** Use `run_in_background: true` on the Bash tool for this entire block.

## Step 4: Collect and Present Results

After the background task completes:

1. Read each result file from the result directory
2. Present results with per-agent provenance headers:

```
=== Parallel Delegation Results ===

[Codex Review]
{codex result content}

[Gemini Review]
{gemini result content}

=== Summary ===
- Codex: {status}, {duration}
- Gemini: {status}, {duration}
```

## Step 5: Handle Failures (best-effort)

Default strategy is **best-effort** — return successful results even if some agents fail:

- If one agent fails, still present results from successful agents
- Report which agents failed and why (exit code, stderr)
- For **fail-fast** (if user requests): abort remaining agents on first failure

## Notes

- Maximum concurrent agents: check `budget.max_concurrent_agents` in config (default: 5)
- Each agent's stdout/stderr is isolated in separate files
- Result files persist in `/tmp/parallel-*` for debugging
- For 3+ agents, consider staggering launches by 1-2 seconds to avoid rate limits
