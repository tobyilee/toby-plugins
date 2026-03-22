# TDD Team Simulation: StringUtils (reverse, isPalindrome)

**User request:** "TDD 시작해줘. 간단한 StringUtils 클래스에 reverse, isPalindrome 메서드"

---

## Phase 0: Environment Detection

The skill triggers on "TDD 시작해줘" matching the activation patterns.

### Actions taken:

1. **Scan for build files** in the working directory:
   - Look for: `build.gradle`, `build.gradle.kts`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`, etc.
   - **Result (simulated):** No project build files found — this is a plugin repository, not an application project.

2. **Ask user for language/build tool:**
   Since no project exists, we ask:
   > "프로젝트가 없습니다. 어떤 언어와 빌드 도구를 사용하시겠어요? (예: Java + Gradle, TypeScript + npm, Python + pytest)"

   **Simulated user response:** "Java + Gradle"

3. **Scaffold a Gradle/Java project:**
   - Run `gradle init --type java-library` or create minimal structure manually
   - Resulting structure:
     ```
     string-utils/
       build.gradle
       src/main/java/
       src/test/java/
       settings.gradle
     ```
   - Configure JUnit 5 in `build.gradle`

4. **Verify build tool works:**
   - Run `./gradlew build` — confirm it completes successfully

5. **Captured environment variables:**
   ```
   PROJECT_ROOT: /Users/tobylee/workspace/ai/toby-plugins/string-utils
   SOURCE_DIR: src/main/java
   TEST_DIR: src/test/java
   BUILD_CMD: ./gradlew build
   TEST_CMD: ./gradlew test
   TEST_FRAMEWORK: JUnit 5
   ```

---

## Phase 1: Team Creation and Agent Spawning

### 1.1 Create Team

```
Tool: TeamCreate
Parameters:
  name: "tdd-cycle"
```

### 1.2 Spawn Agents (3 parallel calls)

**Agent 1 — red:**
```
Tool: TaskCreate (type: general-purpose)
Parameters:
  name: "red"
  team_name: "tdd-cycle"
  prompt: |
    Role: RED agent in a TDD (Test-Driven Development) cycle team.
    Mission: Write a FAILING test for a given task, then verify it fails.
    [... full RED prompt from agent-prompts.md ...]

    ## Environment
    - Project root: /Users/tobylee/workspace/ai/toby-plugins/string-utils
    - Source directory: src/main/java
    - Test directory: src/test/java
    - Build command: ./gradlew build
    - Test command: ./gradlew test
    - Test framework: JUnit 5
```

**Agent 2 — green:**
```
Tool: TaskCreate (type: general-purpose)
Parameters:
  name: "green"
  team_name: "tdd-cycle"
  prompt: |
    Role: GREEN agent in a TDD (Test-Driven Development) cycle team.
    Mission: Make the failing test PASS with the SIMPLEST possible implementation.
    [... full GREEN prompt from agent-prompts.md ...]

    ## Environment
    - Project root: /Users/tobylee/workspace/ai/toby-plugins/string-utils
    - Source directory: src/main/java
    - Test directory: src/test/java
    - Build command: ./gradlew build
    - Test command: ./gradlew test
    - Test framework: JUnit 5
```

**Agent 3 — refactor:**
```
Tool: TaskCreate (type: general-purpose)
Parameters:
  name: "refactor"
  team_name: "tdd-cycle"
  prompt: |
    Role: REFACTOR agent in a TDD (Test-Driven Development) cycle team.
    Mission: Improve code quality while keeping ALL tests passing.
    [... full REFACTOR prompt from agent-prompts.md ...]

    ## Environment
    - Project root: /Users/tobylee/workspace/ai/toby-plugins/string-utils
    - Source directory: src/main/java
    - Test directory: src/test/java
    - Build command: ./gradlew build
    - Test command: ./gradlew test
    - Test framework: JUnit 5
