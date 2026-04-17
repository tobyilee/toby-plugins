---
name: omc-tips
description: >
  This skill should be used when the user asks about "omc", "oh-my-claudecode",
  "omc 사용법", "omc 활용", "omc guide", "omc tips", "omc cheatsheet", "omc reference",
  "omc 모드", "omc 에이전트", "omc 스킬", "which omc mode", "how to use omc",
  "omc keyword", "omc 매직 키워드", "omc commands", "omc modes comparison",
  "autopilot vs ralph", "autopilot vs team", "ralph vs ultrawork", "team mode",
  "omc agent", "omc tool", "omc 설정", "omc setup", "omc doctor", "omc pipeline",
  "omc architecture", or needs guidance on choosing OMC execution modes, agents,
  skills, or strategies. Provides a comprehensive quick-reference for
  oh-my-claudecode v4.10+ plugin.
version: 0.2.0
---

# OMC Tips — oh-my-claudecode Quick Reference

oh-my-claudecode (OMC) is a multi-agent orchestration plugin for Claude Code.
It turns Claude Code into a platform of 19 specialized agents, 37 skills, and
20 lifecycle hooks — all driven by natural-language magic keywords.

> **Last verified against OMC v4.12.x (2026-04-17).** OMC evolves fast — if you
> see a version mismatch in session-start messages, run `omc update` and
> re-verify agent/skill counts before relying on this reference.

## Architecture at a Glance

```
autopilot   (5-stage pipeline: idea → working code)
  └── ralph   (persistence loop — keeps going until verified)
       └── ultrawork   (parallel agent execution engine)
            └── agents   (19 specialists across 3 model tiers)
```

**Core flow:** User Input → Hooks (event detection) → Skills (behavior injection) → Agents (task execution) → State (progress tracking)

**Planning pipeline:** deep-interview → ralplan/plan → autopilot
**Investigation pipeline:** deep-dive → trace + deep-interview → plan → autopilot

---

## Mode Selection — Decision Tree

```
Is the task vague/unclear?
  ├─ Yes → deep-interview (then autopilot)
  └─ No → Complex multi-step project?
            ├─ Yes → Multiple independent components?
            │         ├─ Yes → team (coordinated pipeline)
            │         └─ No  → autopilot (single-lead autonomous)
            └─ No → Is it a bug?
                      ├─ Yes → Cause unclear?
                      │         ├─ Yes → deep-dive or trace
                      │         └─ No  → ralph (persist until fixed)
                      └─ No → Parallelizable?
                                ├─ Yes → ulw (ultrawork)
                                └─ No  → Just describe the task normally
```

| Mode | What It Does | When To Use |
|------|-------------|-------------|
| **autopilot** | 5-stage pipeline (Expansion→Planning→Execution→QA→Validation) | Single coherent deliverable |
| **team** | 3-5 parallel agents with file ownership | 3+ independent subtasks |
| **ralph** | Verification loop — repeats until done | Completion guarantee needed |
| **ultrawork** (ulw) | Maximum parallelism + manual oversight | Speed with control |
| **ccg** | Claude+Codex+Gemini tri-model synthesis | Multi-perspective validation |
| **ralplan** | Planner→Architect→Critic consensus loop | Unclear requirements |
| **deep-interview** | Socratic requirements clarification | Vague starting point |

**Invalid combos:** Two standalone modes together (e.g., `autopilot team`) — the second keyword is silently ignored. `eco` is a modifier only — pair it with autopilot/ralph/ultrawork.

---

## Magic Keywords — Natural Language Triggers

Include these anywhere in a prompt to activate the corresponding mode:

| Keyword | Activates | Example |
|---------|-----------|---------|
| `autopilot`, `build me` | Full autonomous pipeline | "autopilot: build a REST API" |
| `ralph`, `must complete` | Persistence loop | "ralph: fix the auth bug completely" |
| `ulw`, `ultrawork` | Parallel execution | "ulw refactor the API layer" |
| `team` | Coordinated agents | `/team 3:executor fix errors` |
| `ccg` | Tri-model synthesis | "ccg: GraphQL vs REST?" |
| `ralplan` | Consensus planning | "ralplan this feature" |
| `deep-interview` | Socratic questioning | "deep-interview: build a dashboard" |
| `deslop` | AI slop cleaner | "deslop the recent changes" |
| `deepsearch` | Codebase search | "deepsearch: where is auth?" |
| `ultrathink` | Deep reasoning | "ultrathink: why is this deadlocking?" |
| `cancelomc` | Stop active mode | "cancelomc" |

**Priority:** cancel (exclusive) → ralph → autopilot → ultrawork → others

---

## Agents — 19 Specialists in 3 Tiers

| Tier | Model | Agents |
|------|-------|--------|
| **Opus** (deep) | opus | analyst, planner, architect, critic, code-reviewer, code-simplifier |
| **Sonnet** (standard) | sonnet | executor, debugger, verifier, tracer, test-engineer, designer, qa-tester, scientist, document-specialist, git-master, security-reviewer |
| **Haiku** (fast) | haiku | explore, writer |

