---
name: tdd-team
version: 0.3.0
description: >
  Use this skill when the user wants to develop features using Test-Driven Development
  with an agentic Red-Green-Refactor cycle. Trigger on "start TDD", "do TDD",
  "TDD로 개발해줘", "TDD 시작", "TDD 팀 만들어", "테스트 주도 개발",
  "red green refactor", "test-driven development", "테스트 먼저 작성하고 싶어",
  "write tests first then implement", "테스트부터 짜줘", "TDD 방식으로 구현해줘".
  Also trigger when a user describes a feature and says they want it built incrementally
  with tests, e.g. "이 기능 테스트 먼저 만들고 하나씩 구현하자", "build this with
  failing tests first", or "한 단계씩 테스트 작성하면서 개발하고 싶어".
  Do NOT trigger for simply writing unit tests after implementation, running existing
  tests, or debugging test failures — those are not TDD workflows.
---

# TDD Team

Orchestrate a 3-phase Red-Green-Refactor TDD cycle using sequential Agent calls. Each cycle implements one small behavior increment: write a failing test, make it pass with minimal code, then clean up.

## Agent Roles

| Agent | Phase | Responsibility |
|-------|-------|----------------|
| **red** | RED — Write failing test | Create a test that compiles but fails, then verify the failure |
| **green** | GREEN — Make it pass | Implement the simplest code to make the test pass |
| **refactor** | REFACTOR — Clean up | Improve code quality while keeping all tests passing |

## Setup

### 1. Detect Environment

Before starting, detect the project's language and build tool:

- Check for build files: `build.gradle.kts`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, etc.
- Determine the test command (e.g., `./gradlew test`, `npm test`, `pytest`)
- Verify the build tool works by running a quick build
- If no project exists, ask the user what language/framework to use

Capture as environment context:
```
PROJECT_ROOT: /path/to/project
SOURCE_DIR: src/main/java (or equivalent)
TEST_DIR: src/test/java (or equivalent)
TEST_CMD: ./gradlew test
TEST_FRAMEWORK: JUnit 5 / Jest / pytest / etc.
```

### 2. Decompose into TDD Tasks

This is the most important planning step. Break the user's feature request into a sequence of small, incremental behaviors — each one becomes a TDD cycle.

**How to decompose well:**
- Start from the simplest possible behavior and build outward
- Each task should add exactly one new behavior or edge case
- Later tasks can build on earlier ones
- Name each task as a behavior statement: "returns X when Y"

**Example:** User says "Calculator 클래스 만들어줘"

```
TDD Tasks:
1. add(1, 2) returns 3 (basic addition)
2. add(0, 0) returns 0 (zero case)
3. subtract(5, 3) returns 2 (basic subtraction)
4. multiply(3, 4) returns 12 (basic multiplication)
5. divide(10, 2) returns 5 (basic division)
6. divide(10, 0) throws ArithmeticException (division by zero)
```

Present the task list to the user for confirmation before starting. The user can reorder, add, remove, or modify tasks.

## TDD Cycle Execution

For each task, run three sequential Agent calls. This is simpler and more reliable than using Team/Task APIs because RED→GREEN→REFACTOR is inherently sequential.

### RED Phase

Spawn an Agent with the Red agent prompt from `references/agent-prompts.md`, appending:
- The environment context
- The current task description
- Existing source and test file paths for context

```
Execute TDD RED phase:
- Task: "{task description}"
- Environment: {environment context}
- Write a failing test, verify it fails
- Report: test file path, test method name, failure message
- Save any created/modified files
```

Wait for completion. Check the result:
- **Test fails** → proceed to GREEN
- **Test already passes** → STOP. A passing test in the RED phase means either (a) the behavior is already implemented elsewhere — confirm with the user and skip the cycle for this requirement, or (b) the test isn't actually exercising the new behavior — rewrite it to be more specific before moving on. Do NOT silently fall through to REFACTOR.
- **Build fails** → ask the agent to fix compilation, re-verify

### GREEN Phase

Spawn an Agent with the Green agent prompt, including:
- The failing test file path and failure message from RED
- The current source code for context

```
Execute TDD GREEN phase:
- Failing test: {test file path and method}
- Failure message: {from RED phase}
- Environment: {environment context}
- Write the MINIMUM code to make the test pass
- Run ALL tests, confirm everything passes
- Report: files modified, all test results
```

Wait for completion. If tests still fail, send the failure back and ask to retry.

### REFACTOR Phase

Spawn an Agent with the Refactor agent prompt, including:
- All current source and test files
- What was implemented in this cycle

```
Execute TDD REFACTOR phase:
- Just implemented: {summary of RED+GREEN}
- Environment: {environment context}
- Look for: duplication, naming, complexity, test readability
- Run ALL tests after each change
- If code is clean enough, report "no refactoring needed"
- Report: what changed and why, final test results
```

### Cycle Summary and User Checkpoint

After each cycle completes, present a summary to the user:

```
── TDD Cycle {N} Complete ──
Task: {task description}

RED:    ✅ Test written: UserServiceTest.shouldReturnUserById()
GREEN:  ✅ Implementation: UserService.findById() — hardcoded return
REFACTOR: ✅ Extracted UserRepository interface

Tests: 5 passed, 0 failed
Files changed: UserService.java, UserServiceTest.java, UserRepository.java

── Progress ──
[x] 1. findById returns user when exists
[x] 2. findById throws when not found
[ ] 3. createUser saves and returns user
[ ] 4. deleteUser removes user
[ ] 5. listUsers returns all users

Continue with task 3? (or modify the remaining tasks)
```

This checkpoint lets the user:
- Review what was done
- Modify upcoming tasks based on new understanding
- Skip tasks that are no longer needed
- Add new tasks discovered during development
- Stop the TDD session

## Progress Tracking

Maintain a running task list throughout the session. After each cycle, update the status:

```
[x] Completed tasks (with cycle number)
[>] Current task
[ ] Remaining tasks
```

Show this progress list at every user checkpoint. This gives visibility into the session's arc and helps the user decide what to focus on next.

## Key Principles

### Strict Phase Separation
- RED writes tests only (and minimal stubs for compilation)
- GREEN writes production code only (no test changes)
- REFACTOR changes no behavior (all tests must still pass)

The reason for strict separation is that it prevents the common anti-pattern of writing tests and implementation simultaneously, which defeats the purpose of TDD — you lose the confidence that the test actually tests what you think it tests.

### Simplest Implementation First
- GREEN writes the absolute minimum to pass: hardcoding is acceptable, duplication is acceptable
- Elegance comes from REFACTOR, not GREEN

This feels counterintuitive but is fundamental to TDD. The simplest implementation reveals whether the test is specific enough. If hardcoding "passes" a test that should require real logic, the test needs improvement.

### Incremental Progress
- Each cycle adds ONE behavior
- Small steps build confidence and catch errors early
- The user drives what to implement next

## Error Handling

| Situation | Action |
|-----------|--------|
| Build fails in RED | Ask agent to fix stubs, re-verify failure |
| GREEN can't pass test | Send failure output, ask to retry with different approach |
| REFACTOR breaks tests | Ask agent to revert and retry with smaller changes |
| Agent produces incorrect output | Re-read the source files, correct, and re-run tests |

## Session End

When the user finishes the TDD session, provide a final summary:
- Total cycles completed
- All files created/modified
- Final test count (passed/failed)
- Suggestions for next steps (more test cases, integration tests, etc.)

## Additional Resources

### Reference Files

For detailed agent system prompts:
- **`references/agent-prompts.md`** — Complete prompts for Red, Green, and Refactor agents including rules, workflow, and verification steps
