# cmux + Claude Code Hooks Integration

Integrate cmux notifications with Claude Code hooks so you get alerted when tasks complete or agents need attention.

## Hook Script

Create `~/.claude/hooks/cmux-notify.sh`:

```bash
#!/bin/bash
# Skip if not running inside cmux
[ -S /tmp/cmux.sock ] || exit 0

EVENT=$(cat)
EVENT_TYPE=$(echo "$EVENT" | jq -r '.hook_event_name // "unknown"')
TOOL=$(echo "$EVENT" | jq -r '.tool_name // ""')

case "$EVENT_TYPE" in
    "Stop")
        cmux notify --title "Claude Code" --body "Session complete"
        ;;
    "PostToolUse")
        [ "$TOOL" = "Task" ] && cmux notify --title "Claude Code" --body "Agent finished"
        ;;
esac
```

```bash
chmod +x ~/.claude/hooks/cmux-notify.sh
```

## Claude Code Settings

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/cmux-notify.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/cmux-notify.sh"
          }
        ]
      }
    ]
  }
}
```

Restart Claude Code to apply the hooks.

## Notification Lifecycle

1. **Received**: Notification appears in the panel, desktop alert fires
2. **Unread**: Badge shown on workspace tab
3. **Read**: Cleared when you view that workspace
4. **Cleared**: Removed from panel

Desktop alerts are suppressed when cmux is focused and the workspace is active.

## Shortcuts

- `⌘⇧I` — Open notification panel
- `⌘⇧U` — Jump to workspace with most recent unread notification

## OSC Escape Sequences

For sending notifications without the CLI (e.g., from scripts inside tmux passthrough):

```bash
# OSC 777 (simple)
printf '\e]777;notify;Title;Body\a'

# tmux passthrough
printf '\ePtmux;\e\e]777;notify;Title;Body\a\e\\'
```

## Custom Notification Command

Set a custom command in Settings > App > Notification Command. Environment variables available:

| Variable | Description |
|----------|-------------|
| `CMUX_NOTIFICATION_TITLE` | Notification title |
| `CMUX_NOTIFICATION_SUBTITLE` | Subtitle |
| `CMUX_NOTIFICATION_BODY` | Body text |

Example: `say "$CMUX_NOTIFICATION_TITLE"` for text-to-speech alerts.
