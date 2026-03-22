# TDD Team Skill Simulation

**Task:** "Calculator 클래스를 TDD로 만들어줘. add, subtract, multiply, divide 기능이 필요해"

---

## 1. Environment Detection

The skill instructs me to detect the project's language and build tool before anything else. Here is what I would check:

### Files I would look for (via Glob):
- `build.gradle.kts`, `build.gradle` -- Gradle (Kotlin/Java)
- `pom.xml` -- Maven (Java)
- `package.json` -- Node.js / TypeScript
- `Cargo.toml` -- Rust
- `go.mod` -- Go
- `pyproject.toml`, `setup.py`, `requirements.txt` -- Python

### Scenario: No project detected

Since the user's request doesn't specify a project and no build files are found in the working directory, the skill says: "If no project exists, ask the user what language/framework to use."

However, the user wrote in Korean and mentioned a "클래스" (class), and the example in the skill itself uses Java-style conventions (ArithmeticException). I would ask:

> "프로젝트가 아직 없는 것 같습니다. 어떤 언어/프레임워크를 사용하시겠어요? (예: Java + Gradle, Kotlin + Gradle, TypeScript + Jest, Python + pytest)"

### Assumed answer for simulation: **Java + Gradle + JUnit 5**

I would then scaffold a basic Gradle project and verify the build works.

### Captured Environment Context:
```
PROJECT_ROOT: /Users/tobylee/workspace/calculator
SOURCE_DIR: src/main/java/com/example/calculator
TEST_DIR: src/test/java/com/example/calculator
TEST_CMD: ./gradlew test
TEST_FRAMEWORK: JUnit 5
```

---

## 2. Feature Decomposition into TDD Tasks

Following the skill's guidance: "Start from the simplest possible behavior and build outward. Each task should add exactly one new behavior or edge case. Name each task as a behavior statement."

### Proposed TDD Task List:

```
TDD Tasks:
1. add(1, 2) returns 3        — basic addition
2. add(0, 0) returns 0        — addition zero case
3. subtract(5, 3) returns 2   — basic subtraction
4. subtract(3, 5) returns -2  — subtraction negative result
5. multiply(3, 4) returns 12  — basic multiplication
6. multiply(0, 5) returns 0   — multiplication by zero
7. divide(10, 2) returns 5    — basic division
8. divide(10, 0) throws ArithmeticException — division by zero
```

I would present this to the user:

> 다음과 같이 TDD 태스크를 분해했습니다. 순서를 바꾸거나, 추가/삭제하실 수 있어요:
>
> 1. `add(1, 2)` returns 3 -- 기본 덧셈
> 2. `add(0, 0)` returns 0 -- 0 케이스
> 3. `subtract(5, 3)` returns 2 -- 기본 뺄셈
> 4. `subtract(3, 5)` returns -2 -- 음수 결과
> 5. `multiply(3, 4)` returns 12 -- 기본 곱셈
> 6. `multiply(0, 5)` returns 0 -- 0 곱셈
> 7. `divide(10, 2)` returns 5 -- 기본 나눗셈
> 8. `divide(10, 0)` throws ArithmeticException -- 0으로 나누기
>
> 이대로 진행할까요?

**Assumed answer:** User confirms.

---

## 3. TDD Cycle Walkthroughs

---

### Cycle 1: `add(1, 2) returns 3`

#### RED Phase

**Agent prompt I would construct:**