```

### 1.3 Wait for Ready

Wait for all three agents to report ready. Once confirmed:

> **User에게 표시:**
> TDD 팀이 준비되었습니다!
> - RED agent: ready
> - GREEN agent: ready
> - REFACTOR agent: ready
>
> 두 개의 메서드가 있으므로 TDD 사이클을 나눠서 진행합니다:
> 1. Cycle 1: `StringUtils.reverse(String)`
> 2. Cycle 2: `StringUtils.isPalindrome(String)`
>
> Cycle 1부터 시작합니다.

---

## TDD Cycle Plan

The user requested two methods: `reverse` and `isPalindrome`. Following the **"each cycle adds ONE behavior"** principle, we plan:

| Cycle | Behavior |
|-------|----------|
| 1 | `reverse(String)` — reverses a string |
| 2 | `isPalindrome(String)` — checks if a string is a palindrome |

Note: `isPalindrome` naturally builds on `reverse`, which is good incremental design.

---

## Cycle 1: `StringUtils.reverse(String)`

### Step 1: RED Phase

**1a. Create three tasks:**

```
Tool: TaskCreate
Parameters:
  title: "[RED] Write failing test for StringUtils.reverse()"
  description: |
    Write a JUnit 5 test for StringUtils.reverse(String).
    - Test that reverse("hello") returns "olleh"
    - Create a minimal StringUtils stub class with a reverse() method that throws UnsupportedOperationException
    - Test must compile but fail
    - Test file: src/test/java/StringUtilsTest.java
    - Stub file: src/main/java/StringUtils.java
  team_name: "tdd-cycle"
  task_id: "task-1"

Tool: TaskCreate
Parameters:
  title: "[GREEN] Implement StringUtils.reverse() to pass the test"
  description: |
    Make the failing test for reverse() pass with the simplest possible implementation.
    - Do NOT refactor or clean up
    - Do NOT modify tests
    - Run ALL tests and confirm they pass
  team_name: "tdd-cycle"
  task_id: "task-2"
  blocked_by: ["task-1"]

Tool: TaskCreate
Parameters:
  title: "[REFACTOR] Clean up after StringUtils.reverse()"
  description: |
    Review and refactor production and test code for reverse().
    - Improve naming, remove duplication
    - Keep all tests passing
  team_name: "tdd-cycle"
  task_id: "task-3"
  blocked_by: ["task-2"]
```

**1b. Assign RED task and send message:**

```
Tool: TaskUpdate
Parameters:
  task_id: "task-1"
  assigned_to: "red"
  status: "in_progress"

Tool: SendMessage
Parameters:
  to: "red"
  type: "message"
  content: |
    Task #task-1: [RED] Write failing test for StringUtils.reverse()

    Write a JUnit 5 test that verifies StringUtils.reverse("hello") returns "olleh".
    Create a minimal stub class StringUtils in src/main/java/StringUtils.java with:
      public static String reverse(String input) { throw new UnsupportedOperationException(); }

    Test file: src/test/java/StringUtilsTest.java
    Run: ./gradlew test
    Verify: build succeeds, test FAILS.
```

**1c. Wait for RED agent response.**

**Simulated RED agent report:**
```
SendMessage from red:
  Task #task-1 complete.
  - Created: src/test/java/StringUtilsTest.java
    - Test method: testReverse() — asserts reverse("hello") == "olleh"
  - Created: src/main/java/StringUtils.java (stub, throws UnsupportedOperationException)
  - ./gradlew test result: BUILD SUCCESSFUL, 1 test FAILED
    - StringUtilsTest > testReverse() FAILED
      java.lang.UnsupportedOperationException
  - Status: RED confirmed. Test fails as expected.
```

> **User에게 표시:**
> **RED 완료** -- `testReverse()` 실패 확인 (UnsupportedOperationException). GREEN 단계로 넘어갑니다.

---

### Step 2: GREEN Phase

**2a. Mark RED complete, assign GREEN:**

```
Tool: TaskUpdate
Parameters:
  task_id: "task-1"
  status: "completed"

