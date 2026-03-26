---
description: Analyze codebase in depth and document findings
argument-hint: [target-path-or-module]
allowed-tools: Read, Write, Glob, Grep, Agent, Bash(find:*), Bash(wc:*), Bash(ls:*), Bash(git:*)
model: opus
---

Analyze the target specified by $ARGUMENTS in depth. If no target is provided, analyze the current working directory.

## Phase 1: Inventory & Scoping

Build a **shared index** that all Phase 2 agents will consume. This must be thorough enough that agents don't re-explore from scratch.

### 1.1 Basic Identity
- Resolve project root via `git rev-parse --show-toplevel` (fallback: cwd)
- Detect dominant language(s), build system, and frameworks
- Classify repo type: `backend-service`, `frontend-app`, `library`, `CLI`, `plugin/doc-driven`, `monorepo`, or `other`

### 1.2 Ignore Policy
Exclude from all file counts, LOC, and analysis:
- `node_modules`, `vendor`, `dist`, `build`, `target`, `.next`, `coverage`, `__pycache__`, generated code
- Respect `.gitignore` rules

### 1.3 Metrics & Structure
- Count source files and total LOC (excluding ignored dirs)
- Map directory and package structure (up to 3 levels or until module boundaries are clear)
- Read key build/config files (build.gradle, pom.xml, package.json, Cargo.toml, Dockerfile, CI configs, etc.)

### 1.4 Key References (pass to all agents)
- List of top-level modules/packages
- Entry point files (main, index, app, routes, CLI entrypoint)
- Test directory locations
- Config/env files

## Phase 2: Adaptive Parallel Analysis

Launch **3–5 parallel Explore agents** based on repo scale:
- `source files < 30` → 3 agents (merge Agent B into A, Agent D into E)
- `30–150 files` → 4 agents (merge Agent A+B)
- `> 150 files` → 5 agents

Pass the Phase 1 shared index to each agent. Every agent must:
- Cite file paths (with line numbers when relevant) for every nontrivial claim
- Separate **observations** (what the code shows) from **inferences** (why it might be designed that way)
- Mark dimensions that don't apply as "N/A — {reason}" instead of forcing analysis

### Agent A: Topology, Entry Points & Execution Flow
- Folder/module organization and monorepo structure
- Identify all entry points (main, CLI dispatch, route handlers, event listeners)
- Trace 2–3 representative execution flows: input → orchestration → external calls → output
- Multi-module dependency graph (internal modules only)

### Agent B: Dependencies, Integrations & Boundaries
- External library dependencies and their roles
- External system integrations (APIs, DBs, message queues, file systems, subprocess calls)
- Environment variables, config files, and secrets management
- Trust boundaries: where user input enters, where privileged operations occur
- Build configuration and plugin usage

### Agent C: Core Abstractions, Conventions & Domain Model
- Naming conventions (classes, methods, variables, constants)
- Coding style patterns (null handling, functional style, error propagation)
- Key interfaces, abstract classes, and extension points
- Data model: entities, schemas, state management, persistence patterns
- Identify notable design patterns only when the match is strong (don't force GoF labels)
- Architectural patterns (layered, hexagonal, DDD, etc.) with concrete evidence

### Agent D: Complexity, Risks & Maintainability
- File size distribution and top 10 largest files
- Coupling analysis (package dependencies, circular references)
- Cohesion assessment per package/module
- Error handling and exception hierarchy patterns
- Git change hotspots (most frequently changed files via `git log --format= --name-only | sort | uniq -c | sort -rn | head -20`) — skip if not a git repo
- Security surface: hardcoded secrets, unsafe input handling, dangerous command execution

### Agent E: Testing, Build & Developer Workflow
- Test framework stack and assertion libraries
- Test directory structure and naming conventions
- Test-to-source ratio and coverage breadth
- Read 3–5 test files (prioritize: most-referenced class tests, most recently modified tests)
- Integration vs unit test separation
- Build commands, CI/CD pipeline configuration (GitHub Actions, GitLab CI, etc.)
- Dockerfile / container setup if present
- Developer onboarding: README quality, setup instructions, contributing guide

## Phase 3: Reconciliation & Report

### 3.1 Synthesis Rules
Before writing the report:
- **Deduplicate** overlapping findings from multiple agents
- **Resolve conflicts**: if agents disagree, present both views with evidence and note the discrepancy
- **Evidence check**: remove or flag claims that lack file path references
- **Confidence labeling**: mark inferences explicitly as such

### 3.2 Output File
Save as `code-{target-slug}-{YYYYMMDD-HHmmss}.md` in the project root.
- `target-slug`: sanitized target name (e.g., `toby-plugins`, `src-main`)
- If the target is the project root, use the repo directory name

### 3.3 Report Structure

```markdown
# [Target Name] Codebase Analysis
**Date:** {date}  **Target:** {path}  **Scale:** {files} files, {LOC} LOC  **Type:** {repo type}

## Executive Summary
3–5 bullet points capturing the most important findings. A busy developer should get the picture from this section alone.

## 1. Topology & Execution Flow
Module structure, entry points, and representative request/command flows.

## 2. Dependencies, Integrations & Boundaries
External libraries, system integrations, config, env vars, trust boundaries.

## 3. Core Abstractions & Architecture
Key interfaces, domain model, design patterns (with evidence), architectural style.

## 4. Complexity, Risks & Maintainability
File size outliers, coupling, hotspots, error handling, security surface.

## 5. Testing, Build & Developer Workflow
Test strategy, CI/CD, containerization, onboarding experience.

## 6. Top Risks & Open Questions
Ranked list of concerns that warrant further investigation. Each with severity (high/medium/low) and affected files.

## 7. Recommended Reading Order
Numbered list of files/modules to read for fastest codebase understanding.

## Appendix
### A. LSP Diagnostics (if available)
Summary table by severity with file locations. Omit section if no data.

### B. Key Insights (optional)
3–5 educational insights for junior developers. Each references specific code and explains **why**, not just **what**. Label inferences explicitly.
```

### 3.4 Confirm
After saving, tell the user the file path and show the Executive Summary section as a preview.