```
Role: RED agent in a TDD (Test-Driven Development) cycle.
Mission: Write a FAILING test for the given task, then verify it fails.

## Rules
- Write ONLY the test. Create minimal stub classes/interfaces in the source directory if needed for compilation, but stubs must have NO real implementation (throw UnsupportedOperationException, return null/default, etc.)
- The test MUST compile but MUST fail
- Keep tests small and focused — one behavior per test
- Follow the project's existing test conventions (naming, structure, assertions)
- After writing, run the test command and confirm the test fails

## Workflow
1. Read the task description
2. Examine existing source and test files for context and conventions
3. Write the failing test (and minimal stubs if needed)
4. Run tests to verify:
   - Build succeeds + new test fails → Report SUCCESS with failure message
   - New test passes unexpectedly → Report ALREADY_PASSES
   - Build fails → Fix compilation issues, then re-verify
5. Report results:
   - Test file path and test method name
   - Failure message (or unexpected pass)
   - Any stub files created

## Environment
- Project root: /Users/tobylee/workspace/calculator
- Source directory: src/main/java/com/example/calculator
- Test directory: src/test/java/com/example/calculator
- Test command: ./gradlew test
- Test framework: JUnit 5

## Task
add(1, 2) returns 3 — basic addition

## Context
- No existing source files yet
- No existing test files yet
```

**Expected RED agent actions:**
1. Creates stub `Calculator.java` in source directory:
   ```java
   package com.example.calculator;

   public class Calculator {
       public int add(int a, int b) {
           throw new UnsupportedOperationException();
       }
   }
   ```
2. Creates `CalculatorTest.java` in test directory:
   ```java
   package com.example.calculator;

   import org.junit.jupiter.api.Test;
   import static org.junit.jupiter.api.Assertions.assertEquals;

   class CalculatorTest {
       @Test
       void addReturnsSumOfTwoNumbers() {
           Calculator calc = new Calculator();
           assertEquals(3, calc.add(1, 2));
       }
   }
   ```
3. Runs `./gradlew test`
4. Reports: "Test fails with UnsupportedOperationException" -- SUCCESS

**My check:** Test fails? Yes. Proceed to GREEN.

---

#### GREEN Phase

**Agent prompt I would construct:**

```
Role: GREEN agent in a TDD (Test-Driven Development) cycle.
Mission: Make the failing test PASS with the SIMPLEST possible implementation.

## Rules
- Write the MINIMUM code needed to make the test pass — no more, no less
- Do NOT refactor or clean up code — that is the refactor phase's job
- Do NOT modify tests — only modify production code
- Hardcoding values, simple conditionals, and "ugly" code are all acceptable — the goal is GREEN, not beautiful
- After implementation, run ALL tests and confirm every test passes

## Workflow
1. Read the failing test to understand what it expects
2. Read existing production code for context
3. Implement the simplest code to make the test pass
4. Run ALL tests to verify:
   - All tests pass → Report SUCCESS
   - New test still fails → Analyze failure, adjust, retry
   - Other tests break → Revert changes, find a different approach
5. Report results:
   - Files modified and what changed
   - All test results (pass count, any failures)

## Environment
- Project root: /Users/tobylee/workspace/calculator
- Source directory: src/main/java/com/example/calculator
- Test directory: src/test/java/com/example/calculator
- Test command: ./gradlew test
- Test framework: JUnit 5

## Failing Test
- File: src/test/java/com/example/calculator/CalculatorTest.java
- Method: addReturnsSumOfTwoNumbers()
- Failure: UnsupportedOperationException thrown from Calculator.add()

## Current Source
- Calculator.java: stub with add() that throws UnsupportedOperationException
```

**Expected GREEN agent actions:**
1. Modifies `Calculator.add()` to: `return a + b;`
   (Note: Per the "simplest implementation" principle, `return 3;` would also be valid. However, `return a + b;` is equally simple and more natural for addition.)
2. Runs `./gradlew test`
3. Reports: "1 test passed, 0 failed. Modified Calculator.java."

**My check:** All tests pass? Yes. Proceed to REFACTOR.

---

#### REFACTOR Phase

**Agent prompt I would construct:**

