---
name: custom-agent-template
description: >
  Template for creating custom agent delegation Skills.
  Use when the user says "create custom agent", "add new agent",
  "커스텀 에이전트 추가", "새 에이전트 만들어", or wants to integrate
  a new CLI tool as a delegatable agent in the orchestrator.
version: 0.1.0
---

# Custom Agent Skill Template

Generate a new delegation Skill for a custom CLI tool.

## Instructions

Ask the user for:
1. **CLI binary name** (e.g., `aider`, `cursor`, `copilot`)
2. **How to run non-interactively** (flags for stdin/stdout mode)
3. **Output format** (text, json, jsonl)
4. **What tasks it's best for** (for routing rules)

Then generate a SKILL.md file with this structure:

```markdown
---
name: {binary}-delegate
description: >
  Delegate tasks to {Binary} CLI. Use when the user says
  "delegate to {binary}", "{binary}에게", "use {binary} for",
  or wants to run a task using {Binary} CLI.
version: 0.1.0
---

# {Binary} Delegate

## Prerequisites
- {Binary} CLI installed: `which {binary}`

## Execution
\`\`\`bash
RESULT_FILE="/tmp/{binary}-result-$(date +%s)-$RANDOM.md"
{binary} {non_interactive_flags} '<TASK_PROMPT>' \
  > "$RESULT_FILE" 2>&1
echo "==={BINARY}_RESULT_FILE:$RESULT_FILE==="
\`\`\`

## Output Parsing
{Instructions for parsing the output format}

## Error Handling
| Error | Action |
|-------|--------|
| Not installed | `{install_command}` |
| Auth failure | `{auth_command}` |
```

Save the generated file to:
`claude-orchestrator/skills/{binary}-delegate/SKILL.md`

Also suggest adding the agent to `.claude/orchestrator.local.md` routing rules.
