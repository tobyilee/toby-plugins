---
name: delegate-orchestrate
description: >
  Decompose complex tasks into a multi-step workflow with dependency graph,
  then execute with optimal agent routing per step. Use when the user says
  "orchestrate", "오케스트레이션", "작업 분해해서 위임", "break down and delegate",
  "plan and execute with agents", "여러 단계로 나눠서", "복잡한 작업 위임",
  "decompose and delegate", "multi-step delegate", "단계별로 에이전트 실행",
  "작업 계획 세워서 실행", or wants a complex requirement decomposed into
  subtasks and executed across multiple agents with parallel/sequential scheduling.
version: 0.1.0
---

# Delegate Orchestrate

Decompose a complex requirement into subtasks, build a dependency graph (DAG),
and execute each task with the optimal agent — running independent tasks in parallel.

## Step 1: Check Agent Availability

```bash
which codex >/dev/null 2>&1 && echo "codex:available" || echo "codex:unavailable"
which gemini >/dev/null 2>&1 && echo "gemini:available" || echo "gemini:unavailable"
which claude >/dev/null 2>&1 && echo "claude:available" || echo "claude:unavailable"
```

## Step 2: Decompose the Requirement

Analyze the user's request and break it into **atomic subtasks**. Each subtask should be:
- Self-contained enough for a single agent to execute
- Clear about its inputs and expected outputs
- Tagged with a task type for agent routing

**Task type classification** (same as delegate skill):

| Task Type | Best Agent | Reason |
|-----------|-----------|--------|
| `large_context` (scan many files, full codebase) | gemini | Long context window |
| `fast_generation` (new files, boilerplate, scaffold) | codex | Speed |
| `complex_reasoning` (architecture, security, design) | claude | Quality |
| `review` (code review, audit) | gemini | Full context view |
| `simple_edit` (rename, fix typo, small change) | codex | Speed + cost |
| `documentation` (docs, explanations) | claude | Writing quality |
| `testing` (tests, specs, coverage) | codex | Pattern-based generation |

## Step 3: Build the Workflow Graph (DAG)

Determine dependencies between subtasks and construct a Directed Acyclic Graph.

**Rules for dependency analysis:**
- A task **depends on** another if it needs that task's output as input
- A task that **writes files** that another task **reads** creates a dependency
- Tasks with no dependencies on each other can run **in parallel** (same wave)
- Tasks are grouped into **waves**: all tasks in a wave run in parallel, waves run sequentially

**Example decomposition:**

User request: "Refactor the auth module, add tests, and update the docs"

```
Wave 1 (parallel):
  task-1: [codex] Analyze current auth module structure → output: analysis
  task-2: [gemini] Scan codebase for all auth module usages → output: usage-map

Wave 2 (parallel, depends on wave 1):
  task-3: [codex] Refactor auth module (uses analysis + usage-map) → output: refactored files
  task-4: [codex] Write unit tests for auth module (uses analysis) → output: test files

Wave 3 (depends on wave 2):
  task-5: [claude] Update documentation (uses refactored files + test files) → output: docs
```

## Step 4: Create Tasks File

Write the workflow plan as a JSON file for tracking:

```bash
WORKFLOW_DIR="/tmp/orchestrate-$(date +%s)"
mkdir -p "$WORKFLOW_DIR"
```

Write the following JSON to `$WORKFLOW_DIR/tasks.json` using the Write tool:

```json
{
  "id": "orchestrate-<timestamp>",
  "request": "<original user request>",
  "created_at": "<ISO timestamp>",
  "status": "running",
  "agents_available": ["codex", "gemini", "claude"],
  "waves": [
    {
      "wave": 1,
      "status": "pending",
      "tasks": [
        {
          "id": "task-1",
          "name": "<descriptive name>",
          "type": "<task_type>",
          "agent": "<selected_agent>",
          "depends_on": [],
          "prompt": "<full prompt for the agent>",
          "status": "pending",
          "result_file": null,
          "exit_code": null,
          "duration_ms": null
        }
      ]
    },
    {
      "wave": 2,
      "status": "pending",
      "tasks": [
        {
          "id": "task-3",
          "name": "<descriptive name>",
          "type": "<task_type>",
          "agent": "<selected_agent>",
          "depends_on": ["task-1", "task-2"],
          "prompt": "<prompt with {{task-1.result}} placeholder>",
          "status": "pending",
          "result_file": null,
          "exit_code": null,
          "duration_ms": null
        }
      ]
    }
  ],
  "summary": {
    "total_tasks": 0,
    "completed": 0,
    "failed": 0,
    "skipped": 0
  }
}
```

**IMPORTANT:** Before executing, present the workflow plan to the user:

```
Workflow Plan: <request summary>
═══════════════════════════════════════

Wave 1 (parallel):
  ├─ task-1: [codex] <name>
  └─ task-2: [gemini] <name>

Wave 2 (parallel, after wave 1):
  ├─ task-3: [codex] <name> ← depends on: task-1, task-2
  └─ task-4: [codex] <name> ← depends on: task-1

Wave 3 (after wave 2):
  └─ task-5: [claude] <name> ← depends on: task-3, task-4

Total: 5 tasks across 3 waves
Tasks file: $WORKFLOW_DIR/tasks.json
═══════════════════════════════════════
```

Ask the user to confirm before proceeding. They may want to adjust agents, add/remove steps, or change dependencies.

## Step 5: Execute Waves

Execute waves sequentially. Within each wave, run all tasks in parallel.

### 5a. For each wave:

Update the wave status to `"running"` in tasks.json.

