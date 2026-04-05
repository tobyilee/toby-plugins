# cmux Browser API Reference

Full reference for `cmux browser` subcommands. All commands target a browser surface.

## Command Index

| Category | Subcommands |
|----------|-------------|
| Navigation | `identify`, `open`, `open-split`, `navigate`, `back`, `forward`, `reload`, `url`, `focus-webview`, `is-webview-focused` |
| Waiting | `wait` |
| DOM interaction | `click`, `dblclick`, `hover`, `focus`, `check`, `uncheck`, `scroll-into-view`, `type`, `fill`, `press`, `keydown`, `keyup`, `select`, `scroll` |
| Inspection | `snapshot`, `screenshot`, `get`, `is`, `find`, `highlight` |
| JavaScript | `eval`, `addinitscript`, `addscript`, `addstyle` |
| Frames/Dialogs | `frame`, `dialog`, `download` |
| State | `cookies`, `storage`, `state` |
| Tabs/Logs | `tab`, `console`, `errors` |
| Device emulation | `viewport`, `geolocation`/`geo`, `offline` |
| Network | `network route`, `network unroute`, `network requests` |
| Recording | `trace`, `screencast` |

## Targeting

Most subcommands require a target surface. Pass it positionally or with `--surface`:

```bash
cmux browser surface:2 url
cmux browser --surface surface:2 url
```

## Navigation

```bash
cmux browser open https://example.com              # Open in new browser split
cmux browser open-split https://example.com         # Open as a split pane

cmux browser surface:2 navigate https://example.org --snapshot-after
cmux browser surface:2 back
cmux browser surface:2 forward
cmux browser surface:2 reload --snapshot-after
cmux browser surface:2 url                          # Get current URL

cmux browser surface:2 focus-webview
cmux browser surface:2 is-webview-focused
```

## Waiting

Block until a condition is met:

```bash
cmux browser surface:2 wait --load-state complete --timeout-ms 15000
cmux browser surface:2 wait --selector "#checkout" --timeout-ms 10000
cmux browser surface:2 wait --text "Order confirmed"
cmux browser surface:2 wait --url-contains "/dashboard"
cmux browser surface:2 wait --function "window.__appReady === true"
```

## DOM Interaction

Mutating actions support `--snapshot-after` for quick verification:

```bash
# Clicking
cmux browser surface:2 click "button[type='submit']" --snapshot-after
cmux browser surface:2 dblclick ".item-row"
cmux browser surface:2 hover "#menu"

# Focus and checkboxes
cmux browser surface:2 focus "#email"
cmux browser surface:2 check "#terms"
cmux browser surface:2 uncheck "#newsletter"
cmux browser surface:2 scroll-into-view "#pricing"

# Text input
cmux browser surface:2 type "#search" "cmux"           # Types character by character
cmux browser surface:2 fill "#email" --text "a@b.com"  # Clears field first, then fills
cmux browser surface:2 fill "#email" --text ""          # Clear a field

# Keyboard
cmux browser surface:2 press Enter
cmux browser surface:2 keydown Shift
cmux browser surface:2 keyup Shift

# Select dropdown
cmux browser surface:2 select "#region" "us-east"

# Scroll
cmux browser surface:2 scroll --dy 800 --snapshot-after
cmux browser surface:2 scroll --selector "#log-view" --dx 0 --dy 400
```

## Inspection

