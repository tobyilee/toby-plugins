# OMC Detailed Reference — Architecture, Hooks, Tools & Advanced Strategies

## Architecture Deep Dive

### 4 Core Systems

1. **Agent System** — 19 specialized agents organized in 4 operational lanes
2. **Skills System** — 37 behavior injections composing in 3 layers: Guarantee → Enhancement → Execution
3. **Hooks System** — 20 scripts across 11 Claude Code lifecycle events
4. **State Management** — `.omc/` directory structure persisting across context resets

### Agent Lanes

**Build/Analysis Lane** (development lifecycle):
- `explore` (haiku) — Codebase discovery, file mapping, pattern matching
- `analyst` (opus) — Requirements analysis, constraint discovery
- `planner` (opus) — Task sequencing, execution planning
- `architect` (opus) — System design, trade-off analysis (READ-ONLY)
- `debugger` (sonnet) — Root-cause analysis, stack trace resolution
- `executor` (sonnet) — Code implementation, refactoring (workhorse agent)
- `verifier` (sonnet) — Completion verification, evidence-based checks
- `tracer` (sonnet) — Causal analysis with competing hypotheses

**Review Lane** (quality gates):
- `security-reviewer` (sonnet/opus) — OWASP Top 10, secrets detection, unsafe patterns
- `code-reviewer` (opus) — Severity-rated feedback, SOLID checks, logic defects

**Domain Lane** (specialized expertise):
- `test-engineer` (sonnet) — Test strategy, TDD, flaky test hardening
- `designer` (sonnet) — UI/UX design and implementation
- `writer` (haiku) — Technical docs (README, API docs)
- `qa-tester` (sonnet) — Interactive CLI testing via tmux
- `scientist` (sonnet) — Data analysis, statistical reasoning
- `git-master` (sonnet) — Atomic commits, rebasing, history management
- `document-specialist` (sonnet) — External documentation lookup
- `code-simplifier` (opus) — Simplifies code for clarity and maintainability

**Coordination Lane**:
- `critic` (opus) — Gap analysis, multi-angle validation of plans

### Tier Variants

Some agents have tier variants for cost optimization:
- `architect` / `architect-medium` / `architect-low`
- `executor` / `executor-high` / `executor-low`
- `explore` / `explore-high`
- `designer` / `designer-high` / `designer-low`
- `security-reviewer` / `security-reviewer-low`
- `scientist` / `scientist-high`

Total with variants: 29 agent definitions. Use lowest viable tier — reserve Opus for complex reasoning.

---

## Hooks System (20 Hooks, 11 Events)

### Event-Hook Map

| Event | Scripts | Timeout | Purpose |
|-------|---------|---------|---------|
| **UserPromptSubmit** | keyword-detector.mjs, skill-injector.mjs | 5s, 3s | Magic keyword detection, skill activation |
| **SessionStart** | session-start.mjs, project-memory-session.mjs, setup-init.mjs, setup-maintenance.mjs | 5-60s | Initialization, memory loading |
| **PreToolUse** | pre-tool-enforcer.mjs | 3s | Tool usage rule enforcement |
| **PermissionRequest** | permission-handler.mjs | 5s | Bash permission validation |
| **PostToolUse** | post-tool-verifier.mjs, project-memory-posttool.mjs | 3s | Result verification, memory updates |
| **PostToolUseFailure** | post-tool-use-failure.mjs | 3s | Failure recovery guidance |
| **SubagentStart** | subagent-tracker.mjs | 3s | Agent spawn tracking |
| **SubagentStop** | subagent-tracker.mjs, verify-deliverables.mjs | 5s | Agent completion, deliverable verification |
| **PreCompact** | pre-compact.mjs, project-memory-precompact.mjs | 10s, 5s | State preservation before context compression |
| **Stop** | context-guard-stop.mjs, persistent-mode.cjs, code-simplifier.mjs | 5-10s | Mode enforcement, auto-simplification |
| **SessionEnd** | session-end.mjs | 30s | Cleanup, summary, notifications |

### How Hooks Work

Hooks inject context via `<system-reminder>` tags into Claude's context window. The keyword-detector hook scans user input for magic keywords and outputs signals like `[MAGIC KEYWORD: autopilot]` that trigger skill activation.

