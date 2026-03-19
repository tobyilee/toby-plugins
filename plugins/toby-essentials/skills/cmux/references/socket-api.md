# cmux Socket API Reference

All CLI commands have equivalent JSON-RPC methods via the Unix socket at `/tmp/cmux.sock`.

## Connection

```bash
SOCK="${CMUX_SOCKET_PATH:-/tmp/cmux.sock}"
```

Send one newline-terminated JSON request per call:

```bash
echo '{"id":"req-1","method":"workspace.list","params":{}}' | nc -U "$SOCK"
```

Response format:

```json
{"id":"req-1","ok":true,"result":{"workspaces":[...]}}
```

## Access Modes

| Mode | Description |
|------|-------------|
| **Off** | Socket disabled |
| **cmux processes only** | Only processes spawned inside cmux can connect (default) |
| **allowAll** | Any local process can connect (`CMUX_SOCKET_MODE=allowAll`) |

## Methods

### Workspace

| Method | Params | Description |
|--------|--------|-------------|
| `workspace.list` | `{}` | List all workspaces |
| `workspace.create` | `{}` | Create new workspace |
| `workspace.select` | `{"workspace_id":"<id>"}` | Switch to workspace |
| `workspace.current` | `{}` | Get active workspace |
| `workspace.close` | `{"workspace_id":"<id>"}` | Close workspace |

### Surface

| Method | Params | Description |
|--------|--------|-------------|
| `surface.split` | `{"direction":"right\|down\|left\|up"}` | Create split pane |
| `surface.list` | `{}` | List surfaces in workspace |
| `surface.focus` | `{"surface_id":"<id>"}` | Focus a surface |
| `surface.send_text` | `{"text":"...\n"}` | Send text to focused surface |
| `surface.send_text` | `{"surface_id":"<id>","text":"..."}` | Send text to specific surface |
| `surface.send_key` | `{"key":"enter\|tab\|escape\|..."}` | Send key press |

### Notification

| Method | Params | Description |
|--------|--------|-------------|
| `notification.create` | `{"title":"...","subtitle":"...","body":"..."}` | Send notification |
| `notification.list` | `{}` | List notifications |
| `notification.clear` | `{}` | Clear all notifications |

### System

| Method | Params | Description |
|--------|--------|-------------|
| `system.ping` | `{}` | Health check (returns `{"pong":true}`) |
| `system.capabilities` | `{}` | List available methods |
| `system.identify` | `{}` | Show focused context |

## Python Client Example

```python
import json, os, socket

SOCKET_PATH = os.environ.get("CMUX_SOCKET_PATH", "/tmp/cmux.sock")

def rpc(method, params=None, req_id=1):
    payload = {"id": req_id, "method": method, "params": params or {}}
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(SOCKET_PATH)
        sock.sendall(json.dumps(payload).encode("utf-8") + b"\n")
        return json.loads(sock.recv(65536).decode("utf-8"))

# List workspaces
print(rpc("workspace.list", req_id="ws"))

# Send notification
print(rpc("notification.create", {"title": "Done", "body": "Task complete"}, req_id="notify"))
```

## Shell Script Example

```bash
#!/bin/bash
SOCK="${CMUX_SOCKET_PATH:-/tmp/cmux.sock}"

cmux_rpc() {
    printf "%s\n" "$1" | nc -U "$SOCK"
}

cmux_rpc '{"id":"ws","method":"workspace.list","params":{}}'
cmux_rpc '{"id":"notify","method":"notification.create","params":{"title":"Done","body":"Task complete"}}'
```
