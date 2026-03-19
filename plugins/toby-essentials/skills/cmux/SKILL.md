---
name: cmux
description: >
  Use this skill to control the cmux terminal app from Claude Code. Trigger on
  "cmux", "open browser pane", "split pane", "browser split", "open in browser",
  "cmux browser", "cmux notify", "cmux split", "새 pane 열어", "브라우저 열어",
  "알림 보내", "사이드바", "workspace 만들어", "pane 분할", "browser automation",
  "cmux에서", "cmux로", "cmux 사용해서". Also trigger when the user wants to
  open a URL alongside their terminal, send notifications when a task completes,
  manage terminal panes programmatically, automate browser interactions from the
  CLI, or set sidebar status/progress for build scripts. Do NOT trigger for
  general tmux commands — cmux is a different app. If cmux is not detected
  (no socket, no CLI), inform the user and skip.
version: 0.1.0
---

# cmux — Terminal Control from Claude Code

cmux is a native macOS terminal app built on Ghostty's rendering engine. It provides vertical tabs, split panes, an embedded browser, notifications, and a socket API — all controllable from the CLI.

## Detection

Before using any cmux command, check that cmux is available. If cmux is not detected, tell the user and stop — do not fall back to tmux or other tools.

```bash
# Quick detection (prefer this)
[ -S "${CMUX_SOCKET_PATH:-/tmp/cmux.sock}" ] && echo "cmux available"

# Or check the CLI
command -v cmux &>/dev/null && cmux ping
```

Environment variables set inside cmux terminals:

| Variable | Description |
|----------|-------------|
| `CMUX_WORKSPACE_ID` | Current workspace ID |
| `CMUX_SURFACE_ID` | Current surface ID |
| `CMUX_SOCKET_PATH` | Socket path (default: `/tmp/cmux.sock`) |

## Core Concepts

cmux has a four-level hierarchy:

```
Window → Workspace (sidebar tab) → Pane (split region) → Surface (tab within pane)
```

- **Workspace**: A sidebar entry containing split panes. Created with `⌘N` or `cmux new-workspace`.
- **Pane**: A split region. Created with `⌘D` (right) or `⌘⇧D` (down), or `cmux new-split right|down`.
- **Surface**: A tab within a pane. Each surface has a `CMUX_SURFACE_ID`. Surfaces hold either a terminal or a browser panel.

## Common Workflows

### Open a browser alongside the terminal

The most common use case — open a URL in a split pane next to the current terminal:

```bash
cmux browser open-split https://example.com
# Returns: OK surface=surface:2 pane=pane:2 placement=split
```

Save the returned surface ID to interact with the browser later.

### Create pane layouts

```bash
# Split right (vertical split)
cmux new-split right

# Split down (horizontal split)
cmux new-split down

# List all surfaces in current workspace
cmux list-surfaces --json

# Focus a specific surface
cmux focus-surface --surface surface:3
```

### Send input to panes

```bash
# Send to the currently focused terminal
cmux send "npm run build\n"

# Send to a specific surface
cmux send-surface --surface surface:3 "pytest -v\n"

# Send a key press
cmux send-key enter
cmux send-key-surface --surface surface:3 escape
```

### Notifications

Notify the user when something completes or needs attention:

```bash
cmux notify --title "Build Complete" --body "All tests passed"
cmux notify --title "Claude Code" --subtitle "Waiting" --body "Agent needs input"
```

### Sidebar metadata

Surface build status, progress, and logs in the workspace sidebar:

```bash
# Status pills
cmux set-status build "compiling" --icon hammer --color "#ff9500"
cmux clear-status build

# Progress bar (0.0 to 1.0)
cmux set-progress 0.5 --label "Building..."
cmux clear-progress

# Log entries
cmux log "Build started"
cmux log --level success "All 42 tests passed"
cmux log --level error --source build "Compilation failed"
```

### Workspace management

```bash
cmux new-workspace                      # Create new workspace
cmux list-workspaces --json             # List all workspaces
cmux select-workspace --workspace <id>  # Switch workspace
cmux close-workspace --workspace <id>   # Close workspace
cmux current-workspace --json           # Get active workspace
```

## Browser Automation

cmux embeds a full browser that can be controlled from the CLI. This is useful for checking web UIs, filling forms, running E2E verification, or viewing documentation alongside code.

For the full browser command reference, see `references/browser-api.md`.

### Quick reference

```bash
# Navigate
cmux browser surface:2 navigate https://docs.example.com
cmux browser surface:2 back
cmux browser surface:2 reload

# Inspect
cmux browser surface:2 snapshot --interactive --compact
cmux browser surface:2 screenshot --out /tmp/page.png
cmux browser surface:2 get title
cmux browser surface:2 get text "h1"

# Interact
cmux browser surface:2 click "button[type='submit']"
cmux browser surface:2 fill "#email" --text "user@example.com"
cmux browser surface:2 type "#search" "query"
cmux browser surface:2 press Enter

# Wait for conditions
cmux browser surface:2 wait --load-state complete --timeout-ms 10000
cmux browser surface:2 wait --text "Success"
cmux browser surface:2 wait --selector "#dashboard"

# JavaScript
cmux browser surface:2 eval "document.title"
```

### Typical browser workflow

```bash
# 1. Open browser in a split
BROWSER_OUT=$(cmux browser open-split https://example.com/login)
SURFACE=$(echo "$BROWSER_OUT" | grep -o 'surface:[0-9]*')

# 2. Wait for page load
cmux browser $SURFACE wait --load-state complete --timeout-ms 10000

# 3. Fill a form
cmux browser $SURFACE fill "#email" --text "user@example.com"
cmux browser $SURFACE fill "#password" --text "secret"
cmux browser $SURFACE click "button[type='submit']" --snapshot-after

# 4. Verify result
cmux browser $SURFACE wait --text "Welcome"
cmux browser $SURFACE get title
```

## Socket API

Every CLI command has a socket equivalent via `/tmp/cmux.sock`. Useful for scripts that need direct RPC:

```bash
# Send a JSON-RPC request
echo '{"id":"1","method":"workspace.list","params":{}}' | nc -U /tmp/cmux.sock
```

For the full socket API reference, see `references/socket-api.md`.

## Claude Code Hook Integration

cmux integrates with Claude Code hooks to send notifications when tasks complete. A hook script can call `cmux notify` on `Stop` or `PostToolUse` events to alert the user.

For hook setup details, see `references/hooks-integration.md`.

## Error Handling

| Problem | Solution |
|---------|----------|
| `cmux: command not found` | Create symlink: `sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux` |
| Socket not found | cmux app might not be running, or socket is disabled in Settings |
| `surface not found` | Run `cmux list-surfaces --json` to get valid surface IDs |
| Browser command fails | Ensure the target surface is a browser panel, not a terminal |
| Permission denied | Socket mode may be "Off" — check Settings or set `CMUX_SOCKET_MODE=allowAll` |
