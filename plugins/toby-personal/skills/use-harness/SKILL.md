---
name: use-harness
description: >
  This skill should be used when the user asks to "use harness", "하네스 사용",
  "harness use case", "하네스 유즈케이스", "run harness template", "하네스 템플릿",
  "harness 실행", "하네스 예제 실행", "pick a harness", "하네스 골라줘",
  "harness menu", "하네스 메뉴", "select harness use case", "하네스 선택",
  "quick harness", "하네스 빨리", "start harness", "하네스 시작해줘".
  Presents a menu of pre-built harness use cases and launches the selected one
  via the harness:harness skill. Do NOT trigger when the user wants to build
  a custom harness from scratch — use harness:harness directly for that.
version: 0.1.0
---

# Use Harness

Launch a pre-built harness use case with a single selection. This skill acts as a quick-start
menu for the `harness:harness` skill, removing the need to remember or type full prompt templates.

## Available Use Cases

| # | Category | Use Case | Pattern | Description |
|---|----------|----------|---------|-------------|
| 1 | Research & Analysis | Deep Research | Fan-out/Fan-in | Multi-angle investigation with cross-validation |
| 2 | Research & Analysis | Code Review | Fan-out/Fan-in | Parallel architecture/security/perf analysis |
| 3 | Content Creation | Website Development | Pipeline | Full-stack from wireframe to deployment |
| 4 | Content Creation | Webtoon Production | Producer-Reviewer | Story, design, layout with peer review |
| 5 | Media & Marketing | YouTube Content | Supervisor | Trend research, scripting, SEO optimization |
| 6 | Media & Marketing | Marketing Campaign | Producer-Reviewer | Market research, copy, visuals, A/B testing |
| 7 | Engineering | Tech Documentation | Pipeline | API docs from codebase analysis |
| 8 | Engineering | Data Pipeline | Hierarchical | Schema, ETL, validation, monitoring |

## Workflow

### Step 1: Display all use cases

First, print the **full menu** as a formatted text block so the user can see every option
at a glance:

```
🔧 Harness Use Cases

  Research & Analysis
    1. Deep Research       — Multi-angle investigation with cross-validation (Fan-out/Fan-in)
    2. Code Review         — Parallel architecture/security/perf analysis (Fan-out/Fan-in)

  Content Creation
    3. Website Development — Full-stack pipeline from wireframe to deployment (Pipeline)
    4. Webtoon Production  — Story, design, layout with peer review (Producer-Reviewer)

  Media & Marketing
    5. YouTube Content     — Trend research, scripting, SEO optimization (Supervisor)
    6. Marketing Campaign  — Market research, copy, visuals, A/B testing (Producer-Reviewer)

  Engineering
    7. Tech Documentation  — API docs from codebase analysis (Pipeline)
    8. Data Pipeline       — Schema, ETL, validation, monitoring (Hierarchical)
```

### Step 2: Select via AskUserQuestion

After displaying the full menu, use AskUserQuestion with **4 category options**.
Each category label includes its two use case numbers so the user knows what's inside:

- **Research & Analysis (1-2)** — Deep Research, Code Review
- **Content Creation (3-4)** — Website Development, Webtoon Production
- **Media & Marketing (5-6)** — YouTube Content, Marketing Campaign
- **Engineering (7-8)** — Tech Documentation, Data Pipeline

If the user picks "Other", ask them to describe their custom use case as free text,
then pass that directly to the harness skill.

### Step 3: Narrow down within category

After the user picks a category, use AskUserQuestion again with the **2 specific use cases**
in that category. This gives a clean two-step selection: category → use case.

If the category has only one match (user already named a specific use case in "Other"),
skip this step.

### Step 4: Load the prompt

Read the selected use case's full prompt from `references/use-cases.md`.
The file contains numbered sections (## 1. Deep Research, etc.) with the exact prompt
in a fenced code block.

### Step 5: Confirm and customize (optional)

Before launching, show the user the selected prompt and ask if they want to customize it.
If the user provides additional context (e.g., "but use Vue instead of React"), append
that to the base prompt.

### Step 6: Launch harness

Invoke the `harness:harness` skill with the final prompt. Pass the prompt as the skill argument:

```
Skill: harness:harness
Args: <the composed prompt>
```

The harness skill handles the full 6-phase workflow: domain analysis, team architecture,
agent generation, skill generation, integration, and validation.

## Architecture Patterns Reference

For context when the user asks about patterns:

- **Pipeline** — Sequential phases, each feeding the next
- **Fan-out/Fan-in** — Parallel work streams merged into one output
- **Expert Pool** — Context-selective agent routing
- **Producer-Reviewer** — Generation + quality review loop
- **Supervisor** — Central agent distributing and coordinating tasks
- **Hierarchical Delegation** — Recursive sub-task delegation

## Edge Cases

- **harness:harness not installed**: Inform the user that the harness plugin is required.
  Link to https://github.com/revfactory/harness for installation.
- **Custom use case**: If the user picks "Other" at the category step, ask them to describe
  their custom use case as free text, then compose a prompt in the same style ("Build a
  harness for...") and pass it through.
- **User wants to modify a template**: Append modifications to the base prompt before launching.