```
Role: REFACTOR agent in a TDD (Test-Driven Development) cycle.
Mission: Improve code quality while keeping ALL tests passing.

## Rules
- Do NOT change behavior — all existing tests must continue to pass
- Do NOT add new functionality or new tests
- Refactoring of both production code AND test code is allowed
- Focus areas:
  - Remove duplication (DRY)
  - Improve naming (variables, methods, classes)
  - Extract methods or classes for clarity
  - Simplify conditional logic
  - Improve test readability and assertion quality
- If the code is already clean, report "no refactoring needed" — do not force changes
- Run ALL tests after each refactoring change
- If any test fails, revert the breaking change and try a smaller refactoring

## Workflow
1. Read ALL current source and test files
2. Identify refactoring opportunities — prioritize by impact
3. Apply refactorings incrementally (one at a time)
4. Run ALL tests after each change to verify they still pass
5. Report results:
   - What changed and why (or "no refactoring needed")
   - Final test results
   - Any deferred refactoring opportunities for future cycles

## Environment
- Project root: /Users/tobylee/workspace/calculator
- Source directory: src/main/java/com/example/calculator
- Test directory: src/test/java/com/example/calculator
- Test command: ./gradlew test
- Test framework: JUnit 5

## Just Implemented
- RED: Wrote test addReturnsSumOfTwoNumbers() — verifies add(1,2) == 3
- GREEN: Implemented Calculator.add() as return a + b

## Current Files
- src/main/java/com/example/calculator/Calculator.java
- src/test/java/com/example/calculator/CalculatorTest.java
```

**Expected REFACTOR agent actions:**
1. Reviews both files
2. Reports: "No refactoring needed. Code is minimal and clean for this stage."
3. Runs `./gradlew test` -- 1 passed, 0 failed

---

#### Cycle 1 Summary (shown to user):

```
── TDD Cycle 1 Complete ──
Task: add(1, 2) returns 3 — basic addition

RED:      ✅ Test written: CalculatorTest.addReturnsSumOfTwoNumbers()
GREEN:    ✅ Implementation: Calculator.add() — return a + b
REFACTOR: ✅ No refactoring needed

Tests: 1 passed, 0 failed
Files changed: Calculator.java, CalculatorTest.java

── Progress ──
[x] 1. add(1, 2) returns 3
[>] 2. add(0, 0) returns 0
[ ] 3. subtract(5, 3) returns 2
[ ] 4. subtract(3, 5) returns -2
[ ] 5. multiply(3, 4) returns 12
[ ] 6. multiply(0, 5) returns 0
[ ] 7. divide(10, 2) returns 5
[ ] 8. divide(10, 0) throws ArithmeticException

Continue with task 2? (or modify the remaining tasks)
```

**Assumed answer:** User says continue.

---

### Cycle 2: `add(0, 0) returns 0`

#### RED Phase

**Agent prompt I would construct:**

```
Role: RED agent in a TDD (Test-Driven Development) cycle.
Mission: Write a FAILING test for the given task, then verify it fails.

## Rules
- Write ONLY the test. Create minimal stub classes/interfaces in the source directory if needed for compilation, but stubs must have NO real implementation (throw UnsupportedOperationException, return null/default, etc.)
- The test MUST compile but MUST fail
- Keep tests small and focused — one behavior per test
- Follow the project's existing test conventions (naming, structure, assertions)
- After writing, run the test command and confirm the test fails

## Workflow
1. Read the task description
2. Examine existing source and test files for context and conventions
3. Write the failing test (and minimal stubs if needed)
4. Run tests to verify:
   - Build succeeds + new test fails → Report SUCCESS with failure message
   - New test passes unexpectedly → Report ALREADY_PASSES
   - Build fails → Fix compilation issues, then re-verify
5. Report results:
   - Test file path and test method name
   - Failure message (or unexpected pass)
   - Any stub files created

## Environment
- Project root: /Users/tobylee/workspace/calculator
- Source directory: src/main/java/com/example/calculator
- Test directory: src/test/java/com/example/calculator
- Test command: ./gradlew test
- Test framework: JUnit 5

## Task
add(0, 0) returns 0 — addition zero case

## Context
- Existing source: Calculator.java with add(int a, int b) returning a + b
- Existing tests: CalculatorTest.java with addReturnsSumOfTwoNumbers()
```

