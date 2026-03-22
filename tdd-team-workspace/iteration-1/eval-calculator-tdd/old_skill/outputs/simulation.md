# TDD Team Skill Simulation: Calculator Class

**Task:** "Calculator 클래스를 TDD로 만들어줘. add, subtract, multiply, divide 기능이 필요해"

---

## Phase 0: Environment Detection

The skill instructs us to detect the project's language and build tool before creating the team.

### Actions Taken

1. **Scan for build files:** Check for `build.gradle`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`, etc.
2. **Result (simulated):** Found `build.gradle.kts` at project root.
3. **Determine test command:** `./gradlew test`
4. **Verify build tool works:** Run `./gradlew build` -- succeeds.
5. **Detect framework:** Scan `build.gradle.kts` for test dependencies -- find JUnit 5 (`org.junit.jupiter`).

### Captured Environment Variables

```
PROJECT_ROOT: /Users/tobylee/workspace/calculator-project
SOURCE_DIR: src/main/java
TEST_DIR: src/test/java
BUILD_CMD: ./gradlew build
TEST_CMD: ./gradlew test
TEST_FRAMEWORK: JUnit 5
```

---

## Phase 1: Task Planning

The user wants 4 features: `add`, `subtract`, `multiply`, `divide`. Following the skill's "Incremental Progress" principle -- each cycle adds ONE behavior -- we plan 4 TDD cycles:

| Cycle | Feature | Description |
|-------|---------|-------------|
| 1 | `add` | Calculator.add(a, b) returns a + b |
| 2 | `subtract` | Calculator.subtract(a, b) returns a - b |
| 3 | `multiply` | Calculator.multiply(a, b) returns a * b |
| 4 | `divide` | Calculator.divide(a, b) returns a / b (including division by zero handling) |

We present this plan to the user before proceeding.

### User-Facing Message

> **TDD Plan for Calculator**
>
> I'll implement 4 features, one per TDD cycle:
> 1. `add(a, b)` -- addition
> 2. `subtract(a, b)` -- subtraction
> 3. `multiply(a, b)` -- multiplication
> 4. `divide(a, b)` -- division (with zero-division handling)
>
> Starting with cycle 1: `add`

---

## Phase 2: Team Setup

### Step 2.1: TeamCreate

```
Tool: TeamCreate
  name: "tdd-cycle"
```

### Step 2.2: Spawn Agents

Read agent prompts from `references/agent-prompts.md`, append environment block to each, and spawn 3 agents.

**Agent 1: red**
```
Tool: SpawnAgent
  type: "general-purpose"
  name: "red"
  team_name: "tdd-cycle"
  prompt: |
    Role: RED agent in a TDD (Test-Driven Development) cycle team.
    Mission: Write a FAILING test for a given task, then verify it fails.
    [... full RED prompt from agent-prompts.md ...]

    ## Environment
    - Project root: /Users/tobylee/workspace/calculator-project
    - Source directory: src/main/java
    - Test directory: src/test/java
    - Build command: ./gradlew build
    - Test command: ./gradlew test
    - Test framework: JUnit 5
```

**Agent 2: green**
```
Tool: SpawnAgent
  type: "general-purpose"
  name: "green"
  team_name: "tdd-cycle"
  prompt: |
    Role: GREEN agent in a TDD (Test-Driven Development) cycle team.
    Mission: Make the failing test PASS with the SIMPLEST possible implementation.
    [... full GREEN prompt from agent-prompts.md ...]

    ## Environment
    - Project root: /Users/tobylee/workspace/calculator-project
    - Source directory: src/main/java
    - Test directory: src/test/java
    - Build command: ./gradlew build
    - Test command: ./gradlew test
    - Test framework: JUnit 5
```

**Agent 3: refactor**
```
Tool: SpawnAgent
  type: "general-purpose"
  name: "refactor"
  team_name: "tdd-cycle"
  prompt: |
    Role: REFACTOR agent in a TDD (Test-Driven Development) cycle team.
    Mission: Improve code quality while keeping ALL tests passing.
    [... full REFACTOR prompt from agent-prompts.md ...]

    ## Environment
    - Project root: /Users/tobylee/workspace/calculator-project
    - Source directory: src/main/java
    - Test directory: src/test/java
    - Build command: ./gradlew build
    - Test command: ./gradlew test
    - Test framework: JUnit 5
```

**Wait for all 3 agents to report ready.**

---

## Cycle 1: `add(a, b)`

### Step 1: Create Tasks with Dependencies

```
Tool: TaskCreate
  title: "[RED] Write failing test for Calculator.add(a, b)"
  description: |
    Write a JUnit 5 test that:
    - Creates a Calculator instance
    - Calls add(2, 3)
    - Asserts the result equals 5
    Create a minimal Calculator stub in src/main/java with add() throwing UnsupportedOperationException.
    Test file: src/test/java/CalculatorTest.java
  team_name: "tdd-cycle"
  → Returns task_id: 1

