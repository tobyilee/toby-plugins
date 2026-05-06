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
version: 0.2.0
---

# cmux — Terminal Control from Claude Code

cmux is a native macOS terminal app built on Ghostty's rendering engine. It provides vertical tabs, split panes, an embedded browser, notifications, and a socket API — all controllable from the CLI.

## Detection

Before using any cmux command, check that cmux is available. If cmux is not detected, tell the user and stop — do not fall back to tmux or other tools.

```bash
# Quick detection (prefer this)
[ -S "${CMUX_SOCKET_PATH:-$HOME/Library/Application Support/cmux/cmux.sock}" ] && echo "cmux available"

# Or check the CLI
command -v cmux &>/dev/null && cmux ping
```

Environment variables set inside cmux terminals:

| Variable | Description |
|----------|-------------|
| `CMUX_WORKSPACE_ID` | Current workspace ID |
| `CMUX_SURFACE_ID` | Current surface ID |
| `CMUX_SOCKET_PATH` | Socket path (default: `~/Library/Application Support/cmux/cmux.sock`) |

## Core Concepts

cmux has a four-level hierarchy:

```
Window → Workspace (sidebar tab) → Pane (split region) → Surface (tab within pane)
```

- **Workspace**: A sidebar entry containing split panes. Created with `⌘N` or `cmux new-workspace`.
- **Pane**: A split region. Created with `⌘D` (right) or `⌘⇧D` (down), or `cmux new-split right|down`.
- **Surface**: A tab within a pane. Each surface has a `CMUX_SURFACE_ID`. Surfaces hold either a terminal or a browser panel.

## Window Management

Windows are OS-level windows containing workspaces. Most agents work within a single window, but multi-window setups are useful for multi-monitor workflows.

```bash
cmux list-windows                       # List all windows
cmux current-window                     # Get active window
cmux new-window                         # Create a new OS window
cmux focus-window --window window:2     # Bring window to front
cmux close-window --window window:2     # Close a window
cmux move-workspace-to-window --workspace workspace:3 --window window:2  # Move workspace between windows
```

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

# Create a pane with a specific type
cmux new-pane --type browser --direction right --url https://example.com
cmux new-pane --type terminal --direction down

# Add a new surface (tab) within an existing pane
cmux new-surface --type terminal --pane pane:2
cmux new-surface --type browser --pane pane:2 --url https://example.com

# Close a surface
cmux close-surface --surface surface:5

# List panes and surfaces
cmux list-panes                         # List panes in workspace
cmux list-pane-surfaces                 # List surfaces in workspace
cmux list-panels                        # List panels (surfaces) in workspace
cmux tree                               # Show full workspace tree

# Focus
cmux focus-pane --pane pane:3
cmux focus-panel --panel surface:3

# Resize and rearrange panes
cmux resize-pane --pane pane:2 -R --amount 10   # Grow right by 10
cmux swap-pane --pane pane:2 --target-pane pane:3
cmux break-pane --surface surface:4              # Break surface out to its own pane
cmux join-pane --target-pane pane:2 --surface surface:4  # Join surface into another pane
```

### Send input to panes

```bash
# Send to the currently focused terminal
cmux send "npm run build\n"

# Send to a specific surface
cmux send --surface surface:3 "pytest -v\n"

# Send to a panel by panel ref
cmux send-panel --panel surface:3 "npm test\n"

# Send a key press
cmux send-key enter
cmux send-key --surface surface:3 escape
cmux send-key-panel --panel surface:3 ctrl+c
```

### Read terminal output

Read the visible screen or scrollback buffer of a surface:

```bash
# Read current viewport
cmux read-screen

# Read from a specific surface
cmux read-screen --surface surface:3

# Include scrollback buffer
cmux read-screen --scrollback

# Limit to last N lines (implies --scrollback)
cmux read-screen --lines 50 --surface surface:3

# Pipe pane output to a command (for monitoring/logging)
cmux pipe-pane --surface surface:3 --command "tee /tmp/build.log"
```

### Notifications

Notify the user when something completes or needs attention:

```bash
cmux notify --title "Build Complete" --body "All tests passed"
cmux notify --title "Claude Code" --subtitle "Waiting" --body "Agent needs input"

# Manage notifications
cmux list-notifications
cmux clear-notifications
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
cmux log -- "Build started"
cmux log --level success -- "All 42 tests passed"
cmux log --level error --source build -- "Compilation failed"
```

### Workspace management

```bash
cmux new-workspace                      # Create new workspace
cmux new-workspace --name "Tests" --cwd /tmp --command "npm test"  # With options
cmux list-workspaces                    # List all workspaces
cmux select-workspace --workspace <id>  # Switch workspace
cmux close-workspace --workspace <id>   # Close workspace
cmux current-workspace                  # Get active workspace
cmux rename-workspace "New Name"        # Rename current workspace
cmux rename-workspace --workspace workspace:2 "Build"  # Rename specific workspace
cmux find-window --content --select "pytest"  # Search and focus by content
```

### SSH connections

Open SSH sessions as dedicated workspaces:

```bash
cmux ssh user@host.example.com
cmux ssh user@host --name "Production" --port 2222
cmux ssh user@host --identity ~/.ssh/id_ed25519 --no-focus
cmux ssh user@host -- htop   # Run remote command
```

### Markdown viewer

Open a markdown file in a formatted viewer panel with live reload:

```bash
cmux markdown README.md                         # Open in split next to current pane
cmux markdown open docs/ARCHITECTURE.md          # Explicit open subcommand
```

### Synchronization

Use `wait-for` to coordinate between panes or scripts:

```bash
# In script A: wait for a signal (blocks up to 30s by default)
cmux wait-for build-done --timeout 60

# In script B: signal when ready
cmux wait-for --signal build-done
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

Every CLI command has a socket equivalent via `~/Library/Application Support/cmux/cmux.sock`. Useful for scripts that need direct RPC:

```bash
# Send a JSON-RPC request
echo '{"id":"1","method":"workspace.list","params":{}}' | nc -U "${CMUX_SOCKET_PATH:-$HOME/Library/Application Support/cmux/cmux.sock}"
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
| `surface not found` | Run `cmux list-pane-surfaces` to get valid surface IDs |
| Browser command fails | Ensure the target surface is a browser panel, not a terminal |
| Permission denied | Socket mode may be "Off" — check Settings or set `CMUX_SOCKET_MODE=allowAll` |
