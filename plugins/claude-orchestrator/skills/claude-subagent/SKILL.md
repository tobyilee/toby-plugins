---
name: claude-subagent
description: >
  Delegate complex reasoning tasks to a separate Claude Code session.
  Use when the user says "claude subagent", "서브에이전트", "separate claude",
  "another claude session", "complex reasoning task", "deep analysis",
  or needs a fresh Claude session for isolated work. Best for tasks
  requiring full Claude Code tool access with isolation.
version: 0.1.0
---

# Claude Subagent

Delegate tasks to a separate Claude Code session via `claude -p`.

## When to Use

- Complex reasoning requiring fresh context (no prompt pollution)
- Isolated execution in a separate session
- Tasks needing full Claude Code tool access (Read, Edit, Bash, Glob, Grep)
- When you want cost control via `--max-budget-usd`

## Step 1: Read Configuration

Check `.claude/orchestrator.local.md` for subagent settings:
- `claude_subagent.default_model` (default: sonnet)
- `claude_subagent.permission_mode` (default: dontAsk)
- `claude_subagent.max_budget_usd` (default: 1.00)

## Step 2: Build Command

```bash
RESULT_FILE="/tmp/claude-subagent-$(date +%s)-$RANDOM.md"
claude -p "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" \
  --output-format json \
  --model sonnet \
  --permission-mode dontAsk \
  --disable-slash-commands \
  --no-session-persistence \
  --max-budget-usd 1.00 \
  > "$RESULT_FILE" 2>&1
echo "===CLAUDE_RESULT_FILE:$RESULT_FILE==="
```

Use `run_in_background: true` on the Bash tool.

### Optional Flags

| Need | Flag |
|------|------|
| Limit tools | `--allowedTools "Read Glob Grep Bash"` |
| Block tools | `--disallowedTools "Edit Write"` |
| Higher effort | `--effort high` |
| Auto fallback | `--fallback-model haiku` |
| Specific model | `--model opus` |
| Cost limit | `--max-budget-usd 2.00` |
| Extra dirs | `--add-dir /path/to/other/project` |

## Step 3: Notify User

Inform the user:
- Task delegated to a separate Claude session
- Model: {model}
- Budget limit: ${max_budget_usd}
- Running in background

## Step 4: Parse Results

The output is JSONL. Parse the last line (result event):

```javascript
// Each line is a JSON event
// Find the "result" event:
// {"type":"result","subtype":"success","result":"...","total_cost_usd":0.05,...}
```

Present to user:
```
[Claude Subagent, {model}, {duration}s, ${cost}]
{result text}
```

## Step 5: Handle Errors

| Error | Action |
|-------|--------|
| Budget exceeded | Report partial result if available |
| Timeout | Report what was completed |
| Model overload | Retry with `--fallback-model haiku` |
| Permission denied | Check `--permission-mode` setting |

## Notes

- Claude subagent startup takes 10-30s due to session initialization
- Use `--disable-slash-commands` to avoid loading plugins (faster)
- Use `--no-session-persistence` for throwaway sessions
- Session can be resumed later with `--resume {session_id}` from result
- `--fallback-model` provides built-in overload handling
