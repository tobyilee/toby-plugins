---
name: delegate
description: >
  Auto-route tasks to the optimal AI agent. Use when the user says
  "delegate", "위임해줘", "다른 에이전트에게", "best agent for this",
  "auto route", "have another AI do this", "delegate this task",
  "최적의 에이전트로", "자동 라우팅", or wants to route a task to
  the best available agent without specifying which one.
version: 0.1.0
---

# Auto-Route Delegate

Route tasks to the optimal AI agent based on task type analysis.

## Step 1: Check Agent Availability

Run these checks to determine which agents are available:

```bash
which codex >/dev/null 2>&1 && echo "codex:available" || echo "codex:unavailable"
which gemini >/dev/null 2>&1 && echo "gemini:available" || echo "gemini:unavailable"
which claude >/dev/null 2>&1 && echo "claude:available" || echo "claude:unavailable"
```

## Step 2: Read Routing Config

Read `.claude/orchestrator.local.md` to get routing rules. If not found, use defaults:

| Task Type | Default Agent | Reason |
|-----------|--------------|--------|
| Large-context analysis (many files, full codebase) | **gemini** | Long context window |
| Fast code generation (new files, boilerplate) | **codex** | Speed |
| Complex reasoning (architecture, security, design) | **claude subagent** | Quality |
| Code review | **gemini** | Full context view |
| Simple edit (rename, fix typo, small change) | **codex** | Speed + cost |
| Documentation | **claude subagent** | Writing quality |
| Test writing | **codex** | Pattern-based generation |
| Default/unknown | **claude subagent** | Best general quality |

## Step 3: Classify the Task

Analyze the user's prompt to classify the task type. Look for these keywords:

- **large_context**: "all files", "entire codebase", "모노레포", "find all", "scan", "전체"
- **fast_generation**: "generate", "create", "scaffold", "boilerplate", "빠르게", "만들어"
- **complex_reasoning**: "design", "architect", "security", "설계", "분석", "왜"
- **review**: "review", "리뷰", "check", "검토"
- **simple_edit**: "rename", "fix typo", "수정", "바꿔", "간단한"
- **documentation**: "document", "문서화", "explain", "설명"
- **testing**: "test", "테스트", "spec", "coverage"

## Step 4: Select Agent and Execute

Based on the classification and availability, select the agent and execute directly:

### If selected agent is Codex:

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

### If selected agent is Gemini:

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

### If selected agent is Claude subagent:

```bash
RESULT_FILE="/tmp/claude-result-$(date +%s)-$RANDOM.md"
claude -p "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" \
  --output-format json \
  --model sonnet \
  --permission-mode dontAsk \
  --disable-slash-commands \
  --no-session-persistence \
  > "$RESULT_FILE" 2>&1
echo "===CLAUDE_RESULT_FILE:$RESULT_FILE==="
```

Use `run_in_background: true` for all executions.

## Step 5: Fallback on Failure

If the selected agent fails (exit code != 0, empty result, timeout):

1. Check the fallback chain: `claude_subagent → codex → gemini`
2. Try the next available agent in the chain
3. Only auto-fallback for **read-only** intents (read, review, research)
4. For **write** intents, report the failure and ask the user

## Step 6: Present Results

Show results with provenance:
```
[{Agent}, {model}, {duration}s]
Routing: {task_type} → {selected_agent} (reason: {reason})

{result content}
```

If the agent modified files, run `git diff` and ask user to review.
