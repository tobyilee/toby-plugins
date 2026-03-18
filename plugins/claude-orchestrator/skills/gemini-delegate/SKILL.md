---
name: gemini-delegate
description: >
  Delegate tasks to Google Gemini CLI. Use when the user says
  "delegate to gemini", "send to gemini", "ask gemini to", "run with gemini",
  "have gemini do", "gemini에게", "gemini로", "제미나이에게", "제미나이로",
  "use gemini for", "let gemini handle", or wants to run a task using
  Gemini CLI in the background. Best for large-context analysis and
  code review tasks. Also use for second opinions or parallel execution.
version: 0.1.0
---

# Gemini Delegate

Delegate tasks to Google Gemini CLI and retrieve results.

## Prerequisites

Before executing, verify Gemini is available:
```bash
which gemini && gemini --version
```
If not installed, inform the user: `npm install -g @google/gemini-cli`

## Execution Flow

### 1. Read Configuration

Read `.claude/orchestrator.local.md` if it exists to get Gemini settings:
- `agents.gemini.default_model` (empty = CLI default, typically auto-gemini-3)
- `agents.gemini.sandbox` (true by default)
- `agents.gemini.yolo` (true = -y flag, required for non-interactive)
- `agents.gemini.timeout_ms` (300000 = 5min by default)

### 2. Compose the Task Prompt

Build a clear, self-contained prompt for Gemini. Include:
- Exact task description with enough background
- Target files or directories (use absolute paths)
- Constraints and expected output format
- Gemini excels at large-context analysis — provide full file paths for review

### 3. Determine Execution Mode

| Intent | Flags | Notes |
|--------|-------|-------|
| read / review / research | `-p -y -s -o text` | Sandbox + yolo |
| write / refactor | `-p -y -o text` | Yolo only (no sandbox) |

**IMPORTANT:** `-y` (yolo) is REQUIRED for non-interactive execution.
Without it, Gemini hangs waiting for tool approval.

### 4. Execute Gemini

Generate a unique result file and run:

```bash
RESULT_FILE="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p '<TASK_PROMPT>' \
  -y \
  --include-directories "<WORKING_DIRECTORY>" \
  -o text \
  > "$RESULT_FILE" 2>&1
echo "===GEMINI_RESULT_FILE:$RESULT_FILE==="
```

Use `run_in_background: true` on the Bash tool to run asynchronously.

For prompts with single quotes, use heredoc:
```bash
RESULT_FILE="/tmp/gemini-result-$(date +%s)-$RANDOM.md"
gemini -p "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" \
  -y \
  --include-directories "<WORKING_DIRECTORY>" \
  -o text \
  > "$RESULT_FILE" 2>&1
echo "===GEMINI_RESULT_FILE:$RESULT_FILE==="
```

### 5. Notify User

After launching, inform the user:
- Task delegated to Gemini
- Running in background
- They can continue other work

### 6. Retrieve Results

When background task completes:
1. Read the result file with the Read tool
2. If empty/missing, check Bash task output for errors
3. Present with provenance header:
   ```
   [Gemini, {model}, {duration}s]
   {result content}
   ```
4. If Gemini modified files, run `git diff` to show changes
5. Ask user if they want to keep, revert, or adjust

## Flag Reference

| Flag | Purpose |
|------|---------|
| `-p <text>` | Non-interactive mode (required) |
| `-y` / `--yolo` | Auto-approve all tool executions (required) |
| `-s` / `--sandbox` | Sandboxed execution |
| `-o text` | Plain text output (`-o json` for structured) |
| `--include-directories <dir>` | Additional workspace directories |
| `-m <model>` | Override model (optional) |
| `> "$FILE"` | Redirect stdout to file (Gemini has no -o file flag) |

## Error Handling

| Error | Action |
|-------|--------|
| `gemini: command not found` | Suggest: `npm install -g @google/gemini-cli` |
| Auth failure | Suggest: run `gemini` interactively to set up OAuth |
| Empty result | Check stderr output from background task |
| Timeout (>5min) | Report timeout, suggest narrowing scope |
| Hanging | Likely missing `-y` flag — always include it |

## Notes

- Gemini uses multi-model routing internally (router + main model)
- Token usage is split across internal models — aggregate for total
- `--allowed-tools` is DEPRECATED — use `-y` for full tool access
- Default model (`auto-gemini-3`) routes between flash-lite and flash-preview