Tool: TaskCreate
  title: "[GREEN] Implement Calculator.add(a, b) to pass test"
  description: |
    Make the failing add() test pass with the simplest implementation.
    Only modify production code in src/main/java/Calculator.java.
  team_name: "tdd-cycle"
  blocked_by: [1]
  → Returns task_id: 2

Tool: TaskCreate
  title: "[REFACTOR] Clean up after Calculator.add(a, b)"
  description: |
    Review Calculator.java and CalculatorTest.java for refactoring opportunities.
    Ensure all tests still pass after changes.
  team_name: "tdd-cycle"
  blocked_by: [2]
  → Returns task_id: 3
```

### Step 2: RED Phase

**Assign and message the red agent:**

```
Tool: TaskUpdate
  task_id: 1
  assigned_to: "red"
  status: "in_progress"

Tool: SendMessage
  to: "red"
  type: "message"
  body: |
    Task #1: [RED] Write failing test for Calculator.add(a, b)

    Write a JUnit 5 test in src/test/java/CalculatorTest.java:
    - Create a Calculator instance
    - Call add(2, 3) and assert the result is 5
    - Create a minimal stub Calculator class in src/main/java/Calculator.java
      with add() that throws UnsupportedOperationException

    After writing, run: ./gradlew test
    Verify the test compiles but FAILS, then report back.
```

**Red agent works and reports back (simulated):**

> SendMessage from red:
> Task #1 complete.
> - Created `src/test/java/CalculatorTest.java` with `testAdd()` method
> - Created stub `src/main/java/Calculator.java` with `add()` throwing `UnsupportedOperationException`
> - Build: SUCCESS
> - Test: FAILED (1 test, 1 failure)
> - Failure: `java.lang.UnsupportedOperationException` in `testAdd`
> - Status: RED confirmed

**Files created by red agent:**

`src/test/java/CalculatorTest.java`:
```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class CalculatorTest {
    @Test
    void testAdd() {
        Calculator calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
    }
}
```

`src/main/java/Calculator.java` (stub):
```java
public class Calculator {
    public int add(int a, int b) {
        throw new UnsupportedOperationException("Not implemented");
    }
}
```

### Step 3: GREEN Phase

**Mark RED done, assign GREEN:**

```
Tool: TaskUpdate
  task_id: 1
  status: "completed"

Tool: TaskUpdate
  task_id: 2
  assigned_to: "green"
  status: "in_progress"

Tool: SendMessage
  to: "green"
  type: "message"
  body: |
    Task #2: [GREEN] Implement Calculator.add(a, b) to pass test

    The failing test is in src/test/java/CalculatorTest.java — method testAdd().
    It calls Calculator.add(2, 3) and expects 5.

    Implement the simplest code in src/main/java/Calculator.java to pass.
    Do NOT modify the test. Run: ./gradlew test
    Verify ALL tests pass, then report back.
```

**Green agent works and reports back (simulated):**

> SendMessage from green:
> Task #2 complete.
> - Modified `src/main/java/Calculator.java`: implemented `add()` as `return a + b;`
> - All tests: PASSED (1 test, 0 failures)
> - Status: GREEN confirmed

**Updated `Calculator.java`:**
```java
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
}
```

### Step 4: REFACTOR Phase

**Mark GREEN done, assign REFACTOR:**

```
Tool: TaskUpdate
  task_id: 2
  status: "completed"

Tool: TaskUpdate
  task_id: 3
  assigned_to: "refactor"
  status: "in_progress"

Tool: SendMessage
  to: "refactor"
  type: "message"
  body: |
    Task #3: [REFACTOR] Clean up after Calculator.add(a, b)

    Current files:
    - src/main/java/Calculator.java
    - src/test/java/CalculatorTest.java

    Look for: naming improvements, duplication, test readability.
    Run: ./gradlew test after any changes.
    Report what changed (or "no refactoring needed").
```

**Refactor agent works and reports back (simulated):**

> SendMessage from refactor:
> Task #3 complete.
> - Reviewed Calculator.java and CalculatorTest.java.
> - Code is clean and minimal at this stage. No refactoring needed.
> - All tests: PASSED (1 test, 0 failures)
> - Status: REFACTOR complete (no changes)

### Step 5: Mark complete and report to user

```
Tool: TaskUpdate
  task_id: 3
  status: "completed"