The `persistent-mode` hook is critical for ralph/ultrawork — it blocks Stop events with "The boulder never stops" to force continuation.

### Hook Configuration

```bash
# Disable all OMC hooks
export DISABLE_OMC=1

# Skip specific hooks
export OMC_SKIP_HOOKS="keyword-detector,notepad"

# keyword-detector is auto-disabled when OMC_TEAM_WORKER is set
```

### Code Simplifier Hook (Optional)

Disabled by default. Enable in `~/.omc/config.json`:
```json
{
  "codeSimplifier": {
    "enabled": true,
    "extensions": [".ts", ".tsx", ".js", ".jsx", ".py", ".go", ".rs"],
    "maxFiles": 10
  }
}
```

---

## MCP Tools (33 Total)

### LSP (Language Server Protocol) — 12 Tools

| Tool | Purpose |
|------|---------|
| `lsp_hover(file, line, char)` | Type info and documentation |
| `lsp_goto_definition(file, line, char)` | Navigate to symbol definition |
| `lsp_find_references(file, line, char)` | Find all usages |
| `lsp_document_symbols(file)` | File structural outline |
| `lsp_workspace_symbols(query)` | Cross-workspace symbol search |
| `lsp_diagnostics(file)` | Errors, warnings, hints for file |
| `lsp_diagnostics_directory(path)` | Directory-wide diagnostics |
| `lsp_prepare_rename(file, line, char)` | Validate rename operation |
| `lsp_rename(file, line, char, newName)` | Project-wide rename |
| `lsp_code_actions(file, startLine, endLine)` | Available refactoring actions |
| `lsp_code_action_resolve(action)` | Detailed action info |
| `lsp_servers()` | List available language servers |

Requires installed language servers: typescript-language-server, pylsp, rust-analyzer, gopls.

### AST Grep — 2 Tools

| Tool | Purpose |
|------|---------|
| `ast_grep_search(pattern, lang)` | Structural code search using AST patterns |
| `ast_grep_replace(pattern, replacement, lang, dryRun?)` | Structural code replacement |

Meta-variables: `$VAR` (single node), `$$$` (multiple nodes). Supports 15+ languages.

### Notepad — 6 Tools

| Tool | Purpose |
|------|---------|
| `notepad_read()` | Read full notepad |
| `notepad_write_priority(content)` | Highest-priority note |
| `notepad_write_working(content)` | General working context |
| `notepad_write_manual(content)` | Manual note placement |
| `notepad_prune()` | Clean up old notes |
| `notepad_stats()` | Notepad statistics |

Storage: `.omc/notepad.md` — survives context compaction.

### Project Memory — 4 Tools

| Tool | Purpose |
|------|---------|
| `project_memory_read()` | Read all project memory |
| `project_memory_write(content)` | Overwrite entire memory |
| `project_memory_add_note(note)` | Add informational note |
| `project_memory_add_directive(directive)` | Add strict rule for agents |

Notes = observations. Directives = rules agents must follow.

### State Management — 5 Tools

| Tool | Purpose |
|------|---------|
| `state_read(mode)` | Read mode state |
| `state_write(mode, state)` | Save mode state |
| `state_clear(mode)` | Delete state |
| `state_list_active()` | List active sessions |
| `state_get_status(session_id)` | Session status summary |

States older than 2 hours are treated as inactive.

### Other Tools

| Tool | Purpose |
|------|---------|
| `session_search(query)` | Search past session transcripts |
| `trace_timeline()` | Chronological agent flow trace |
| `trace_summary()` | Aggregated statistics on hooks/keywords/skills |
| `python_repl(code)` | Persistent Python execution environment |
| `shared_memory_*` | Cross-agent shared memory (write/read/list/delete/cleanup) |

---

## Verification Protocol

### 3-Tier Verification

| Tier | Agent | Model | When | Cost |
|------|-------|-------|------|------|
| **LIGHT** | architect-low | Haiku | <5 files, <100 lines, full test coverage | 1x |
| **STANDARD** | architect-medium | Sonnet | Default for typical changes | 5x |
| **THOROUGH** | architect | Opus | >20 files, security/architecture changes | 20x |

**Auto-escalation to THOROUGH:** Changes affecting authentication, permissions, credentials, environment config, schemas, type definitions, tsconfig.

### Evidence Requirements

