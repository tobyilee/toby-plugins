---
name: TDD Team
version: 0.2.0
description: >
  This skill should be used when the user asks to "start TDD", "do TDD",
  "create a TDD team", "red green refactor", "test-driven development",
  "set up TDD agents", "TDD 시작", "TDD 팀 만들어", "테스트 주도 개발",
  or wants to develop features using the TDD cycle with an agentic team.
  Provides a 3-agent team (Red, Green, Refactor) that executes the TDD
  Red-Green-Refactor cycle for each task.
---

# TDD Team

Set up and orchestrate a 3-agent team that executes the TDD Red-Green-Refactor cycle.

## Agent Roles

| Agent | Phase | Responsibility |
|-------|-------|----------------|
| **red** | RED — Write failing test | Create a test that compiles but fails, then verify the failure |
| **green** | GREEN — Make it pass | Implement the simplest code to make the test pass |
| **refactor** | REFACTOR — Clean up | Improve code quality while keeping all tests passing |

## Setup Procedure

### 1. Detect Environment

Before creating the team, detect the project's language and build tool:

- Check for build files: `build.gradle`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`, etc.
- Determine the test command (e.g., `./gradlew test`, `mvn test`, `npm test`)
- Verify the build tool works by running a quick build command
- If no project exists, ask the user what language and build tool to use, then scaffold the project

Capture these as environment variables for agent prompts:
```
PROJECT_ROOT: /path/to/project
SOURCE_DIR: src/main/java (or equivalent)
TEST_DIR: src/test/java (or equivalent)
BUILD_CMD: ./gradlew build
TEST_CMD: ./gradlew test
TEST_FRAMEWORK: JUnit 5 / Jest / pytest / etc.
```

### 2. Create Team and Spawn Agents

1. Create a team using TeamCreate (e.g., `tdd-cycle`)
2. Read agent prompts from `references/agent-prompts.md`
3. Spawn three `general-purpose` agents — **red**, **green**, **refactor** — each with:
   - The corresponding prompt from `references/agent-prompts.md`
   - Environment context appended (project root, directories, build/test commands, test framework)
   - `team_name` parameter set so agents join the team
4. Wait for all three agents to report ready before accepting tasks

## TDD Cycle Workflow

For each task the user provides, execute this cycle:

### Step 1: RED Phase

1. Create three tasks with TaskCreate: `[RED] ...`, `[GREEN] ...`, `[REFACTOR] ...`
2. Set dependencies: GREEN blocked by RED, REFACTOR blocked by GREEN
3. Assign the RED task to `red` agent via TaskUpdate
4. Send task details via SendMessage to `red`
5. Wait for `red` to report:
   - **Test fails** → Proceed to GREEN
   - **Test already passes** → Skip GREEN, go directly to REFACTOR (test still has value as regression documentation)
   - **Build fails** → Ask `red` to fix compilation issues, then re-verify

### Step 2: GREEN Phase

1. Mark RED task completed, assign GREEN task to `green`
2. Send task context: what test needs to pass, relevant file paths
3. Wait for `green` to report all tests passing
4. If tests still fail → send `green` the failure output and ask to retry

### Step 3: REFACTOR Phase

1. Mark GREEN task completed, assign REFACTOR task to `refactor`
2. Send task context with guidance on what to look for (duplication, naming, complexity)
3. Wait for `refactor` to report results
4. If any test fails after refactoring → ask `refactor` to revert and retry

### Step 4: Review and Report

1. Mark REFACTOR task completed
2. Read current source and test files to present to the user
3. Summarize what each phase accomplished
4. Ask the user for the next task or if the TDD session is complete

## Key Principles

### Strict Phase Separation
- RED writes tests only (and minimal stubs for compilation)
- GREEN writes production code only (no test changes)
- REFACTOR changes no behavior (all tests must still pass after changes)

### Simplest Implementation First
- GREEN writes the absolute minimum to pass: hardcoding is acceptable, duplication is acceptable
- Elegance comes from the REFACTOR phase, not the GREEN phase

### Test Already Passes
- When RED's test passes without new production code, skip GREEN
- The test still has value as regression documentation
- Proceed to REFACTOR to look for cleanup opportunities

### Incremental Progress
- Each cycle adds ONE behavior
- Small steps build confidence and catch errors early
- The user drives what to implement next

## Agent Communication

Use SendMessage with `type: "message"` to communicate with agents. Include in every message:
- Task number reference (e.g., "Task #3")
- Clear description of the work
- Relevant file paths
- Build/test commands to run

## Error Handling

| Situation | Action |
|-----------|--------|
| Build fails in RED | Ask `red` to fix stubs, re-verify failure |
| GREEN can't pass test | Send failure output, ask to retry with different approach |
| REFACTOR breaks tests | Ask `refactor` to revert and retry with smaller changes |
| Agent goes unresponsive | Send follow-up message; if still unresponsive, reassign to a new agent |

## Shutdown

When the user finishes the TDD session:
1. Send `shutdown_request` to each agent (red, green, refactor)
2. Wait for confirmations
3. Clean up with TeamDelete

## Additional Resources

### Reference Files

For detailed agent system prompts with full instructions:
- **`references/agent-prompts.md`** — Complete prompts for Red, Green, and Refactor agents including rules, workflow, and verification steps