```bash
# Accessibility tree (best for finding interactive elements)
cmux browser surface:2 snapshot --interactive --compact
cmux browser surface:2 snapshot --selector "main" --max-depth 5

# Screenshot
cmux browser surface:2 screenshot --out /tmp/page.png

# Get properties
cmux browser surface:2 get title
cmux browser surface:2 get url
cmux browser surface:2 get text "h1"
cmux browser surface:2 get html "main"
cmux browser surface:2 get value "#email"
cmux browser surface:2 get attr "a.primary" --attr href
cmux browser surface:2 get count ".row"
cmux browser surface:2 get box "#checkout"
cmux browser surface:2 get styles "#total" --property color

# Boolean checks
cmux browser surface:2 is visible "#checkout"
cmux browser surface:2 is enabled "button[type='submit']"
cmux browser surface:2 is checked "#terms"

# Find elements
cmux browser surface:2 find role button --name "Continue"
cmux browser surface:2 find text "Order confirmed"
cmux browser surface:2 find label "Email"
cmux browser surface:2 find placeholder "Search"
cmux browser surface:2 find testid "save-btn"
cmux browser surface:2 find first ".row"
cmux browser surface:2 find last ".row"
cmux browser surface:2 find nth 2 ".row"

# Visual highlight
cmux browser surface:2 highlight "#checkout"
```

## JavaScript

```bash
cmux browser surface:2 eval "document.title"
cmux browser surface:2 eval --script "window.location.href"

cmux browser surface:2 addinitscript "window.__cmuxReady = true;"
cmux browser surface:2 addscript "document.querySelector('#name')?.focus()"
cmux browser surface:2 addstyle "#debug-banner { display: none !important; }"
```

## State Management

```bash
# Cookies
cmux browser surface:2 cookies get
cmux browser surface:2 cookies get --name session_id
cmux browser surface:2 cookies set session_id abc123 --domain example.com --path /
cmux browser surface:2 cookies clear --name session_id
cmux browser surface:2 cookies clear --all

# Local/session storage
cmux browser surface:2 storage local set theme dark
cmux browser surface:2 storage local get theme
cmux browser surface:2 storage local clear
cmux browser surface:2 storage session set flow onboarding

# Full state snapshot
cmux browser surface:2 state save /tmp/browser-state.json
cmux browser surface:2 state load /tmp/browser-state.json
```

## Tabs

```bash
cmux browser surface:2 tab list
cmux browser surface:2 tab new https://example.com/pricing
cmux browser surface:2 tab switch 1
cmux browser surface:2 tab close
```

## Console and Errors

```bash
cmux browser surface:2 console list
cmux browser surface:2 console clear
cmux browser surface:2 errors list
cmux browser surface:2 errors clear
```

## Dialogs

```bash
cmux browser surface:2 dialog accept
cmux browser surface:2 dialog accept "Confirmed"
cmux browser surface:2 dialog dismiss
```

## Frames

```bash
cmux browser surface:2 frame "iframe[name='checkout']"
cmux browser surface:2 click "#pay-now"
cmux browser surface:2 frame main   # Return to top-level
```

## Downloads

```bash
cmux browser surface:2 click "a#download-report"
cmux browser surface:2 download --path /tmp/report.csv --timeout-ms 30000
```

## Viewport and Device Emulation

```bash
# Set browser dimensions (pixels)
cmux browser surface:2 viewport 375 812          # iPhone X size

# Simulate GPS coordinates
cmux browser surface:2 geolocation 37.7749 -122.4194   # San Francisco
cmux browser surface:2 geo 35.6762 139.6503             # Tokyo (alias)

# Toggle offline mode
cmux browser surface:2 offline true
cmux browser surface:2 offline false
```

## Network Interception

Mock or block HTTP requests:

```bash
# Route: intercept requests matching a URL pattern
cmux browser surface:2 network route "*/api/users" --body '{"users":[]}'
cmux browser surface:2 network route "*/analytics/*" --abort   # Block requests

# Remove a route
cmux browser surface:2 network unroute "*/api/users"

# List captured requests
cmux browser surface:2 network requests
```

## Performance Tracing and Recording

```bash
# Record a performance trace
cmux browser surface:2 trace start /tmp/trace.json
# ... interact with the page ...
cmux browser surface:2 trace stop

# Record video (screencast)
cmux browser surface:2 screencast start
# ... interact with the page ...
cmux browser surface:2 screencast stop
```