| Claim | Required Evidence |
|-------|------------------|
| Fix | Passing tests |
| Implementation | Clean diagnostics + successful build |
| Refactor | Passing tests |
| Debug | Root cause + specific file:line |

All evidence must be fresh (within 5 minutes).

---

## Team Mode Details

### Command Format
```
/oh-my-claudecode:team <count>:<type> "task description"
```

### Agent Types
- `executor` — General implementation (default)
- `debugger` — Build/type error fixing
- `designer` — UI/frontend work
- `codex` — Codex CLI workers (requires tmux)
- `gemini` — Gemini CLI workers (requires tmux)

### Pipeline
```
team-plan → team-prd → team-exec → team-verify → team-fix (loop)
```

### CLI Management
```bash
omc team 2:codex "review auth module"
omc team status review-auth-module
omc team shutdown review-auth-module --force
```

---

## Autopilot 5-Stage Pipeline

| Stage | Agents | Purpose |
|-------|--------|---------|
| **1. Expansion** | analyst, architect | Clarify requirements, generate specs |
| **2. Planning** | planner, critic | Create roadmap, review for completeness |
| **3. Execution** | executor (+ parallel agents) | Write code |
| **4. QA** | verifier, test-engineer | Build/test validation, auto-fix loops |
| **5. Validation** | security-reviewer, code-reviewer | Final quality/security assessment |

State persists to `.omc/state/autopilot-state.json`.

---

## Cost Optimization Strategies

1. **Use lowest viable tier** — Haiku for lookups, Sonnet for implementation, Opus only for architecture/review
2. **eco modifier** — Append to autopilot/ralph/ultrawork to route toward cheaper tiers
3. **LIGHT verification** — Small changes with full test coverage skip expensive Opus review
4. **Skip autopilot stages** — Configuration allows skipping expansion/validation for known-scope work
5. **Tiered verification saves ~40%** compared to always using THOROUGH

---

## Configuration

### Config Priority
```
Defaults → User (~/.config/claude-omc/config.jsonc) → Project (.claude/omc.jsonc) → Env Variables
```

### Key Config Options

**Magic keyword customization** — Modify triggers in `config.jsonc`
**Per-agent model override** — Route specific agents to different tiers
**Parallel execution toggle** — `OMC_PARALLEL_EXECUTION=false` for sequential
**HUD presets** — minimal/focused/full in `~/.claude/settings.json`

### HUD Configuration
```json
{
  "omcHud": {
    "preset": "focused",
    "elements": {
      "cwd": true,
      "gitBranch": true,
      "showTokens": true
    }
  }
}
```

---

## Custom Skills

| Scope | Path | Shared? |
|-------|------|---------|
| Project | `.omc/skills/` | Version-controlled with team |
| User | `~/.claude/skills/omc-learned/` | All projects |

### Management
```
/oh-my-claudecode:skill list          # List all skills
/oh-my-claudecode:skill add <name>    # Add new skill
/oh-my-claudecode:skill remove <name> # Remove skill
/oh-my-claudecode:skill edit <name>   # Edit skill
/oh-my-claudecode:skill search <q>    # Search skills
/oh-my-claudecode:learner             # Auto-extract from session
/oh-my-claudecode:skillify            # Convert workflow to skill
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| OMC not activating | `/oh-my-claudecode:omc-doctor` |
| HUD not showing | `/oh-my-claudecode:hud setup` |
| Hooks not firing | Check `chmod +x ~/.claude/hooks/**/*.sh` |
| Mode stuck | `cancelomc` or `/oh-my-claudecode:cancel` |
| State corrupt | `state_clear(mode)` via MCP tool |
| Rate limited | `omc wait --start` (requires tmux) |

---

## Platform Support

| Platform | Hook Type | Notes |
|----------|-----------|-------|
| macOS | Bash (.sh) | Full support |
| Linux | Bash (.sh) | Full support |
| Windows | Node.js (.mjs) | WSL2 recommended |

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `@anthropic-ai/claude-agent-sdk` | Subagent spawning |
| `@ast-grep/napi` | AST code search/replace |
| `@modelcontextprotocol/sdk` | MCP server implementation |
| `better-sqlite3` | Local DB for state/team (ACID guarantees) |
| `vscode-languageserver-protocol` | LSP integration |
