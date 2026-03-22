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
version: 0.1.0
---

# save-conversation

Save a concise summary of the current conversation to a markdown file in the `claudelogs/` directory.

The goal is to create a readable record of what Toby and Claude discussed and accomplished — not a verbatim transcript, but a structured summary that's useful for future reference.

## Workflow

### Step 1: Create the output directory

```bash
mkdir -p claudelogs
```

### Step 2: Generate the filename

Use the current timestamp:

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILENAME="claudelogs/conv-${TIMESTAMP}.md"
```

### Step 3: Write the conversation summary

Review the entire conversation history and write a markdown file with this structure:

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

If there are no uncommitted changes (everything was already committed and pushed), use `git diff --name-status {first_commit_of_session}..HEAD` to capture all changes made during the session.

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

### Step 4: Save and confirm

Write the file using the Write tool, then tell the user:
> "대화 내용을 저장했습니다: `claudelogs/conv-{timestamp}.md`"

Show a brief preview (first 10-15 lines) so the user can verify the content looks right.