Tool: TaskUpdate
Parameters:
  task_id: "task-2"
  assigned_to: "green"
  status: "in_progress"

Tool: SendMessage
Parameters:
  to: "green"
  type: "message"
  content: |
    Task #task-2: [GREEN] Make StringUtils.reverse() test pass.

    The failing test is in src/test/java/StringUtilsTest.java:
      testReverse() expects reverse("hello") == "olleh"

    Production code: src/main/java/StringUtils.java
    Currently throws UnsupportedOperationException.

    Implement the SIMPLEST code to make it pass. Do NOT modify the test.
    Run: ./gradlew test — ALL tests must pass.
```

**2b. Wait for GREEN agent response.**

**Simulated GREEN agent report:**
```
SendMessage from green:
  Task #task-2 complete.
  - Modified: src/main/java/StringUtils.java
    - Implemented reverse() using StringBuilder.reverse()
  - ./gradlew test result: BUILD SUCCESSFUL, 1 test PASSED
  - Status: GREEN confirmed. All tests pass.
```

> **User에게 표시:**
> **GREEN 완료** -- `reverse()` 구현 완료. 모든 테스트 통과. REFACTOR 단계로 넘어갑니다.

---

### Step 3: REFACTOR Phase

**3a. Mark GREEN complete, assign REFACTOR:**

```
Tool: TaskUpdate
Parameters:
  task_id: "task-2"
  status: "completed"

Tool: TaskUpdate
Parameters:
  task_id: "task-3"
  assigned_to: "refactor"
  status: "in_progress"

Tool: SendMessage
Parameters:
  to: "refactor"
  type: "message"
  content: |
    Task #task-3: [REFACTOR] Clean up after StringUtils.reverse()

    Files to review:
    - src/main/java/StringUtils.java
    - src/test/java/StringUtilsTest.java

    Look for: naming improvements, unnecessary complexity, test readability.
    Run: ./gradlew test after any changes to confirm all tests still pass.
    If code is already clean, report "no refactoring needed".
```

**3b. Wait for REFACTOR agent response.**

**Simulated REFACTOR agent report:**
```
SendMessage from refactor:
  Task #task-3 complete.
  - Reviewed both files.
  - Added @DisplayName annotation to test for readability:
      @DisplayName("reverse should return characters in opposite order")
  - Added null-safety check to reverse() method.
  - Added package declaration for proper structure.
  - ./gradlew test: BUILD SUCCESSFUL, 1 test PASSED.
  - Status: Refactoring complete, all tests pass.
```

---

### Step 4: Cycle 1 Review and Report

```
Tool: TaskUpdate
Parameters:
  task_id: "task-3"
  status: "completed"
```

Read the current state of source and test files, then present to user:

> **User에게 Cycle 1 결과 표시:**
>
> ---
> ### Cycle 1 완료: `StringUtils.reverse()`
>
> | 단계 | 결과 |
> |------|------|
> | RED | `testReverse()` 작성 -- 실패 확인 (UnsupportedOperationException) |
> | GREEN | `StringBuilder.reverse()` 사용하여 구현 -- 테스트 통과 |
> | REFACTOR | `@DisplayName` 추가, null 체크 추가, 패키지 선언 정리 |
>
> **현재 파일:**
> - `src/main/java/StringUtils.java` — `reverse(String)` 메서드 구현 완료
> - `src/test/java/StringUtilsTest.java` — 1개 테스트 통과
>
> **테스트 결과:** 1 passed, 0 failed
>
> Cycle 2로 넘어갑니다: `isPalindrome(String)`
> ---

---

## Cycle 2: `StringUtils.isPalindrome(String)`

### Step 1: RED Phase

**1a. Create three tasks:**

```
Tool: TaskCreate
Parameters:
  title: "[RED] Write failing test for StringUtils.isPalindrome()"
  description: |
    Write JUnit 5 tests for StringUtils.isPalindrome(String).
    - Test that isPalindrome("racecar") returns true
    - Test that isPalindrome("hello") returns false
    - Add a stub method isPalindrome() that throws UnsupportedOperationException
    - Tests must compile but fail
  team_name: "tdd-cycle"
  task_id: "task-4"