**Expected RED agent actions:**
1. Adds test to `CalculatorTest.java`:
   ```java
   @Test
   void addReturnsZeroWhenBothOperandsAreZero() {
       Calculator calc = new Calculator();
       assertEquals(0, calc.add(0, 0));
   }
   ```
2. Runs `./gradlew test`
3. Reports: "ALREADY_PASSES -- add(0, 0) returns 0 already works with the existing `return a + b` implementation."

**My check:** The skill says "Test already passes -> skip GREEN, go to REFACTOR."

This is an important moment. The existing `return a + b` implementation already handles the zero case. This demonstrates a real TDD dynamic: some tests pass immediately because an earlier, more general implementation already covers the case.

---

#### GREEN Phase

**Skipped.** The test already passes. Per the skill: "Test already passes -> skip GREEN, go to REFACTOR."

---

#### REFACTOR Phase

**Agent prompt I would construct:**

```
Role: REFACTOR agent in a TDD (Test-Driven Development) cycle.
Mission: Improve code quality while keeping ALL tests passing.

## Rules
- Do NOT change behavior — all existing tests must continue to pass
- Do NOT add new functionality or new tests
- Refactoring of both production code AND test code is allowed
- Focus areas:
  - Remove duplication (DRY)
  - Improve naming (variables, methods, classes)
  - Extract methods or classes for clarity
  - Simplify conditional logic
  - Improve test readability and assertion quality
- If the code is already clean, report "no refactoring needed" — do not force changes
- Run ALL tests after each refactoring change
- If any test fails, revert the breaking change and try a smaller refactoring

## Workflow
1. Read ALL current source and test files
2. Identify refactoring opportunities — prioritize by impact
3. Apply refactorings incrementally (one at a time)
4. Run ALL tests after each change to verify they still pass
5. Report results:
   - What changed and why (or "no refactoring needed")
   - Final test results
   - Any deferred refactoring opportunities for future cycles

## Environment
- Project root: /Users/tobylee/workspace/calculator
- Source directory: src/main/java/com/example/calculator
- Test directory: src/test/java/com/example/calculator
- Test command: ./gradlew test
- Test framework: JUnit 5

## Just Implemented
- RED: Wrote test addReturnsZeroWhenBothOperandsAreZero() — already passed (GREEN skipped)

## Current Files
- src/main/java/com/example/calculator/Calculator.java
- src/test/java/com/example/calculator/CalculatorTest.java (2 tests)
```

**Expected REFACTOR agent actions:**
1. Reviews code. Notices `new Calculator()` is duplicated in both tests.
2. Extracts a shared instance variable using `@BeforeEach`:
   ```java
   private Calculator calc;

   @BeforeEach
   void setUp() {
       calc = new Calculator();
   }
   ```
3. Updates both tests to use `calc` instead of creating new instances.
4. Runs `./gradlew test` -- 2 passed, 0 failed.
5. Reports: "Extracted shared Calculator instance to @BeforeEach setUp() to remove duplication."

---

#### Cycle 2 Summary (shown to user):

```
── TDD Cycle 2 Complete ──
Task: add(0, 0) returns 0 — addition zero case

RED:      ⚡ Test written: CalculatorTest.addReturnsZeroWhenBothOperandsAreZero()
          (already passed — GREEN skipped)
GREEN:    ⏭️  Skipped (test passed immediately)
REFACTOR: ✅ Extracted shared Calculator instance to @BeforeEach setUp()

Tests: 2 passed, 0 failed
Files changed: CalculatorTest.java

── Progress ──
[x] 1. add(1, 2) returns 3
[x] 2. add(0, 0) returns 0
[>] 3. subtract(5, 3) returns 2
[ ] 4. subtract(3, 5) returns -2
[ ] 5. multiply(3, 4) returns 12
[ ] 6. multiply(0, 5) returns 0
[ ] 7. divide(10, 2) returns 5
[ ] 8. divide(10, 0) throws ArithmeticException

Continue with task 3? (or modify the remaining tasks)
```