Typical sequence: `explore → analyst → planner → critic → executor → verifier`

Some agents have tier variants (e.g., `architect-low`, `executor-high`, `security-reviewer-low`). Override model via `model` parameter in Agent tool calls: `model: "opus"` on executor for complex tasks. See `references/detailed-reference.md` for full tier variant list.

For detailed agent capabilities, tool assignments, and lane descriptions, consult `references/detailed-reference.md`.

---

## Key Skills Quick Reference

### Execution & Orchestration
| Skill | Command | Notes |
|-------|---------|-------|
| autopilot | `/oh-my-claudecode:autopilot` | 5-stage autonomous pipeline |
| ralph | `/oh-my-claudecode:ralph` | Loop until verified. Includes ultrawork. |
| ultrawork | `/oh-my-claudecode:ultrawork` | Max parallel agents |
| team | `/oh-my-claudecode:team N:type "task"` | N agents, types: executor/debugger/designer/codex/gemini |
| ultraqa | `/oh-my-claudecode:ultraqa` | QA cycle: test→verify→fix→repeat |
| cancel | `/oh-my-claudecode:cancel` | Stop any active mode |

### Planning & Analysis
| Skill | Command |
|-------|---------|
| plan | `/oh-my-claudecode:plan` |
| ralplan | `/oh-my-claudecode:ralplan` |
| deep-interview | `/oh-my-claudecode:deep-interview` |
| deep-dive | `/oh-my-claudecode:deep-dive` |
| trace | `/oh-my-claudecode:trace` |

### Multi-Model & Research
| Skill | Command |
|-------|---------|
| ccg | `/oh-my-claudecode:ccg` |
| ask | `/oh-my-claudecode:ask` — route to claude/codex/gemini |
| omc-teams | `/oh-my-claudecode:omc-teams` — tmux CLI workers |
| sciomc | `/oh-my-claudecode:sciomc` — parallel scientist agents |
| external-context | `/oh-my-claudecode:external-context` — web doc lookup |

### Code Quality & Knowledge
| Skill | Command |
|-------|---------|
| ai-slop-cleaner | `/oh-my-claudecode:ai-slop-cleaner` |
| visual-verdict | `/oh-my-claudecode:visual-verdict` |
| deepinit | `/oh-my-claudecode:deepinit` — generate AGENTS.md across codebase |
| verify | `/oh-my-claudecode:verify` |
| self-improve | `/oh-my-claudecode:self-improve` |

### Setup & Admin
| Skill | Command |
|-------|---------|
| omc-setup | `/oh-my-claudecode:omc-setup` |
| omc-doctor | `/oh-my-claudecode:omc-doctor` |
| hud | `/oh-my-claudecode:hud` — statusline: minimal/focused/full |
| mcp-setup | `/oh-my-claudecode:mcp-setup` |

---

## Practical Examples

| Scenario | Command |
|----------|---------|
| Vague idea → code | `deep-interview "real-time dashboard for metrics"` |
| Fix all errors | `/team 3:executor "fix all TS errors in src/"` |
| Large refactoring | `ulw refactor user API into service/controller/repo` |
| Mystery bug | `deep-dive "intermittent 403 on /api/orders"` |
| Must-complete task | `ralph: migrate raw SQL to repository pattern` |
| Multi-AI opinion | `ccg: should we use GraphQL or REST?` |
| Security review | `review payment module for security issues` |
| Clean AI slop | `deslop the recently modified files` |
| Feature planning | `ralplan: implement OAuth2 with PKCE` |
| Map new codebase | `/oh-my-claudecode:deepinit` |

---

## State & Memory

| Path | Purpose | Survives Compaction? |
|------|---------|---------------------|
| `.omc/state/` | Per-mode state | Yes |
| `.omc/notepad.md` | Working memory | Yes |
| `.omc/project-memory.json` | Project knowledge | Yes (permanent) |
| `.omc/plans/` | Execution plans | Yes |
| `.omc/skills/` | Project-level custom skills | N/A |

**Memory tags:** `<remember>` (7 days), `<remember priority>` (permanent)

---

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `DISABLE_OMC` | Disable all hooks | — |
| `OMC_SKIP_HOOKS` | Skip specific hooks (comma-separated) | — |
| `OMC_STATE_DIR` | Centralized state directory | `.omc/state/` |
| `OMC_PARALLEL_EXECUTION` | Toggle parallel execution | true |
| `OMC_LSP_TIMEOUT_MS` | LSP request timeout | 15000 |

---

## CLI Helpers

```bash
omc ask claude/codex/gemini "prompt"  # Route to specific AI
omc team N:type "task"                # Start team job
omc team status                       # Inspect running jobs
omc team shutdown <name> --force      # Stop team job
omc hud                               # Render statusline
omc wait --start                      # Auto-resume on rate limit
omc session search "query" --since 7d # Search past sessions
```

---

## Additional Resources

For in-depth details on architecture, hooks, MCP tools, verification tiers, team pipelines, and cost optimization strategies, consult:

- **`references/detailed-reference.md`** — Complete architecture, hooks system, MCP tools, verification protocol, team mode details, and advanced strategies