Tool: TaskCreate
Parameters:
  title: "[GREEN] Implement StringUtils.isPalindrome() to pass tests"
  description: |
    Make the failing isPalindrome() tests pass with simplest implementation.
    - Do NOT modify tests
    - Do NOT refactor
    - ALL tests must pass (including reverse test from cycle 1)
  team_name: "tdd-cycle"
  task_id: "task-5"
  blocked_by: ["task-4"]

Tool: TaskCreate
Parameters:
  title: "[REFACTOR] Clean up after StringUtils.isPalindrome()"
  description: |
    Review full codebase and refactor.
    - Look for: duplication between reverse() and isPalindrome(), naming, test structure
    - Consider: can isPalindrome() reuse reverse()?
    - Keep all tests passing
  team_name: "tdd-cycle"
  task_id: "task-6"
  blocked_by: ["task-5"]
```

**1b. Assign RED task and send message:**

```
Tool: TaskUpdate
Parameters:
  task_id: "task-4"
  assigned_to: "red"
  status: "in_progress"

Tool: SendMessage
Parameters:
  to: "red"
  type: "message"
  content: |
    Task #task-4: [RED] Write failing tests for StringUtils.isPalindrome()

    Add to existing test file src/test/java/StringUtilsTest.java:
    - testIsPalindrome_true(): isPalindrome("racecar") should return true
    - testIsPalindrome_false(): isPalindrome("hello") should return false

    Add stub in src/main/java/StringUtils.java:
      public static boolean isPalindrome(String input) { throw new UnsupportedOperationException(); }

    Run: ./gradlew test
    Verify: build succeeds, new tests FAIL, existing reverse test still PASSES.
```

**1c. Wait for RED agent response.**

**Simulated RED agent report:**
```
SendMessage from red:
  Task #task-4 complete.
  - Modified: src/test/java/StringUtilsTest.java
    - Added: testIsPalindrome_true() — asserts isPalindrome("racecar") == true
    - Added: testIsPalindrome_false() — asserts isPalindrome("hello") == false
  - Modified: src/main/java/StringUtils.java
    - Added stub: isPalindrome() throws UnsupportedOperationException
  - ./gradlew test result: BUILD SUCCESSFUL
    - testReverse() PASSED
    - testIsPalindrome_true() FAILED (UnsupportedOperationException)
    - testIsPalindrome_false() FAILED (UnsupportedOperationException)
  - Status: RED confirmed. 2 new tests fail, 1 existing test passes.
```

> **User에게 표시:**
> **RED 완료** -- `testIsPalindrome_true()`, `testIsPalindrome_false()` 실패 확인. GREEN 단계로 넘어갑니다.

---

### Step 2: GREEN Phase

**2a. Mark RED complete, assign GREEN:**

```
Tool: TaskUpdate
Parameters:
  task_id: "task-4"
  status: "completed"

Tool: TaskUpdate
Parameters:
  task_id: "task-5"
  assigned_to: "green"
  status: "in_progress"

Tool: SendMessage
Parameters:
  to: "green"
  type: "message"
  content: |
    Task #task-5: [GREEN] Make StringUtils.isPalindrome() tests pass.

    Failing tests in src/test/java/StringUtilsTest.java:
    - testIsPalindrome_true(): isPalindrome("racecar") should return true
    - testIsPalindrome_false(): isPalindrome("hello") should return false

    Production code: src/main/java/StringUtils.java
    Currently isPalindrome() throws UnsupportedOperationException.

    Implement the SIMPLEST code. Do NOT modify tests. Do NOT refactor.
    Run: ./gradlew test — ALL tests (including reverse) must pass.
