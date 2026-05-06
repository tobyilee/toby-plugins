---
name: toby-team-starter
description: >
  Use this skill to spawn a multi-agent workspace with Codex and Gemini running
  alongside Claude in cmux. Trigger on "toby team", "toby team 시작", "toby team 준비",
  "toby team 시작해", "toby team 준비해", "toby 팀 시작", "toby 팀 준비",
  "agent team", "에이전트 팀", "codex랑 gemini 같이", "start agent team", "팀 시작",
  "멀티 에이전트 시작", "codex gemini 같이 띄워", "에이전트 팀 만들어",
  "spawn agents", "launch agents", "에이전트 pane 열어", "agent pane",
  "start multi-agent", "codex gemini pane".
  Also trigger when the user wants Codex and Gemini running side-by-side in terminal
  panes for parallel work, or asks to set up a multi-agent development environment.
  Do NOT trigger when the user just wants to delegate a single task to codex or gemini
  — use codex-delegate or gemini-delegate for that. This skill is specifically for
  spawning persistent agent panes in cmux.
version: 0.1.0
---

# Toby Agent Team

Spawn Codex (`--full-auto`) and Gemini (`--yolo`) in cmux panes alongside the current Claude session. Skips creation if they're already running in the same workspace.

## Prerequisites

- cmux must be running (check socket)
- Current terminal must be inside cmux (CMUX_WORKSPACE_ID set)
- `codex` and `gemini` CLI binaries must be available

## Workflow

### Step 1: Verify cmux environment

```bash
# Check cmux is available and we're inside it
if [ -z "${CMUX_WORKSPACE_ID:-}" ]; then
  echo "ERROR: Not inside a cmux workspace"
  exit 1
fi
cmux ping
```

If cmux is not available or we're not inside a cmux terminal, inform the user and stop.

### Step 2: Check for existing agent panes

Before creating new panes, check if codex or gemini are already running in the current workspace. The skill labels panes with `rename-tab` on creation, so we can detect them by title.

```bash
# Get the tree of current workspace in JSON
cmux tree --json
```

Parse the JSON to get all surfaces in the selected workspace. Check each surface's `title` field:
- `CODEX_RUNNING=true` if any surface title is exactly `"Codex"`
- `GEMINI_RUNNING=true` if any surface title is exactly `"Gemini"`

Also save the caller's `pane_ref` (the pane containing `CMUX_SURFACE_ID`) — you'll need it in Step 6 to return focus.

If both are already running, inform the user and stop:
> "Codex와 Gemini가 이미 이 workspace에서 실행 중입니다."

### Step 3: Check CLI availability

Only check for CLIs that need to be launched:

```bash
# Check codex (only if not already running)
command -v codex &>/dev/null && echo "codex available"

# Check gemini (only if not already running)
command -v gemini &>/dev/null && echo "gemini available"
```

If a needed CLI is not found, warn the user but continue with the other agent.

### Step 4: Create Codex pane (right split)

Skip if codex is already running or codex CLI is not available.

`new-split` returns a line like `OK surface:26 workspace:7`. Capture the surface ref to send commands to it.

```bash
# Split right from current pane
CODEX_OUT=$(cmux new-split right)
CODEX_SURFACE=$(echo "$CODEX_OUT" | grep -o 'surface:[0-9]*')

# Shell readiness check via cmux IPC round-trip (no hard sleep per project convention).
# The read-screen call naturally paces ~10-50ms — enough for shell init without sleep.
cmux read-screen --surface "$CODEX_SURFACE" --lines 1 >/dev/null 2>&1 || true
# Send the command text, then press Enter via send-key. Avoid literal "\n" in the
# argument — cmux send treats the string as raw text, not a shell-interpreted escape.
cmux send --surface "$CODEX_SURFACE" "codex --full-auto"
cmux send-key --surface "$CODEX_SURFACE" enter

# Label the pane for future detection (toby-codex skill matches `title == "Codex"`).
cmux rename-tab --surface "$CODEX_SURFACE" "Codex"
```

### Step 5: Create Gemini pane (down split from Codex pane)

Skip if gemini is already running or gemini CLI is not available.

Split down from the Codex surface specifically (use `--surface` flag) so Gemini appears below Codex, not below Claude.

```bash
# Split down from the Codex pane
GEMINI_OUT=$(cmux new-split down --surface "$CODEX_SURFACE")
GEMINI_SURFACE=$(echo "$GEMINI_OUT" | grep -o 'surface:[0-9]*')

# Shell readiness check via cmux IPC round-trip (no hard sleep per project convention).
cmux read-screen --surface "$GEMINI_SURFACE" --lines 1 >/dev/null 2>&1 || true
# Model version: single source of truth is plugins/toby-essentials/MODELS.md
cmux send --surface "$GEMINI_SURFACE" "gemini --yolo --model gemini-3.1-pro-preview"
cmux send-key --surface "$GEMINI_SURFACE" enter

# Label the pane for future detection (toby-gemini skill matches `title == "Gemini"`).
cmux rename-tab --surface "$GEMINI_SURFACE" "Gemini"
```

If only Gemini needs to be created (Codex already running), split down from the existing Codex surface (find it from the tree by title `"Codex"`). If Codex is not present either, split right from the current Claude pane:

```bash
GEMINI_OUT=$(cmux new-split right)
```

### Step 6: Return focus to Claude pane

Use `focus-pane` (not `focus-surface` — that command doesn't exist). Get the caller's pane ref from the `cmux tree --json` output obtained in Step 2.

```bash
# The caller's pane ref was captured in Step 2 from tree output
# Look for the pane where caller.surface_ref matches CMUX_SURFACE_ID
cmux focus-pane --pane <caller_pane_ref>
```

### Step 7: Notify and report

Send a notification and report the result:

```bash
cmux notify --title "Agent Team Ready" --body "Codex and Gemini are running"
```

Display a summary to the user:

```
Agent Team 구성 완료:
┌─────────────────┬─────────────────┐
│                 │ Codex           │
│  Claude (현재)   │ (--full-auto)   │
│                 ├─────────────────┤
│                 │ Gemini          │
│                 │ (--yolo)        │
└─────────────────┴─────────────────┘
```

## Edge Cases

- **Only one agent missing**: If codex is already running but gemini is not (or vice versa), only create the missing pane. When creating just the gemini pane without a codex pane to split from, split down from the current Claude pane instead.
- **Neither CLI available**: Inform the user which CLIs are missing and how to install them.
- **cmux not running**: Tell the user to open cmux first. Do not fall back to tmux.
- **Already in a complex layout**: The skill always splits from the current context. If the layout is already complex, the new panes will be added relative to whatever is currently focused.
