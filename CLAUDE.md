# Project Instructions

## Commands

### `upgrade <plugin-name>`

When the user says "upgrade <plugin-name>" (e.g. "upgrade toby-session"), perform the following steps in order:

1. Bump the `version` field (minor version) in `plugins/<plugin-name>/.claude-plugin/plugin.json`
2. Update the version in `README.md` (해당 플러그인 섹션의 버전 태그 — both the top table and the section heading if present)
3. Update `CHANGELOG.md` with the new entry
4. Commit with message: `Bump <plugin-name> plugin version to {new_version}`
5. Push to remote

If the user says "upgrade" without a plugin name, ask which of the 5 plugins they mean:
`toby-multi-agent`, `toby-session`, `toby-claude-config`, `toby-codereview`, `toby-personal`.
