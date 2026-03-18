---
name: codex-delegate
description: >
  Delegate tasks to OpenAI Codex CLI. Use when the user says
  "delegate to codex", "send to codex", "ask codex to", "run with codex",
  "have codex do", "codex에게", "codex로", "코덱스에게", "코덱스로",
  "use codex for", "let codex handle", or wants to run a task using
  Codex CLI in the background. Also use when the user wants a second
  opinion from another AI or mentions running tasks with external agents.
version: 0.1.0
---

# Codex Delegate

Delegate tasks to OpenAI Codex CLI and retrieve results.

## Prerequisites

Before executing, verify Codex is available:
```bash
which codex && codex --version
```
If not installed, inform the user: `npm install -g @openai/codex`

## Execution Flow

### 1. Read Configuration

Read `.claude/orchestrator.local.md` if it exists to get Codex settings:
- `agents.codex.default_model` (empty = CLI default)
- `agents.codex.sandbox` (workspace-write by default)
- `agents.codex.timeout_ms` (300000 = 5min by default)

### 2. Compose the Task Prompt

Build a clear, self-contained prompt for Codex. The prompt must work independently — Codex has no access to this conversation's context. Include:
- Exact task description with enough background
- Target files or directories (use absolute paths)
- Constraints, coding style, or preferences
- Expected output format

### 3. Determine Execution Mode

Based on the user's intent:

| Intent | Sandbox Mode | Flag |
|--------|-------------|------|
| read / review / research | workspace-write (safe) | `--full-auto` |
| write / refactor | workspace-write | `--full-auto` |
| dangerous operations | Only if user explicitly approves | `--full-auto` |

### 4. Execute Codex

Generate a unique result file and run:

```bash
RESULT_FILE="/tmp/codex-result-$(date +%s)-$RANDOM.md"
codex exec '<TASK_PROMPT>' \
  --full-auto \
  --ephemeral \
  --skip-git-repo-check \
  -C "<WORKING_DIRECTORY>" \
  -o "$RESULT_FILE" \
  2>&1
echo "===CODEX_RESULT_FILE:$RESULT_FILE==="
```

Use `run_in_background: true` on the Bash tool to run asynchronously.

For prompts with single quotes, use heredoc:
```bash
RESULT_FILE="/tmp/codex-result-$(date +%s)-$RANDOM.md"
codex exec "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" \
  --full-auto --ephemeral --skip-git-repo-check \
  -C "<WORKING_DIRECTORY>" \
  -o "$RESULT_FILE" \
  2>&1
echo "===CODEX_RESULT_FILE:$RESULT_FILE==="
```

### 5. Notify User

After launching, inform the user:
- Task delegated to Codex
- Running in background
- They can continue other work

### 6. Retrieve Results

When background task completes:
1. Read the result file with the Read tool
2. If empty/missing, check Bash task output for errors
3. Present with provenance header:
   ```
   [Codex, {model}, {duration}s]
   {result content}
   ```
4. If Codex modified files, run `git diff` to show changes
5. Ask user if they want to keep, revert, or adjust

## Flag Reference

| Flag | Purpose |
|------|---------|
| `--full-auto` | Sandboxed auto-execution (workspace-write sandbox) |
| `--ephemeral` | Don't persist Codex session files |
| `--skip-git-repo-check` | Allow running outside git repos |
| `-C <dir>` | Set working directory |
| `-o <file>` | Save final response to file |
| `-m <model>` | Override model (e.g., `-m o3`, `-m o4-mini`) |

## Error Handling

| Error | Action |
|-------|--------|
| `codex: command not found` | Suggest: `npm install -g @openai/codex` |
| Auth failure | Suggest: `codex login` |
| Empty result file | Check stderr output from background task |
| Timeout (>5min) | Report timeout, suggest breaking task into smaller parts |
| Non-zero exit code | Report stderr content to user |
