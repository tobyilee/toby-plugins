---
name: codex-delegate
description: >
  Use this skill to delegate tasks to OpenAI Codex CLI running in the background.
  Trigger on "delegate to codex", "send to codex", "ask codex to", "run with codex",
  "have codex do", "codex에게", "codex로", "코덱스에게", "코덱스로", "use codex for",
  "let codex handle", "codex한테 시켜", "codex로 돌려봐".
  Also trigger when the user wants a second opinion from another AI specifically
  mentioning Codex or OpenAI, wants to compare Claude's approach with Codex,
  or asks to run a task with an external OpenAI agent in parallel.
  Do NOT trigger for general "delegate" or "외부 AI" requests without mentioning
  Codex/OpenAI — those may be better handled by gemini-delegate or other tools.
version: 0.3.0
---

# Codex Delegate

Delegate tasks to OpenAI Codex CLI agent running in the background and retrieve results.

## Prerequisites

- Codex CLI installed: `npm install -g @openai/codex` (`codex` binary available)
- Authentication completed: run `codex login` if needed

## Execution Flow

### 1. Compose the Task Prompt

Build a clear, self-contained prompt for Codex. The prompt must work independently — Codex has no access to this conversation's context.

**Gather context first.** Before composing the prompt, collect relevant information to include:

```
# Context to gather:
- Relevant source files (read key files and include snippets in the prompt)
- Recent git changes: git diff HEAD~3 --stat (if relevant)
- Project structure: a brief tree or file listing
- Build/test commands the agent should use
- Error messages or logs (if debugging)
```

**Compose the prompt** with this structure:
- Task description with enough background for a fresh agent
- Target files or directories (use absolute paths)
- Relevant code context (key file contents or snippets — include enough so the agent doesn't need to explore)
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
  -m gpt-5.4 \
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
  -m gpt-5.4 \
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

### 4. Check Progress (if needed)

If the task is taking long or the user asks for status, check the background task:

```bash
# Check if the process is still running
TaskOutput(task_id="<task_id>", block=false)

# Peek at partial output
tail -20 /tmp/codex-result-*.md 2>/dev/null
```

If the task appears stuck (no output for extended time), inform the user and offer to cancel and retry.

### 5. Retrieve and Present Results

When the background task completes:

1. Read the result file using the Read tool
2. If the file is empty or missing, check the Bash task output for errors
3. Present a concise summary of what Codex accomplished
4. If Codex modified files, run `git diff` to show what changed
5. Ask the user if they want to keep, revert, or adjust the changes

## Parallel Delegation

When the user wants to compare approaches or get a second opinion, send the same task to both Codex and Gemini simultaneously. Launch both with `run_in_background: true` in the same turn:

```bash
# Launch Codex
CODEX_RESULT="/tmp/codex-result-$(date +%s)-$RANDOM.md"
codex exec '<TASK>' --full-auto --ephemeral -m gpt-5.4 -C "<DIR>" -o "$CODEX_RESULT" 2>&1

# Launch Gemini (in a separate Bash call, same turn)
GEMINI_RESULT="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p '<TASK>' -y -o text > "$GEMINI_RESULT" 2>&1
```

When both complete, present a side-by-side comparison highlighting differences in approach, code style, and correctness.

## Configuration Overrides

Override model or behavior with `-m` or `-c` flags:

```bash
codex exec "task" --full-auto --ephemeral -m gpt-5.4
codex exec "task" --full-auto --ephemeral -m gpt-5.4 -c model_reasoning_effort="high"
```

## Error Handling

| Error | Action |
|-------|--------|
| Auth failure | Run `codex login` to re-authenticate |
| Empty output | Check stderr from background task output |
| Timeout | Check task status with `TaskOutput(block=false)`; offer to cancel and retry |
| Command not found | Run `npm install -g @openai/codex` |
| Process stuck | No new output for >2min — inform user, offer cancel |

## Security Note

`--full-auto` uses a workspace-write sandbox — Codex can read anything but only write within the workspace directory. This is safer than `--dangerously-bypass-approvals-and-sandbox`. Use `--add-dir` if Codex needs to write outside the workspace.