---

## 4. Progress Tracking Display After Cycle 2

```
── TDD Session Progress ──

Completed: 2/8 tasks
Tests: 2 passed, 0 failed

[x] 1. add(1, 2) returns 3            — Cycle 1 ✅
[x] 2. add(0, 0) returns 0            — Cycle 2 ⚡ (already passed)
[>] 3. subtract(5, 3) returns 2
[ ] 4. subtract(3, 5) returns -2
[ ] 5. multiply(3, 4) returns 12
[ ] 6. multiply(0, 5) returns 0
[ ] 7. divide(10, 2) returns 5
[ ] 8. divide(10, 0) throws ArithmeticException

Files in play:
  - src/main/java/com/example/calculator/Calculator.java
  - src/test/java/com/example/calculator/CalculatorTest.java
```

---

## 5. User Checkpoint Interaction

At this point, the user has several options per the skill:

> **Continue with task 3?** (or modify the remaining tasks)

Possible user responses and how I would handle them:

| User says | Action |
|-----------|--------|
| "계속해" / "Continue" | Proceed to Cycle 3: subtract(5, 3) returns 2 |
| "Task 4 건너뛰어" / "Skip task 4" | Remove task 4 from the list, renumber, proceed to task 3 |
| "add에 음수 케이스도 추가하고 싶어" | Insert new task (e.g., `add(-1, -2) returns -3`) after task 2, shift remaining tasks |
| "나머지는 알아서 쭉 해줘" | Run remaining cycles without checkpoints until completion |
| "여기서 멈출게" | End session, provide final summary |
| "multiply부터 하고 싶어" | Reorder: move task 5 to next position |

### Example: User says "계속해"

I would proceed to Cycle 3 with the same pattern:
- RED: Write `subtractReturnsDifference()` test, create stub `subtract()` that throws
- GREEN: Implement `return a - b;`
- REFACTOR: Review -- likely "no refactoring needed" at this stage

### Example: User says "여기서 멈출게" (stop here)

I would present the session-end summary per the skill:

```
── TDD Session Summary ──

Cycles completed: 2
Total tests: 2 passed, 0 failed

Files created:
  - src/main/java/com/example/calculator/Calculator.java
  - src/test/java/com/example/calculator/CalculatorTest.java

Implemented behaviors:
  - Calculator.add(int, int) — addition of two integers

Suggested next steps:
  - Continue TDD for subtract, multiply, divide
  - Consider additional edge cases: negative numbers, integer overflow
  - Add integration tests if Calculator is used by other components
```

---

## Key Observations from This Simulation

1. **Environment detection is interactive.** The skill correctly requires asking the user when no project is detected, rather than guessing.

2. **Decomposition matters.** Breaking "Calculator with 4 operations" into 8 granular behavior-level tasks gives meaningful TDD granularity. Each cycle is small enough to be atomic.

3. **ALREADY_PASSES is a real scenario.** Cycle 2 demonstrates that a general implementation (`a + b`) can make subsequent edge-case tests pass immediately. The skill correctly handles this by skipping GREEN.

4. **Refactoring emerges naturally.** By cycle 2, duplication in tests becomes noticeable, prompting extraction of `@BeforeEach`. This is exactly how TDD refactoring should work -- you don't plan it; it emerges from the code.

5. **User checkpoints maintain control.** The user can redirect, skip, or stop at any point. This is critical for a TDD session that could have 8+ cycles.

6. **Strict phase separation is enforced.** RED only writes tests/stubs. GREEN only writes production code. REFACTOR only improves structure. This is maintained through explicit agent prompts that constrain each role.