```

### User-Facing Report after Cycle 1

> **Cycle 1 Complete: `add(a, b)`**
>
> | Phase | Result |
> |-------|--------|
> | RED | `testAdd()` written -- test fails with `UnsupportedOperationException` |
> | GREEN | `add()` implemented as `return a + b` -- test passes |
> | REFACTOR | No changes needed -- code is clean |
>
> **Tests: 1 passed, 0 failed**
>
> Moving to cycle 2: `subtract`...

---

## Cycle 2: `subtract(a, b)`

### Step 1: Create Tasks with Dependencies

```
Tool: TaskCreate
  title: "[RED] Write failing test for Calculator.subtract(a, b)"
  description: |
    Add a test to CalculatorTest.java:
    - Call subtract(5, 3) and assert the result equals 2
    Create a minimal subtract() stub in Calculator.java if it doesn't exist.
  team_name: "tdd-cycle"
  → Returns task_id: 4

Tool: TaskCreate
  title: "[GREEN] Implement Calculator.subtract(a, b) to pass test"
  description: |
    Make the failing subtract() test pass with the simplest implementation.
    Only modify production code.
  team_name: "tdd-cycle"
  blocked_by: [4]
  → Returns task_id: 5

Tool: TaskCreate
  title: "[REFACTOR] Clean up after Calculator.subtract(a, b)"
  description: |
    Review all code for refactoring opportunities.
    Ensure all tests still pass.
  team_name: "tdd-cycle"
  blocked_by: [5]
  → Returns task_id: 6
```

### Step 2: RED Phase

```
Tool: TaskUpdate
  task_id: 4
  assigned_to: "red"
  status: "in_progress"

Tool: SendMessage
  to: "red"
  type: "message"
  body: |
    Task #4: [RED] Write failing test for Calculator.subtract(a, b)

    Add a test to src/test/java/CalculatorTest.java:
    - testSubtract(): Calculator.subtract(5, 3) should equal 2
    Add a stub subtract() to src/main/java/Calculator.java that throws
    UnsupportedOperationException.

    Run: ./gradlew test
    Verify the NEW test fails while the existing add test still passes.
    Report back.
```

**Red agent works and reports back (simulated):**

> SendMessage from red:
> Task #4 complete.
> - Added `testSubtract()` to `CalculatorTest.java`
> - Added `subtract()` stub to `Calculator.java` (throws UnsupportedOperationException)
> - Build: SUCCESS
> - Tests: 1 passed (testAdd), 1 failed (testSubtract)
> - Failure: `java.lang.UnsupportedOperationException` in `testSubtract`
> - Status: RED confirmed

**Updated `CalculatorTest.java`:**
```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class CalculatorTest {
    @Test
    void testAdd() {
        Calculator calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
    }

    @Test
    void testSubtract() {
        Calculator calc = new Calculator();
        assertEquals(2, calc.subtract(5, 3));
    }
}
```

**Updated `Calculator.java` (with stub):**
```java
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }

    public int subtract(int a, int b) {
        throw new UnsupportedOperationException("Not implemented");
    }
}
```

### Step 3: GREEN Phase

```
Tool: TaskUpdate
  task_id: 4
  status: "completed"

Tool: TaskUpdate
  task_id: 5
  assigned_to: "green"
  status: "in_progress"

Tool: SendMessage
  to: "green"
  type: "message"
  body: |
    Task #5: [GREEN] Implement Calculator.subtract(a, b) to pass test

    The failing test is testSubtract() in src/test/java/CalculatorTest.java.
    It calls Calculator.subtract(5, 3) and expects 2.

    Implement the simplest code in src/main/java/Calculator.java.
    Do NOT modify tests. Run: ./gradlew test
    Verify ALL tests pass (both testAdd and testSubtract).
```

**Green agent works and reports back (simulated):**

> SendMessage from green:
> Task #5 complete.
> - Modified `Calculator.java`: implemented `subtract()` as `return a - b;`
> - All tests: PASSED (2 tests, 0 failures)
> - Status: GREEN confirmed

### Step 4: REFACTOR Phase

```
Tool: TaskUpdate
  task_id: 5
  status: "completed"

Tool: TaskUpdate
  task_id: 6
  assigned_to: "refactor"
  status: "in_progress"

Tool: SendMessage
  to: "refactor"
  type: "message"
  body: |
    Task #6: [REFACTOR] Clean up after Calculator.subtract(a, b)

    Current files:
    - src/main/java/Calculator.java (has add, subtract)
    - src/test/java/CalculatorTest.java (has testAdd, testSubtract)

    Look for: duplication in tests (e.g. repeated Calculator instantiation),
    naming, structure.
    Run: ./gradlew test after any changes.
