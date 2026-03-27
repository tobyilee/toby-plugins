---
name: toby-gemini
description: >
  Use this skill to send a task to Gemini running in a cmux pane and get the result back
  as a file. Trigger on "toby gemini", "toby gemini에게", "toby gemini한테",
  "toby gemini로", "toby gemini에게 해줘", "toby gemini한테 시켜",
  "toby gemini로 보내", "toby gemini에게 물어봐".
  Only trigger when the user explicitly says "toby gemini" — the "toby" prefix is
  required to distinguish from gemini-delegate. Do NOT trigger on bare "gemini" mentions
  without the "toby" prefix. This skill communicates with a persistent Gemini pane
  in cmux (started by toby-team-starter) and collects the result via a file.
  Do NOT trigger for gemini-delegate (which launches a new gemini process in the background).
version: 0.1.0
---

# toby-gemini

Send a prompt to the Gemini pane in cmux and collect the result as a markdown file.

This skill works with a Gemini instance already running in a cmux pane (typically started by `toby-team-starter`). It sends the user's task as a prompt, asks Gemini to write the result to a file, then watches for that file and presents the result.

## Workflow

### Step 1: Find the Gemini pane

```bash
cmux tree --json
```

Parse the JSON to find a surface with `title` exactly `"Gemini"` in the selected workspace. If not found, tell the user:
> "Gemini pane을 찾을 수 없습니다. `toby-team-starter` 스킬로 먼저 Gemini pane을 시작하세요."

Save the Gemini surface ref (e.g., `surface:27`).

### Step 2: Prepare the result file path

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULT_DIR="$(pwd)/tobyteam"
RESULT_FILE="$RESULT_DIR/gemini-result-${TIMESTAMP}.md"
mkdir -p "$RESULT_DIR"
```

### Step 3: Compose and send the prompt

Build the prompt to send to Gemini. The prompt wraps the user's task with instructions to write the result to the specific file path.

```
[USER'S TASK HERE]

When you are done, write your complete response (including any code, explanation, or analysis) to this file:
${RESULT_FILE}

Write the file using the Write tool or by running: cat > "${RESULT_FILE}" << 'RESULT_EOF'
[your response here]
RESULT_EOF
```

Send the prompt text via `cmux send`, then send an Enter key to submit. Gemini's composer needs an explicit Enter press — `cmux send` inserts text but doesn't submit it.

```bash
cmux send --surface <gemini_surface_ref> "<prompt>"
cmux send-key --surface <gemini_surface_ref> enter
```

For prompts with special characters (quotes, backticks, `$`), escape them properly or use single quotes. For very long prompts, write to a temp file:

```bash
PROMPT_FILE=$(mktemp /tmp/gemini-prompt-XXXXXX.txt)
# Write prompt content to PROMPT_FILE
cmux send --surface <gemini_surface_ref> "$(cat "$PROMPT_FILE")"
cmux send-key --surface <gemini_surface_ref> enter
rm "$PROMPT_FILE"
```

### Step 4: Launch file watcher in background

Start a background process that polls for the result file. Use Bash with `run_in_background: true`:

```bash
# Poll every 3 seconds for up to 30 minutes (600 checks)
RESULT_FILE="<result_file_path>"
for i in $(seq 1 600); do
  if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
    echo "RESULT_READY: $RESULT_FILE"
    cat "$RESULT_FILE"
    exit 0
  fi
  sleep 3
done
echo "TIMEOUT: Gemini did not write result within 30 minutes"
exit 1
```

### Step 5: Notify the user and wait

Tell the user the prompt has been sent:
> "Gemini pane에 프롬프트를 전송했습니다. 결과 파일을 기다리고 있습니다: `tobyteam/gemini-result-{timestamp}.md`"

The background process will notify when the file appears. When the task notification arrives, read the result file and present it to the user.

### Step 6: Present the result

When the background watcher completes:

1. Read the result file
2. Present the content to the user with a header indicating the source:
   > **Gemini Result** (`tobyteam/gemini-result-{timestamp}.md`)
3. If the watcher timed out, inform the user and suggest checking the Gemini pane manually:
   > "Gemini가 30분 내에 결과를 작성하지 않았습니다. Gemini pane을 직접 확인해 주세요."

## Notes

- Send the prompt text with `cmux send`, then `cmux send-key enter` to submit. This two-step approach is necessary because `cmux send` inserts text into the composer but doesn't submit it.
- If the prompt contains quotes or special shell characters, escape them or use the temp file approach.
- The `tobyteam/` directory is created automatically if it doesn't exist.
- Result files accumulate in `tobyteam/` — the user can clean them up as needed.
