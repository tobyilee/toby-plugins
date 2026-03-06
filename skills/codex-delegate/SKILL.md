---
name: codex-delegate
description: >
  This skill should be used when the user asks to "delegate to codex",
  "send to codex", "ask codex to", "run with codex", "have codex do",
  "codex에게", "codex로", "코덱스에게", "코덱스로", "use codex for",
  "let codex handle", or wants to run a task using OpenAI Codex CLI
  in the background and get results back. Also use this when the user
  wants a second opinion from another AI, wants to compare approaches,
  or mentions running tasks in parallel with external agents.
version: 0.2.0
---

# Codex Delegate

Delegate tasks to OpenAI Codex CLI agent running in the background and retrieve results.

## Prerequisites

- Codex CLI installed: `npm install -g @openai/codex` (`codex` binary available)
- Authentication completed: run `codex login` if needed

## Execution Flow

### 1. Compose the Task Prompt

Build a clear, self-contained prompt for Codex. The prompt must work independently — Codex has no access to this conversation's context. Include:
- Exact task description with enough background for a fresh agent
- Target files or directories (use absolute paths)
- Constraints, coding style, or preferences mentioned by the user
- Expected output format and success criteria

Wrap the prompt in single quotes to avoid shell interpolation issues. If the prompt contains single quotes, use a heredoc approach instead.

### 2. Launch Codex in Background

Generate a unique result file path and execute Codex using the Bash tool with `run_in_background: true`:

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

For prompts containing single quotes, use a heredoc:

```bash
RESULT_FILE="/tmp/codex-result-$(date +%s)-$RANDOM.md"
codex exec "$(cat <<'PROMPT'
<TASK_PROMPT_WITH_QUOTES>
PROMPT
)" \
  --full-auto --ephemeral --skip-git-repo-check \
  -C "<WORKING_DIRECTORY>" \
  -o "$RESULT_FILE" \
  2>&1
echo "===CODEX_RESULT_FILE:$RESULT_FILE==="
```

### Flag Reference

| Flag | Purpose |
|------|---------|
| `--full-auto` | Sandboxed auto-execution — no approval prompts (workspace-write sandbox) |
| `--ephemeral` | Do not persist Codex session files to disk |
| `--skip-git-repo-check` | Allow running outside git repositories |
| `-C <dir>` | Set the working directory for the agent |
| `-o <file>` | Save Codex's final response to a file |
| `-m <model>` | Override model (e.g., `-m o3`, `-m o4-mini`) |
| `--add-dir <dir>` | Additional writable directories beyond the workspace |
| `--json` | Output events as JSONL to stdout (useful for structured parsing) |

### 3. Notify the User

After launching, inform the user:
- The task has been delegated to Codex
- It is running in the background
- They can continue with other work in the meantime

### 4. Retrieve and Present Results

When the background task completes:

1. Read the result file using the Read tool
2. If the file is empty or missing, check the Bash task output for errors
3. Present a concise summary of what Codex accomplished
4. If Codex modified files, run `git diff` to show what changed
5. Ask the user if they want to keep, revert, or adjust the changes

## Configuration Overrides

Override model or behavior with `-m` or `-c` flags:

```bash
codex exec "task" --full-auto --ephemeral -m o3
codex exec "task" --full-auto --ephemeral -c model_reasoning_effort="high"
```

## Error Handling

| Error | Action |
|-------|--------|
| Auth failure | Run `codex login` to re-authenticate |
| Empty output | Check stderr from background task output |
| Timeout | Codex may still be running; check task status |
| Command not found | Run `npm install -g @openai/codex` |

## Security Note

`--full-auto` uses a workspace-write sandbox — Codex can read anything but only write within the workspace directory. This is safer than `--dangerously-bypass-approvals-and-sandbox`. Use `--add-dir` if Codex needs to write outside the workspace.
