# Project Instructions

## Commands

### `upgrade`

When the user says "upgrade", perform the following steps in order:

1. Bump the `version` field (minor version) in `plugins/toby-essentials/.claude-plugin/plugin.json`
2. Update the version in `README.md` (`toby-essentials` 헤더의 버전 태그)
3. Update `CHANGELOG.md`
4. Commit with message: `Bump toby-essentials plugin version to {new_version}`
5. Push to remote