```

**2b. Wait for GREEN agent response.**

**Simulated GREEN agent report:**
```
SendMessage from green:
  Task #task-5 complete.
  - Modified: src/main/java/StringUtils.java
    - Implemented isPalindrome():
        public static boolean isPalindrome(String input) {
            return input.equals(new StringBuilder(input).reverse().toString());
        }
  - ./gradlew test result: BUILD SUCCESSFUL
    - testReverse() PASSED
    - testIsPalindrome_true() PASSED
    - testIsPalindrome_false() PASSED
  - Status: GREEN confirmed. All 3 tests pass.
```

> **User에게 표시:**
> **GREEN 완료** -- `isPalindrome()` 구현 완료. 모든 테스트 (3개) 통과. REFACTOR 단계로 넘어갑니다.

---

### Step 3: REFACTOR Phase

**3a. Mark GREEN complete, assign REFACTOR:**

```
Tool: TaskUpdate
Parameters:
  task_id: "task-5"
  status: "completed"

Tool: TaskUpdate
Parameters:
  task_id: "task-6"
  assigned_to: "refactor"
  status: "in_progress"

Tool: SendMessage
Parameters:
  to: "refactor"
  type: "message"
  content: |
    Task #task-6: [REFACTOR] Clean up StringUtils after adding isPalindrome()

    Files to review:
    - src/main/java/StringUtils.java
    - src/test/java/StringUtilsTest.java

    Key things to look for:
    - isPalindrome() duplicates reversal logic from reverse(). Consider reusing reverse() inside isPalindrome().
    - Test structure: consider @Nested classes to group reverse and palindrome tests.
    - Naming consistency in test methods.
    Run: ./gradlew test after each change.
```

**3b. Wait for REFACTOR agent response.**

**Simulated REFACTOR agent report:**
```
SendMessage from refactor:
  Task #task-6 complete.
  - Refactored src/main/java/StringUtils.java:
    - isPalindrome() now reuses reverse():
        public static boolean isPalindrome(String input) {
            return input.equals(reverse(input));
        }
    - Removed duplicated StringBuilder logic
  - Refactored src/test/java/StringUtilsTest.java:
    - Added @Nested classes: ReverseTest, PalindromeTest
    - Added @DisplayName annotations to all tests
  - ./gradlew test: BUILD SUCCESSFUL, 3 tests PASSED
  - Status: Refactoring complete. Eliminated duplication. All tests pass.
```

---

### Step 4: Cycle 2 Review and Report

```
Tool: TaskUpdate
Parameters:
  task_id: "task-6"
  status: "completed"