### 5b. Single-task wave (no parallelism needed):

Execute the appropriate agent command directly:

**Codex:**
```bash
RESULT_FILE="$WORKFLOW_DIR/task-{ID}-codex.md"
START_MS=$(date +%s%3N)
codex exec "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" --full-auto --ephemeral --skip-git-repo-check \
  -C "<WORKING_DIR>" -o "$RESULT_FILE" 2>&1
EXIT_CODE=$?
END_MS=$(date +%s%3N)
echo "EXIT:$EXIT_CODE DURATION:$((END_MS - START_MS))ms FILE:$RESULT_FILE"
```

**Gemini:**
```bash
RESULT_FILE="$WORKFLOW_DIR/task-{ID}-gemini.md"
START_MS=$(date +%s%3N)
gemini -p "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" -y --include-directories "<WORKING_DIR>" -o text > "$RESULT_FILE" 2>&1
EXIT_CODE=$?
END_MS=$(date +%s%3N)
echo "EXIT:$EXIT_CODE DURATION:$((END_MS - START_MS))ms FILE:$RESULT_FILE"
```

**Claude subagent:**
```bash
RESULT_FILE="$WORKFLOW_DIR/task-{ID}-claude.md"
START_MS=$(date +%s%3N)
claude -p "$(cat <<'PROMPT'
<TASK_PROMPT>
PROMPT
)" --output-format json --model sonnet \
  --permission-mode dontAsk --disable-slash-commands \
  --no-session-persistence > "$RESULT_FILE" 2>&1
EXIT_CODE=$?
END_MS=$(date +%s%3N)
echo "EXIT:$EXIT_CODE DURATION:$((END_MS - START_MS))ms FILE:$RESULT_FILE"
```

### 5c. Multi-task wave (parallel execution):

Combine all tasks into a single Bash block with background processes:

```bash
WORKFLOW_DIR="<WORKFLOW_DIR>"

# task-1: codex
START_1=$(date +%s%3N)
codex exec "$(cat <<'PROMPT1'
<TASK_1_PROMPT>
PROMPT1
)" --full-auto --ephemeral --skip-git-repo-check \
  -C "<DIR>" -o "$WORKFLOW_DIR/task-1-codex.md" \
  > "$WORKFLOW_DIR/task-1-stdout.log" 2>&1 &
PID_1=$!

# task-2: gemini
START_2=$(date +%s%3N)
gemini -p "$(cat <<'PROMPT2'
<TASK_2_PROMPT>
PROMPT2
)" -y --include-directories "<DIR>" -o text \
  > "$WORKFLOW_DIR/task-2-gemini.md" 2>&1 &
PID_2=$!

# Wait and collect
wait $PID_1; EXIT_1=$?
END_1=$(date +%s%3N)
wait $PID_2; EXIT_2=$?
END_2=$(date +%s%3N)

echo "task-1: exit=$EXIT_1 duration=$((END_1 - START_1))ms"
echo "task-2: exit=$EXIT_2 duration=$((END_2 - START_2))ms"
```

Use `run_in_background: true` on the Bash tool for parallel wave execution.

### 5d. After each wave completes:

1. Read each task's result file
2. Update tasks.json: set task `status`, `exit_code`, `duration_ms`, `result_file`
3. Update wave `status` to `"completed"` or `"partial"` (if some tasks failed)
4. Print wave progress:

```
Wave 1 completed:
  ✓ task-1: [codex] Analyze auth structure (2.3s)
  ✓ task-2: [gemini] Scan auth usages (4.1s)
```

### 5e. Inject previous results into next wave prompts:

Before executing the next wave, replace `{{task-N.result}}` placeholders in each task's prompt with the actual content from the dependency's result file. Read each dependency result file and substitute.

If a dependency task failed, **skip** the dependent task (set status to `"skipped"`) unless the user explicitly asked for best-effort execution.

## Step 6: Handle Failures

**Per-task failure:**
- Mark task as `"failed"` in tasks.json
- If the task has dependents in later waves, mark those as `"skipped"`
- Try fallback agent (use fallback chain: `claude → codex → gemini`) for the failed task
- If fallback also fails, continue with remaining independent tasks

**Wave-level failure (all tasks failed):**
- Stop execution
- Present partial results from any completed waves
- Ask user how to proceed

## Step 7: Present Final Results

After all waves complete, present the orchestration summary:

```
Orchestration Complete
═══════════════════════════════════════

Request: <original request>
Workflow: $WORKFLOW_DIR/tasks.json

Wave 1 ✓
  ✓ task-1: [codex] Analyze auth structure (2.3s)
  ✓ task-2: [gemini] Scan auth usages (4.1s)

Wave 2 ✓
  ✓ task-3: [codex] Refactor auth module (8.5s)
  ✓ task-4: [codex] Write unit tests (5.2s)

Wave 3 ✓
  ✓ task-5: [claude] Update documentation (3.8s)

Summary: 5/5 tasks completed in 3 waves
Total time: 18.4s (parallel), estimated sequential: 23.9s
Speedup: 1.3x from parallelization

═══════════════════════════════════════
```

If any agents modified files, run `git diff` to show all changes and ask user to review.

Read the final task results from their result files and present a synthesized summary of all outputs.

## Limits

- Maximum tasks per orchestration: 10
- Maximum waves: 5
- Maximum concurrent agents per wave: check `budget.max_concurrent_agents` (default: 5)
- Maximum delegation depth: check `budget.max_delegation_depth` (default: 2)
- If decomposition produces more than 10 tasks, ask user to narrow scope
