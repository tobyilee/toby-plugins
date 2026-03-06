---
name: gemini-delegate
description: >
  This skill should be used when the user asks to "delegate to gemini",
  "send to gemini", "ask gemini to", "run with gemini", "have gemini do",
  "gemini에게", "gemini로", "제미나이에게", "제미나이로", "use gemini for",
  "let gemini handle", or wants to run a task using Google Gemini CLI
  in the background and get results back. Also use this when the user
  wants a second opinion from another AI, wants to compare approaches,
  or mentions running tasks in parallel with external agents.
version: 0.2.0
---

# Gemini Delegate

Delegate tasks to Google Gemini CLI agent running in the background and retrieve results.

## Prerequisites

- Gemini CLI installed: `npm install -g @google/gemini-cli` (`gemini` binary available)
- Authentication completed: run `gemini` interactively to set up OAuth if needed

## Execution Flow

### 1. Compose the Task Prompt

Build a clear, self-contained prompt for Gemini. The prompt must work independently — Gemini has no access to this conversation's context. Include:
- Exact task description with enough background for a fresh agent
- Target files or directories (use absolute paths)
- Constraints, coding style, or preferences mentioned by the user
- Expected output format and success criteria

Wrap the prompt in single quotes to avoid shell interpolation issues. If the prompt contains single quotes, use a heredoc approach instead.

### 2. Launch Gemini in Background

Generate a unique result file path and execute Gemini using the Bash tool with `run_in_background: true`:

```bash
RESULT_FILE="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p '<TASK_PROMPT>' \
  -y \
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
| `-m <model>` | Override model (e.g., `-m gemini-3-flash`) |
| `-s` / `--sandbox` | Run in sandboxed mode for safer execution |
| `> "$RESULT_FILE"` | Redirect stdout to file (Gemini outputs to stdout, no file flag) |

### 3. Notify the User

After launching, inform the user:
- The task has been delegated to Gemini
- It is running in the background
- They can continue with other work in the meantime

### 4. Retrieve and Present Results

When the background task completes:

1. Read the result file using the Read tool
2. If the file is empty or missing, check the Bash task output for errors
3. Present a concise summary of what Gemini accomplished
4. If Gemini modified files, run `git diff` to show what changed
5. Ask the user if they want to keep, revert, or adjust the changes

## Configuration Overrides

Override Gemini model with `-m` flag:

```bash
gemini -p "task" -y -m gemini-3-flash-preview -o text
```

Available models: `gemini-3-flash-preview` (CLI default), `gemini-2.5-pro`, `gemini-2.5-flash`, etc.

## Error Handling

| Error | Action |
|-------|--------|
| Auth failure | Run `gemini` interactively to re-authenticate via OAuth |
| Empty output | Check stderr from background task output |
| Timeout | Gemini may still be running; check task status |
| Command not found | Run `npm install -g @google/gemini-cli` |

## Security Note

`-y` (yolo mode) allows Gemini to execute commands and modify files without approval. This is required for background execution. Use `-s` (sandbox mode) alongside `-y` for safer execution when the task doesn't need unrestricted system access.