```

Read the final state of source and test files, then present to user:

> **User에게 Cycle 2 결과 및 최종 요약 표시:**
>
> ---
> ### Cycle 2 완료: `StringUtils.isPalindrome()`
>
> | 단계 | 결과 |
> |------|------|
> | RED | `testIsPalindrome_true()`, `testIsPalindrome_false()` 작성 -- 실패 확인 |
> | GREEN | `StringBuilder.reverse()` 사용하여 구현 -- 모든 테스트 통과 |
> | REFACTOR | `isPalindrome()`이 `reverse()` 재사용하도록 리팩토링, `@Nested` 테스트 구조 정리 |
>
> ---
>
> ### 전체 TDD 세션 요약
>
> **최종 파일:**
>
> **`src/main/java/StringUtils.java`:**
> ```java
> public class StringUtils {
>     public static String reverse(String input) {
>         if (input == null) return null;
>         return new StringBuilder(input).reverse().toString();
>     }
>
>     public static boolean isPalindrome(String input) {
>         return input.equals(reverse(input));
>     }
> }
> ```
>
> **`src/test/java/StringUtilsTest.java`:**
> ```java
> class StringUtilsTest {
>     @Nested
>     @DisplayName("reverse")
>     class ReverseTest {
>         @Test
>         @DisplayName("should return characters in opposite order")
>         void testReverse() {
>             assertEquals("olleh", StringUtils.reverse("hello"));
>         }
>     }
>
>     @Nested
>     @DisplayName("isPalindrome")
>     class PalindromeTest {
>         @Test
>         @DisplayName("should return true for palindrome string")
>         void testIsPalindrome_true() {
>             assertTrue(StringUtils.isPalindrome("racecar"));
>         }
>
>         @Test
>         @DisplayName("should return false for non-palindrome string")
>         void testIsPalindrome_false() {
>             assertFalse(StringUtils.isPalindrome("hello"));
>         }
>     }
> }
> ```
>
> **테스트 결과:** 3 passed, 0 failed
>
> 추가 TDD 사이클이 필요하시면 말씀해주세요. 완료라면 TDD 세션을 종료하겠습니다.
> ---

---

## Phase 5: Shutdown Procedure

When the user indicates the session is complete (e.g., "끝" or "완료"):

### 5.1 Send shutdown_request to each agent (3 parallel calls)

```
Tool: SendMessage
Parameters:
  to: "red"
  type: "shutdown_request"
  content: "TDD session complete. Please shut down."

Tool: SendMessage
Parameters:
  to: "green"
  type: "shutdown_request"
  content: "TDD session complete. Please shut down."

Tool: SendMessage
Parameters:
  to: "refactor"
  type: "shutdown_request"
  content: "TDD session complete. Please shut down."
```

### 5.2 Wait for confirmations

Wait for all three agents to acknowledge shutdown.

### 5.3 Delete the team

```
Tool: TeamDelete
Parameters:
  name: "tdd-cycle"
```

### 5.4 Final message to user

> TDD 세션이 종료되었습니다.
> - 총 2개 TDD 사이클 완료
> - `StringUtils` 클래스: `reverse()`, `isPalindrome()` 구현
> - 테스트 3개 모두 통과
> - 에이전트 팀 정리 완료

---

## Tool Call Summary

| Phase | Tool Calls | Count |
|-------|-----------|-------|
| Environment Detection | Bash (scan files, scaffold, verify build) | ~4 |
| Team Setup | TeamCreate + 3x agent spawn | 4 |
| Cycle 1 RED | TaskCreate x3, TaskUpdate, SendMessage | 5 |
| Cycle 1 GREEN | TaskUpdate x2, SendMessage | 3 |
| Cycle 1 REFACTOR | TaskUpdate x2, SendMessage | 3 |
| Cycle 1 Review | TaskUpdate, Read x2 | 3 |
| Cycle 2 RED | TaskCreate x3, TaskUpdate, SendMessage | 5 |
| Cycle 2 GREEN | TaskUpdate x2, SendMessage | 3 |
| Cycle 2 REFACTOR | TaskUpdate x2, SendMessage | 3 |
| Cycle 2 Review | TaskUpdate, Read x2 | 3 |
| Shutdown | SendMessage x3, TeamDelete | 4 |
| **Total** | | **~40** |

---

## Key Observations

1. **Strict phase separation maintained:** RED only wrote tests + stubs, GREEN only wrote production code, REFACTOR only cleaned up.
2. **Incremental approach:** Each cycle added exactly ONE behavior (reverse, then isPalindrome).
3. **Natural dependency emerged:** REFACTOR in Cycle 2 discovered that `isPalindrome` could reuse `reverse`, demonstrating the value of the refactoring phase.
4. **Korean language support:** User prompts and status updates were presented in Korean matching the user's language preference.
5. **Dependency chain enforced:** Tasks were created with `blocked_by` to ensure GREEN waits for RED and REFACTOR waits for GREEN.
