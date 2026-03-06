---
description: Merge local project permissions into global settings
allowed-tools: Read, Write, Bash(cat:*), Bash(mkdir:*)
---

## Task: Merge Permissions

Merge the permissions from the current project's `.claude/settings.local.json` file into `~/.claude/settings.json`.

### Steps to Perform

1. **Read local settings file**: Read the `.claude/settings.local.json` file from the current project.

2. **Read global settings file**: Read the `~/.claude/settings.json` file.

3. **Merge permissions**:
   - Combine the `permissions.allow` arrays from both files
   - Combine the `permissions.deny` arrays from both files (if present)
   - Remove duplicate entries
   - Sort alphabetically

4. **Update global settings file**: Save the merged permissions to `~/.claude/settings.json`.

### Notes

- If a file does not exist, notify the user
- Preserve all other existing settings in the global configuration
- Clearly show the changes before and after the operation

### Execute

Perform the permissions merge operation following the steps above.
