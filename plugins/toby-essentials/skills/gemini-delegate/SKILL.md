---
name: gemini-delegate
description: >
  Use this skill to delegate tasks to Google Gemini CLI running in the background.
  Trigger on "delegate to gemini", "send to gemini", "ask gemini to", "run with gemini",
  "have gemini do", "gemini에게", "gemini로", "제미나이에게", "제미나이로",
  "use gemini for", "let gemini handle", "gemini한테 시켜", "gemini로 돌려봐".
  Also trigger when the user wants a second opinion from another AI specifically
  mentioning Gemini or Google, wants to compare Claude's approach with Gemini,
  or asks to run a task with an external Google agent in parallel.
  Do NOT trigger for general "delegate" or "외부 AI" requests without mentioning
  Gemini/Google — those may be better handled by codex-delegate or other tools.
version: 0.3.0
---

# Gemini Delegate

Delegate tasks to Google Gemini CLI agent running in the background and retrieve results.

## Prerequisites

- Gemini CLI installed: `npm install -g @google/gemini-cli` (`gemini` binary available)
- Authentication completed: run `gemini` interactively to set up OAuth if needed

## Execution Flow

### 1. Compose the Task Prompt

Build a clear, self-contained prompt for Gemini. The prompt must work independently — Gemini has no access to this conversation's context.

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

### 2. Launch Gemini in Background

Generate a unique result file path and execute Gemini using the Bash tool with `run_in_background: true`:

```bash
RESULT_FILE="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p '<TASK_PROMPT>' \
  -y \
  --model gemini-3.1-pro-preview \
  --include-directories "<WORKING_DIRECTORY>" \
  -o text \
  > "$RESULT_FILE" 2>&1
echo "===GEMINI_RESULT_FILE:$RESULT_FILE==="
```

For prompts containing single quotes, use a heredoc:

```bash
RESULT_FILE="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p "$(cat <<'PROMPT'
<TASK_PROMPT_WITH_QUOTES>
PROMPT
)" \
  -y \
  --model gemini-3.1-pro-preview \
  --include-directories "<WORKING_DIRECTORY>" \
  -o text \
  > "$RESULT_FILE" 2>&1
echo "===GEMINI_RESULT_FILE:$RESULT_FILE==="
```

### Flag Reference

| Flag | Purpose |
|------|---------|
| `-p <text>` | Non-interactive/headless mode (required for background execution) |
| `-y` / `--yolo` | Auto-approve all tool executions without prompting |
| `--approval-mode yolo` | Equivalent to `-y` (also accepts `auto_edit`, `plan`) |
| `-o text` | Plain text output (`-o json` for structured output with metadata) |
| `--include-directories <dir>` | Additional directories to include in the workspace |
| `-m <model>` | Override model (optional, uses CLI default if omitted) |
| `-s` / `--sandbox` | Run in sandboxed mode for safer execution |
| `> "$RESULT_FILE"` | Redirect stdout to file (Gemini outputs to stdout, no file flag) |

### 3. Notify the User

After launching, inform the user:
- The task has been delegated to Gemini
- It is running in the background
- They can continue with other work in the meantime

### 4. Check Progress (if needed)

If the task is taking long or the user asks for status, check the background task:

```bash
# Check if the process is still running
TaskOutput(task_id="<task_id>", block=false)

# Peek at partial output
tail -20 /tmp/gemini-result-*.md 2>/dev/null
```

If the task appears stuck (no output for extended time), inform the user and offer to cancel and retry.

### 5. Retrieve and Present Results

When the background task completes:

1. Read the result file using the Read tool
2. If the file is empty or missing, check the Bash task output for errors
3. Present a concise summary of what Gemini accomplished
4. If Gemini modified files, run `git diff` to show what changed
5. Ask the user if they want to keep, revert, or adjust the changes

## Parallel Delegation

When the user wants to compare approaches or get a second opinion, send the same task to both Gemini and Codex simultaneously. Launch both with `run_in_background: true` in the same turn:

```bash
# Launch Gemini
GEMINI_RESULT="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p '<TASK>' -y --model gemini-3.1-pro-preview -o text > "$GEMINI_RESULT" 2>&1

# Launch Codex (in a separate Bash call, same turn)
CODEX_RESULT="/tmp/codex-result-$(date +%s)-$RANDOM.md"
codex exec '<TASK>' --full-auto --ephemeral -C "<DIR>" -o "$CODEX_RESULT" 2>&1
```

When both complete, present a side-by-side comparison highlighting differences in approach, code style, and correctness.

## Configuration Overrides

By default, use `--model gemini-3.1-pro-preview`. Override only when the user explicitly requests a different model:

```bash
# Default
gemini -p "task" -y --model gemini-3.1-pro-preview -o text

# Override with specific model
gemini -p "task" -y --model gemini-2.5-pro -o text
```

## Error Handling

| Error | Action |
|-------|--------|
| Auth failure | Run `gemini` interactively to re-authenticate via OAuth |
| Empty output | Check stderr from background task output |
| Timeout | Check task status with `TaskOutput(block=false)`; offer to cancel and retry |
| Command not found | Run `npm install -g @google/gemini-cli` |
| Process stuck | No new output for >2min — inform user, offer cancel |

## Security Note

`-y` (yolo mode) allows Gemini to execute commands and modify files without approval. This is required for background execution. Use `-s` (sandbox mode) alongside `-y` for safer execution when the task doesn't need unrestricted system access.
