---
name: save-conversation
description: >
  Use this skill to save a summary of the current conversation to a markdown file.
  Trigger on "save conv", "save conversation", "대화 저장", "대화내용 저장",
  "대화 저장해줘", "대화내용 저장해줘", "conversation 저장", "로그 저장",
  "대화 기록 남겨", "save chat", "save log", "대화 정리해서 저장",
  "지금까지 대화 저장", "conv 저장".
  Also trigger when the user asks to log, archive, or record the current conversation,
  or wants a summary of what was discussed saved to a file.
  Do NOT trigger for memory saving (use memory system) or for git commit messages.
user-invocable: true
version: 0.1.0
---

# save-conversation

Save a concise summary of the current conversation to a markdown file in the `conv-logs/` directory.

The goal is to create a readable record of what Toby and Claude discussed and accomplished — not a verbatim transcript, but a structured summary that's useful for future reference.

## Workflow

**IMPORTANT:** Always resolve the project root via `git rev-parse --show-toplevel` and use that as the base for `conv-logs/`. Do NOT use the current working directory — it may be a subdirectory. If the caller is not inside a git repo at all, fall back to `pwd` so writes never escape into `/conv-logs/...`.

### Step 1: Create the output directory

Use the current date to create a hierarchical directory structure:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
YYYYMM=$(date +%Y%m)
DD=$(date +%d)
mkdir -p "${PROJECT_ROOT}/conv-logs/${YYYYMM}/${DD}"
```

### Step 2: Check for previous save in this session

Look for the most recent file across all subdirectories of `conv-logs/` under the project root. Use a `find -printf` (Linux) / `stat` (macOS) sort instead of `xargs ls -t` so filenames with spaces or newlines stay safe:

```bash
LATEST=""
LATEST_MTIME=0
while IFS= read -r -d '' f; do
  if [[ "$OSTYPE" == "darwin"* ]]; then m=$(stat -f %m "$f"); else m=$(stat -c %Y "$f"); fi
  if (( m > LATEST_MTIME )); then LATEST_MTIME=$m; LATEST="$f"; fi
done < <(find "${PROJECT_ROOT}/conv-logs" -name 'conv-*.md' -type f -print0 2>/dev/null)
echo "$LATEST"
```

If a previous save exists, read it to determine where the last save ended — the new save should only include conversation that happened after that point. Always start numbering from `## 1.` in each save file.

If no previous save exists, this is the first save of the session — include everything.

### Step 3: Generate the filename

Use the current timestamp:

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
YYYYMM=$(date +%Y%m)
DD=$(date +%d)
FILENAME="${PROJECT_ROOT}/conv-logs/${YYYYMM}/${DD}/conv-${TIMESTAMP}.md"
```

### Step 4: Write the conversation summary

Review the conversation history (only the part after the last save, or everything if first save) and write a markdown file with this structure:

```markdown
# Conversation Log — {YYYY-MM-DD HH:MM}

# 참여자
- Toby (사용자)
- Claude ({model name, e.g. Opus 4.6})

## 브랜치
- `{branch}` (or `main` if no feature branch)

---

## 1. {Topic Title}
사용: {comma-separated list of skills, tools, agents used in this exchange}

Toby: {One sentence summary of request}

Claude: {What was done — actions, key results. Use bullet list for multiple items:}
- item 1
- item 2

---

## 2. {Next Topic}
사용: {skills, tools, agents}

Toby: ...

Claude: ...

(Continue numbering for each distinct topic. Use `---` between sections.)

---

## 변경된 파일
- `path/to/new-file.md` (추가)
- `path/to/modified-file.json` (수정)
- `path/to/deleted-file.md` (삭제)
```

Before writing the file, run `git diff --name-status HEAD` (or compare against the commit at session start) to get the actual list of added/modified/deleted files. Use the status codes:
- A → (추가)
- M → (수정)
- D → (삭제)
- R → (이름변경)

If there are no uncommitted changes (everything was already committed and pushed), use `git diff --name-status {first_commit_of_session}..HEAD` to capture all changes made during the session. For incremental saves, only list files changed since the previous save.

Guidelines for writing the summary:
- Number each topic section sequentially (`## 1.`, `## 2.`, ...)
- Give each section a descriptive title that captures the topic
- `Toby:` lines capture the user's intent in one sentence (not verbatim)
- `Claude:` lines describe what was actually done — use bullet lists when there are multiple actions or results
- Do NOT use bold markup (`**`) on Toby/Claude names — keep them plain text
- Add a `사용:` line right after each section title listing skills, tools, and agents used (e.g., `사용: skill-creator, firecrawl, Bash, Explore agent`)
- Group related back-and-forth exchanges into a single section under one topic
- Include file paths, command names, surface refs, and version numbers — these are the details that matter
- Write in the same language as the conversation (Korean if Korean, English if English)
- Skip trivial confirmations ("ok", "yes") — only log meaningful exchanges
- For incremental saves: always start numbering from `## 1.` (do not continue from the previous file's numbering). Do not include a reference to the previous log file

### Step 5: Save prompt rewrites

Review the conversation for any Korean prompts that were rewritten into English (lines like `Your prompt rewritten: "..."`). If any exist, append them to a monthly prompt log file:

```bash
PROMPT_FILE="${PROJECT_ROOT}/conv-logs/${YYYYMM}/prompt-${YYYYMM}.md"
```

If the file does not exist, create it with a header:

```markdown
# Prompt Rewrites — {YYYY-MM}

| id | datetime | korean | english |
|----|----------|--------|---------|
```

Append each rewrite as a new row. Use an auto-incrementing `id` (continue from the last id in the file, or start at 1). The `datetime` is the approximate time of the exchange.

Example rows:

```markdown
| 1 | 2026-03-25 21:30 | .idea는 .gitignore에 포함해줘 | Add .idea to .gitignore. |
| 2 | 2026-03-25 21:32 | save-conversation skill에서 md 문서를 만든 뒤에 git add로 tracking까지 해주도록 변경해줘 | Modify the save-conversation skill so that after creating the markdown file, it also runs `git add` to track the file. |
```

If there are no Korean-to-English rewrites in the conversation (or the scope being saved), skip this step.

After writing, run `git add` on the prompt file:

```bash
git add "${PROMPT_FILE}"
```

### Step 6: Save and confirm

Write the conversation log file using the Write tool, then run `git add` to track it:

```bash
git add "${FILENAME}"
```

Then tell the user:
> "대화 내용을 저장했습니다: `conv-logs/{yyyymm}/{dd}/conv-{timestamp}.md`"

Show a brief preview (first 10-15 lines) so the user can verify the content looks right.
