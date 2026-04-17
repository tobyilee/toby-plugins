# Model Defaults — toby-essentials

Single source of truth for default model versions used by delegation skills.
When upgrading to a newer model, update this file **and** the skills listed below.

## Current Defaults

| Provider | Model | Used By |
|----------|-------|---------|
| OpenAI Codex | `gpt-5.4` | `codex-delegate`, `toby-codex` (via cmux pane) |
| Google Gemini | `gemini-3.1-pro-preview` | `gemini-delegate`, `toby-team-starter`, `toby-gemini` (via cmux pane) |
| Anthropic Claude | (inherits session model) | All Claude-run skills |

## Update Procedure

When a new model version drops:

1. Update the table above with the new model ID
2. Update default examples in these files:
   - `skills/codex-delegate/SKILL.md` — 5 occurrences of `gpt-5.4`
   - `skills/gemini-delegate/SKILL.md` — 6 occurrences of `gemini-3.1-pro-preview`
   - `skills/toby-team-starter/SKILL.md` — 1 occurrence (Gemini launch command)
3. Verify with: `grep -rn "gpt-5\\.4\\|gemini-3\\.1" plugins/toby-essentials/skills/`
4. Bump the plugin version in `.claude-plugin/plugin.json` and `README.md`
5. Update the relevant entry in `/Users/tobylee/.claude/projects/-Users-tobylee-workspace-ai-toby-plugins/memory/` (project_codex_model.md / project_gemini_model.md)

## History

| Date | Change | Reason |
|------|--------|--------|
| 2026-03-26 | Gemini default → `gemini-3.1-pro-preview` | User preference (memory entry) |
| 2026-03-30 | Codex default → `gpt-5.4` | User preference (memory entry) |
| 2026-04-17 | This file created as single source of truth | Reduce edit count on future upgrades |
