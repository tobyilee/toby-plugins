---
name: toby-codex
description: >
  Use this skill to send a task to Codex running in a cmux pane and get the result back
  as a file. Trigger on "toby codex", "toby codex에게", "toby codex한테",
  "toby codex로", "toby codex에게 해줘", "toby codex한테 시켜",
  "toby codex로 보내", "toby codex에게 물어봐".
  Only trigger when the user explicitly says "toby codex" — the "toby" prefix is
  required to distinguish from codex-delegate. Do NOT trigger on bare "codex" mentions
  without the "toby" prefix. This skill communicates with a persistent Codex pane
  in cmux (started by toby-team-starter) and collects the result via a file.
  Do NOT trigger for codex-delegate (which launches a new codex process in the background).
version: 0.1.0
---

# toby-codex

Send a prompt to the Codex pane in cmux and collect the result as a markdown file.

This skill works with a Codex instance already running in a cmux pane (typically started by `toby-team-starter`). It sends the user's task as a prompt, asks Codex to write the result to a file, then watches for that file and presents the result.

## Workflow

### Step 1: Find the Codex pane

```bash
cmux tree --json
```

Parse the JSON to find a surface with `title` exactly `"Codex"` in the selected workspace. If not found, tell the user:
> "Codex pane을 찾을 수 없습니다. `toby-team-starter` 스킬로 먼저 Codex pane을 시작하세요."

Save the Codex surface ref (e.g., `surface:26`).

### Step 2: Prepare the result file path

Anchor the result directory to the git project root so results land in the same place regardless of the caller's `pwd`. Fall back to `pwd` only when the caller is outside any git repo.

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
RESULT_DIR="$PROJECT_ROOT/tobyteam"
RESULT_FILE="$RESULT_DIR/codex-result-${TIMESTAMP}.md"
mkdir -p "$RESULT_DIR"
```

### Step 3: Compose and send the prompt

Build the prompt with the user's task on top, then a single trailing instruction line that names the target file. Do not include literal heredoc fragments — Codex may copy them verbatim.

Prompt template (substitute `${RESULT_FILE}` before sending):

```
[USER'S TASK HERE]

When you finish, write your complete final response — code, explanation, and analysis — to the file at ${RESULT_FILE}. Use the Write tool. Do not include any meta-commentary about the writing process.
```

Send the prompt text via `cmux send`, then send an Enter key to submit. Codex's composer needs an explicit Enter press — `cmux send` inserts text but doesn't submit it.

For short single-line prompts:

```bash
cmux send --surface <codex_surface_ref> "<prompt>"
cmux send-key --surface <codex_surface_ref> enter
```

For multi-line prompts, write the prompt to a temp file and pipe it via stdin so newlines are preserved (using `"$(cat …)"` collapses internal newlines to spaces under default word-splitting):

```bash
PROMPT_FILE=$(mktemp /tmp/codex-prompt-XXXXXX.txt)
# write the rendered prompt to "$PROMPT_FILE" (e.g. via the Write tool)
cmux send --surface <codex_surface_ref> --stdin < "$PROMPT_FILE"
cmux send-key --surface <codex_surface_ref> enter
rm -f "$PROMPT_FILE"
```

If `--stdin` is unavailable in the installed cmux build, fall back to a single quoted argument with explicit `$'...'` ANSI-C quoting so newlines survive:

```bash
PROMPT=$(cat "$PROMPT_FILE")
cmux send --surface <codex_surface_ref> "$PROMPT"
cmux send-key --surface <codex_surface_ref> enter
```

(The double-quoted form preserves embedded newlines in argument value — the `$(cat …)` collapse only happens with unquoted command substitution. Keep the double quotes.)

### Step 4: Launch file watcher in background

Start a background process that polls for the result file. Use Bash with `run_in_background: true`. Timeout is configurable via `TOBY_CODEX_TIMEOUT_SEC` (default: 1800 seconds = 30 minutes):

```bash
RESULT_FILE="<result_file_path>"
TIMEOUT_SEC="${TOBY_CODEX_TIMEOUT_SEC:-1800}"
DEADLINE=$(( $(date +%s) + TIMEOUT_SEC ))
while [ "$(date +%s)" -lt "$DEADLINE" ]; do
  if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
    echo "RESULT_READY: $RESULT_FILE"
    cat "$RESULT_FILE"
    exit 0
  fi
  sleep 3
done
echo "TIMEOUT: Codex did not write result within ${TIMEOUT_SEC}s"
exit 1
```

### Step 5: Notify the user and wait

Tell the user the prompt has been sent:
> "Codex pane에 프롬프트를 전송했습니다. 결과 파일을 기다리고 있습니다: `tobyteam/codex-result-{timestamp}.md`"

The background process will notify when the file appears. When the task notification arrives, read the result file and present it to the user.

### Step 6: Present the result

When the background watcher completes:

1. Read the result file
2. Present the content to the user with a header indicating the source:
   > **Codex Result** (`tobyteam/codex-result-{timestamp}.md`)
3. If the watcher timed out, inform the user and suggest checking the Codex pane manually:
   > "Codex가 시간 내에 결과를 작성하지 않았습니다. Codex pane을 직접 확인해 주세요. (timeout: `TOBY_CODEX_TIMEOUT_SEC`)"

## Notes

- Send the prompt text with `cmux send`, then `cmux send-key enter` to submit. This two-step approach is necessary because `cmux send` inserts text into the composer but doesn't submit it.
- If the prompt contains quotes or special shell characters, escape them or use the temp file approach.
- The `tobyteam/` directory is created automatically if it doesn't exist.
- Result files accumulate in `tobyteam/` — the user can clean them up as needed.