```

**Refactor agent works and reports back (simulated):**

> SendMessage from refactor:
> Task #6 complete.
> - Extracted `Calculator calc` into a `@BeforeEach` setup method to remove duplication.
> - All tests: PASSED (2 tests, 0 failures)
> - Status: REFACTOR complete
>
> Changes made:
> - Added `private Calculator calc;` field
> - Added `@BeforeEach void setUp() { calc = new Calculator(); }`
> - Removed local `calc` variables from each test

**Refactored `CalculatorTest.java`:**
```java
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class CalculatorTest {
    private Calculator calc;

    @BeforeEach
    void setUp() {
        calc = new Calculator();
    }

    @Test
    void testAdd() {
        assertEquals(5, calc.add(2, 3));
    }

    @Test
    void testSubtract() {
        assertEquals(2, calc.subtract(5, 3));
    }
}
```

### Step 5: Mark complete and report to user

```
Tool: TaskUpdate
  task_id: 6
  status: "completed"
```

### User-Facing Report after Cycle 2

> **Cycle 2 Complete: `subtract(a, b)`**
>
> | Phase | Result |
> |-------|--------|
> | RED | `testSubtract()` written -- fails with `UnsupportedOperationException` |
> | GREEN | `subtract()` implemented as `return a - b` -- all tests pass |
> | REFACTOR | Extracted `@BeforeEach setUp()` to eliminate repeated Calculator instantiation |
>
> **Tests: 2 passed, 0 failed**
>
> Progress: 2/4 features complete. Next: `multiply`...

---

## Remaining Cycles (3 and 4) -- Summary

### Cycle 3: `multiply(a, b)`
Same orchestration pattern:
- RED: Add `testMultiply()`, stub `multiply()` with `throw UnsupportedOperationException`
- GREEN: Implement `return a * b;`
- REFACTOR: Likely "no refactoring needed" -- pattern is consistent

### Cycle 4: `divide(a, b)`
Same pattern, with an additional consideration:
- RED: Add `testDivide()` and `testDivideByZero()` (two sub-behaviors)
  - Or split into two separate cycles: one for basic division, one for zero-division handling
  - Per skill's "each cycle adds ONE behavior" principle, we would do two cycles:
    - Cycle 4a: `divide(6, 3)` returns `2`
    - Cycle 4b: `divide(6, 0)` throws `ArithmeticException`
- GREEN: Implement `return a / b;` (Java's integer division already throws ArithmeticException for zero)
- REFACTOR: Possibly add a descriptive exception message, review overall class structure

---

## Overall Orchestration Flow Diagram

```
User Request
    │
    ▼
[Detect Environment]
    │  Scan build files, determine test command, verify tool works
    │
    ▼
[Plan TDD Cycles]
    │  Break features into individual behaviors (4-5 cycles)
    │  Present plan to user
    │
    ▼
[TeamCreate: "tdd-cycle"]
    │
    ├── SpawnAgent: red
    ├── SpawnAgent: green
    └── SpawnAgent: refactor
    │
    ▼
For each cycle:
    │
    ├── TaskCreate x3 (RED → GREEN → REFACTOR, with dependencies)
    │
    ├── RED Phase
    │   ├── TaskUpdate: assign to red
    │   ├── SendMessage: task details to red
    │   ├── Wait for red's report
    │   └── Verify: test fails? → proceed | test passes? → skip GREEN | build fails? → fix
    │
    ├── GREEN Phase
    │   ├── TaskUpdate: mark RED done, assign to green
    │   ├── SendMessage: task context to green
    │   ├── Wait for green's report
    │   └── Verify: all pass? → proceed | still fails? → retry
    │
    ├── REFACTOR Phase
    │   ├── TaskUpdate: mark GREEN done, assign to refactor
    │   ├── SendMessage: task context to refactor
    │   ├── Wait for refactor's report
    │   └── Verify: all pass? → proceed | test fails? → revert and retry
    │
    └── Report to User
        ├── Read final source & test files
        ├── Summarize each phase's outcome
        └── Ask: next cycle or done?
    │
    ▼
[Session Complete]
    ├── SendMessage: shutdown_request to red, green, refactor
    ├── Wait for confirmations
    └── TeamDelete: "tdd-cycle"
```

---

## Key Observations about the Skill

1. **Serial execution within each cycle:** RED must complete before GREEN starts, GREEN before REFACTOR. The 3 agents cannot work in parallel within a single cycle.

2. **Agent reuse across cycles:** The same 3 agents (red, green, refactor) are reused for all cycles. They are spawned once and shut down at the end.

3. **Task creation is upfront per cycle:** All 3 tasks (RED, GREEN, REFACTOR) are created at the beginning of each cycle with dependency chains, not on-the-fly.

4. **Communication is message-based:** The orchestrator (this skill) coordinates everything via SendMessage. Agents do the actual file editing and test running.

5. **Error handling is loop-based:** If RED produces a build failure, or GREEN can't pass the test, or REFACTOR breaks something, the skill sends follow-up messages to the same agent to retry -- it doesn't abandon the cycle.

6. **User stays informed:** After each complete cycle (all 3 phases), the user sees a summary with phase outcomes and test counts. The user can steer the next cycle or end the session.
