---
name: handoff
description: >
  Use this skill to write a forward-looking handoff document that prepares the NEXT
  Claude Code session to pick up where this one stops. Generates a compact markdown
  file (~2K tokens) under `.claude/reports/handoff/` with Summary, Key Decisions,
  Traps to Avoid, Working Agreements, Relevant Files (with line numbers), Open Work
  (status-form only, never imperative), and a Prompt for New Chat that includes a
  verification instruction.
  Trigger on "handoff", "hand off", "세션 인계", "인계 문서", "다음 세션으로 넘겨",
  "end-of-session handoff", "session handoff", "세션 종료 전에 정리해",
  "handoff 문서 만들어", "handoff 써줘", "write a handoff", "prepare next session",
  "세션 넘기기 전에", "핸드오프".
  Also trigger when the user is about to run `/clear`, close the terminal, end the day,
  or says something like "let's wrap up this session", "세션 끝내기 전에 정리하자".
  Do NOT trigger for `save-conversation` (which is a retrospective transcript log, not a
  forward-looking handoff), git commit messages, PRD writing, or CLAUDE.md updates.
user-invocable: true
version: 0.1.0
---

# handoff

Write a compact, forward-looking document that lets the **next** Claude Code session resume this work without re-explaining everything. The document is a *hypothesis for the next session to verify*, not a fact sheet — it names files and line numbers so the next session can confirm claims against live code.

## Design principles

- **Status, not commands.** Open Work is written as state ("Retry logic is not yet implemented; depends on backoff util"). Never imperative ("Implement retry logic"). Commands cause the next session to act blindly; status lets it decide.
- **Line-numbered file references.** `src/auth/TokenService.kt:L45-L72 — refresh logic, race condition suspected` beats "look at TokenService".
- **Record failures.** Success lives in code; failure lives nowhere unless you write it here. The "Traps to Avoid" section is the single biggest value of a handoff.
- **No CLAUDE.md duplication.** The next session already loads CLAUDE.md. Repeating it here wastes tokens and buries the handoff-specific signal.
- **Budget ~2000 tokens.** Offload detail into separate reports under `.claude/reports/` and link to them; keep the handoff itself short enough to read in one pass.

## Workflow

### Step 1: Resolve paths

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
HANDOFF_DIR="${PROJECT_ROOT}/.claude/reports/handoff"
mkdir -p "${HANDOFF_DIR}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILENAME="${HANDOFF_DIR}/handoff-${TIMESTAMP}.md"
```

Use the git root, not `pwd` — matches the rest of this plugin's skills and works from subdirectories.

### Step 2: Gather inputs before writing

In parallel, gather:

- Conversation so far — what was attempted, what was decided, what was discarded.
- `git status` — uncommitted work in progress.
- `git log --oneline -20` — commits created this session.
- `git diff --stat` — scope of uncommitted edits.
- Any files the user explicitly flagged as "important" or "risky" during the session.

### Step 3: Write the document

Use the Write tool to create `${FILENAME}` with this structure:

```markdown
# Handoff — {YYYY-MM-DD HH:MM}

Session: {branch name, commit range if any}
Model: {e.g. Opus 4.7 (1M context)}
Handoff target: next Claude Code session on the same task

## Summary
{1–3 sentences. What was this session about? What shifted?}

## Key Decisions
- {Decision} — because {rationale}. Alternatives considered: {X (rejected: reason), Y (rejected: reason)}.
- ...

## Traps to Avoid
- {Approach that looked good but failed} — {why it broke, or which assumption was wrong}.
- {Subtle constraint easy to miss} — {where it lives in code or docs}.
- ...

## Working Agreements
- {User preference that emerged this session, e.g. "review diffs before committing", "한국어로 답변"}.
- ...

## Relevant Files
- `path/to/file.ext:Lstart-Lend` — {why this matters to the next session}.
- `path/to/other.ext:L123` — {specific line of interest}.
- ...

## Open Work
{Write as STATUS, not COMMANDS. Examples:}
- The retry path is scaffolded in `TokenService.kt:L45-L72` but the backoff utility it depends on is not finalized — blocker pending.
- Integration test `AuthFlowSpec` currently skips the refresh case (see `@Disabled` marker) because the mock HTTP fixture is stale.
- {NOT: "Implement retry logic" — that's imperative and skips verification.}

## Pointers to deeper reports (optional)
- `.claude/reports/impl/FEAT-123-impl.md` — full implementation notes
- `.claude/reports/arch/FEAT-123-decisions.md` — ADR-level decisions
- (Omit this section if there are none.)

## Prompt for New Chat

Copy-paste this into the next session:

> I'm resuming work from a handoff document at `.claude/reports/handoff/handoff-{TIMESTAMP}.md`.
>
> Please:
> 1. Read CLAUDE.md first. Do NOT restate anything already covered there.
> 2. Read the handoff file listed above.
> 3. For every file referenced under "Relevant Files", use the Read tool to verify the file exists and that the cited lines still match what the handoff claims. Treat the handoff as a HYPOTHESIS, not fact — the previous session may have been confused when writing it.
> 4. Run `git status` and `git log --oneline -10` so you see what has actually moved since the handoff was written.
> 5. Report your verification results: which claims confirmed, which diverged, what moved. Then WAIT for my instructions — do not start implementing anything on your own.
```

### Step 4: Enforce the writing rules

Before returning to the user, re-read the draft and check:

- [ ] No imperative verbs in "Open Work" (no "Implement", "Fix", "Add" — rewrite as status if found).
- [ ] Every file reference has a line range or single line number.
- [ ] No section restates what CLAUDE.md already says (architecture style, coding conventions, build commands).
- [ ] "Traps to Avoid" has at least one entry if the session tried more than one approach — if the session went perfectly, say so explicitly rather than leaving the section empty.
- [ ] Total size under ~2000 tokens. If longer, move detail to `.claude/reports/{impl,arch,analysis}/` and reference it from the Pointers section.

Fix any violations before saving.

### Step 5: Confirm to the user

Tell the user:

> "Handoff 문서를 작성했습니다: `.claude/reports/handoff/handoff-{TIMESTAMP}.md`"

Then show the first 20–30 lines so they can spot-check the Summary / Key Decisions / Traps sections before ending the session.

## Notes

- **Do not auto-commit the handoff.** Whether `.claude/reports/` is gitignored or not is the user's call; some users commit handoffs to share across machines, others don't. The skill just writes the file.
- **Multiple handoffs per day are fine.** The timestamp suffix means you can run this at every milestone. `catchup` picks the newest by mtime.
- **This is not the same as `save-conversation`.** `save-conversation` is a retrospective transcript log of what was discussed. `handoff` is forward-looking: it's what the next session needs to know to continue. Both can coexist in the same session.
- **When the session produced no real output** (e.g. pure exploration that found nothing actionable), still write a handoff — the "Traps to Avoid" section is where negative results earn their keep.

## Background

This skill operationalizes the "Document & Clear" pattern (Tier 2 of the handoff strategy in `claude-session-context-handoff-4-layer-strategy.md`): before ending a session, dump the session's evolved understanding to a markdown file so a fresh session can pick up from a clean context without re-doing the exploration. Paired skill: `catchup` (reads this document at the start of the next session and verifies its claims).
