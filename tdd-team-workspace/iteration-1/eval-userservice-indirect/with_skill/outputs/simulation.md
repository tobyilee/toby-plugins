# TDD Team Skill Simulation

**Task (user input):** "이 기능 테스트 먼저 만들고 하나씩 구현하자: UserService에 findById, createUser, deleteUser 추가해줘"

---

## Phase 1: Detect Environment

The skill instructs us to detect the project's language and build tool before anything else. We would scan for build files in the project root.

**Actions taken (simulated):**

1. Glob for build files: `build.gradle.kts`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`
2. Suppose we find `build.gradle.kts` at the project root.
3. Read `build.gradle.kts` to confirm language (Kotlin/Java), dependencies (Spring Boot, JUnit 5).
4. Run `./gradlew build` to verify the build tool works.
5. Scan `src/main/java` and `src/test/java` for existing conventions.

**Captured environment context:**

```
PROJECT_ROOT: /Users/tobylee/workspace/project
SOURCE_DIR: src/main/java
TEST_DIR: src/test/java
TEST_CMD: ./gradlew test
TEST_FRAMEWORK: JUnit 5 (with Spring Boot Test)
```

---

## Phase 2: Decompose into TDD Tasks

The user wants three methods: `findById`, `createUser`, `deleteUser`. Per the skill, we break each into small behavioral increments, starting from the simplest case and building outward.

**Proposed TDD Task List:**

```
TDD Tasks:
1. findById returns user when user exists
2. findById throws exception when user not found
3. createUser saves and returns the created user
4. createUser throws exception when email already exists (duplicate prevention)
5. deleteUser removes existing user successfully
6. deleteUser throws exception when user not found
```

**Presented to user for confirmation:**

> 다음과 같이 6개의 TDD 사이클로 나눠서 진행하겠습니다:
>
> 1. `findById` — 유저가 존재할 때 반환
> 2. `findById` — 유저가 없을 때 예외 발생
> 3. `createUser` — 유저 저장 및 반환
> 4. `createUser` — 이메일 중복 시 예외 발생
> 5. `deleteUser` — 존재하는 유저 삭제
> 6. `deleteUser` — 없는 유저 삭제 시 예외 발생
>
> 이 순서대로 진행할까요? 추가/제거/수정하고 싶은 항목이 있으면 말씀해 주세요.

(User confirms.)

---

## Phase 3: TDD Cycle Execution

### Cycle 1: findById returns user when user exists

#### RED Phase

**Agent spawn:** Red agent with the following prompt:

```
Role: RED agent in a TDD (Test-Driven Development) cycle.
Mission: Write a FAILING test for the given task, then verify it fails.

## Rules
- Write ONLY the test. Create minimal stub classes/interfaces in the source
  directory if needed for compilation, but stubs must have NO real
  implementation (throw UnsupportedOperationException, return null/default, etc.)
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
- Project root: /Users/tobylee/workspace/project
- Source directory: src/main/java
- Test directory: src/test/java
- Test command: ./gradlew test
- Test framework: JUnit 5 (with Spring Boot Test)

## Task
findById returns user when user exists

## Context
- No existing UserService or UserServiceTest files yet.
- This is the first TDD cycle in the session.
```

**Simulated Red Agent actions:**

1. No existing files found — creates stubs:
   - `src/main/java/com/example/model/User.java` — simple data class with `id`, `name`, `email` fields
   - `src/main/java/com/example/repository/UserRepository.java` — interface with `findById(Long id)` returning `Optional<User>` (stub)
   - `src/main/java/com/example/service/UserService.java` — class with `findById(Long id)` method that `throw new UnsupportedOperationException()`

2. Writes test:
   - `src/test/java/com/example/service/UserServiceTest.java`

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldReturnUserWhenFoundById() {
        // given
        User user = new User(1L, "Alice", "alice@example.com");
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        // when
        User result = userService.findById(1L);

        // then
        assertThat(result).isEqualTo(user);
    }
}
```

3. Runs `./gradlew test`
4. **Result:** Build succeeds, test FAILS with `java.lang.UnsupportedOperationException`

**Red Agent Report:**
```
STATUS: SUCCESS (test fails as expected)
Test file: src/test/java/com/example/service/UserServiceTest.java
Test method: shouldReturnUserWhenFoundById()
Failure message: java.lang.UnsupportedOperationException
Stub files created:
  - src/main/java/com/example/model/User.java
  - src/main/java/com/example/repository/UserRepository.java
  - src/main/java/com/example/service/UserService.java
```

**Orchestrator check:** Test fails → proceed to GREEN.

---

#### GREEN Phase

**Agent spawn:** Green agent with the following prompt:

```
Role: GREEN agent in a TDD (Test-Driven Development) cycle.
Mission: Make the failing test PASS with the SIMPLEST possible implementation.

## Rules
- Write the MINIMUM code needed to make the test pass — no more, no less
- Do NOT refactor or clean up code — that is the refactor phase's job
- Do NOT modify tests — only modify production code
- Hardcoding values, simple conditionals, and "ugly" code are all acceptable
  — the goal is GREEN, not beautiful
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
- Project root: /Users/tobylee/workspace/project
- Source directory: src/main/java
- Test directory: src/test/java
- Test command: ./gradlew test
- Test framework: JUnit 5 (with Spring Boot Test)

## Context
- Failing test: src/test/java/com/example/service/UserServiceTest.java
  → shouldReturnUserWhenFoundById()
- Failure message: java.lang.UnsupportedOperationException
- Source file: src/main/java/com/example/service/UserService.java
```

**Simulated Green Agent actions:**

1. Reads the failing test — it expects `findById(1L)` to delegate to `userRepository.findById(1L)` and return the user.
2. Implements the simplest code in `UserService.java`:

```java
public User findById(Long id) {
    return userRepository.findById(id).orElse(null);
}
```

3. Runs `./gradlew test`
4. **Result:** 1 test passed, 0 failed.

**Green Agent Report:**
```
STATUS: SUCCESS (all tests pass)
Files modified: src/main/java/com/example/service/UserService.java
  - findById() now delegates to userRepository.findById() and returns
    the unwrapped value (or null)
Test results: 1 passed, 0 failed
```

---

#### REFACTOR Phase

**Agent spawn:** Refactor agent with the following prompt:

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
- If the code is already clean, report "no refactoring needed" — do not
  force changes
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
- Project root: /Users/tobylee/workspace/project
- Source directory: src/main/java
- Test directory: src/test/java
- Test command: ./gradlew test
- Test framework: JUnit 5 (with Spring Boot Test)

## Context
- Just implemented: findById() — delegates to repository, returns user
- Source files:
  - src/main/java/com/example/model/User.java
  - src/main/java/com/example/repository/UserRepository.java
  - src/main/java/com/example/service/UserService.java
- Test files:
  - src/test/java/com/example/service/UserServiceTest.java
```

**Simulated Refactor Agent actions:**

1. Reads all source and test files.
2. Code is minimal — only one method, one test. Naming is clear. No duplication.
3. Notes that `findById` returns `null` when not found, but this will be addressed by the next TDD cycle (task 2: "throws exception when not found"), so no change needed now.
4. Runs `./gradlew test` — 1 passed, 0 failed.

**Refactor Agent Report:**
```
STATUS: No refactoring needed
Reason: Code is minimal and clean for the current scope.
Deferred: orElse(null) may be replaced with exception throwing in a future cycle.
Test results: 1 passed, 0 failed
```

---

### Cycle 1 Summary (presented to user)

```
── TDD Cycle 1 Complete ──────────────────────────────
Task: findById returns user when user exists

RED:      ✅ Test written: UserServiceTest.shouldReturnUserWhenFoundById()
GREEN:    ✅ Implementation: UserService.findById() — delegates to repository
REFACTOR: ✅ No refactoring needed

Tests: 1 passed, 0 failed
Files changed: User.java, UserRepository.java, UserService.java, UserServiceTest.java

── Progress ──────────────────────────────────────────
[x] 1. findById returns user when exists
[>] 2. findById throws exception when not found
[ ] 3. createUser saves and returns user
[ ] 4. createUser throws on duplicate email
[ ] 5. deleteUser removes existing user
[ ] 6. deleteUser throws when user not found

Continue with task 2? (or modify the remaining tasks)
```

---

### Cycle 2: findById throws exception when user not found

#### RED Phase

**Agent spawn:** Red agent with prompt:

```
Role: RED agent in a TDD (Test-Driven Development) cycle.
Mission: Write a FAILING test for the given task, then verify it fails.

## Rules
- Write ONLY the test. Create minimal stub classes/interfaces in the source
  directory if needed for compilation, but stubs must have NO real
  implementation (throw UnsupportedOperationException, return null/default, etc.)
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
- Project root: /Users/tobylee/workspace/project
- Source directory: src/main/java
- Test directory: src/test/java
- Test command: ./gradlew test
- Test framework: JUnit 5 (with Spring Boot Test)

## Task
findById throws exception when user not found

## Context
- Existing test: UserServiceTest.shouldReturnUserWhenFoundById() (passing)
- Existing source: UserService.findById() returns userRepository.findById(id).orElse(null)
- Files:
  - src/main/java/com/example/service/UserService.java
  - src/test/java/com/example/service/UserServiceTest.java
```

**Simulated Red Agent actions:**

1. Reads existing test file to follow conventions (Mockito + AssertJ style).
2. Creates a custom exception stub: `src/main/java/com/example/exception/UserNotFoundException.java` extending `RuntimeException`.
3. Adds test to `UserServiceTest.java`:

```java
@Test
void shouldThrowExceptionWhenUserNotFoundById() {
    // given
    given(userRepository.findById(999L)).willReturn(Optional.empty());

    // when & then
    assertThatThrownBy(() -> userService.findById(999L))
        .isInstanceOf(UserNotFoundException.class)
        .hasMessageContaining("999");
}
```

4. Runs `./gradlew test`
5. **Result:** Build succeeds. `shouldReturnUserWhenFoundById` passes. `shouldThrowExceptionWhenUserNotFoundById` FAILS — expected `UserNotFoundException` but no exception was thrown (method returned `null`).

**Red Agent Report:**
```
STATUS: SUCCESS (test fails as expected)
Test file: src/test/java/com/example/service/UserServiceTest.java
Test method: shouldThrowExceptionWhenUserNotFoundById()
Failure message: Expected UserNotFoundException to be thrown, but nothing was thrown.
Stub files created:
  - src/main/java/com/example/exception/UserNotFoundException.java
```

**Orchestrator check:** Test fails → proceed to GREEN.

---

#### GREEN Phase

**Agent spawn:** Green agent with prompt:

```
Role: GREEN agent in a TDD (Test-Driven Development) cycle.
Mission: Make the failing test PASS with the SIMPLEST possible implementation.

## Rules
- Write the MINIMUM code needed to make the test pass — no more, no less
- Do NOT refactor or clean up code — that is the refactor phase's job
- Do NOT modify tests — only modify production code
- Hardcoding values, simple conditionals, and "ugly" code are all acceptable
  — the goal is GREEN, not beautiful
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
- Project root: /Users/tobylee/workspace/project
- Source directory: src/main/java
- Test directory: src/test/java
- Test command: ./gradlew test
- Test framework: JUnit 5 (with Spring Boot Test)

## Context
- Failing test: UserServiceTest.shouldThrowExceptionWhenUserNotFoundById()
- Failure message: Expected UserNotFoundException to be thrown, but nothing was thrown.
- Current implementation: userRepository.findById(id).orElse(null)
- Source file: src/main/java/com/example/service/UserService.java
```

**Simulated Green Agent actions:**

1. Reads the failing test — expects `UserNotFoundException` when repository returns `Optional.empty()`.
2. Changes `UserService.findById()`:

```java
public User findById(Long id) {
    return userRepository.findById(id)
        .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
}
```

3. Runs `./gradlew test`
4. **Result:** 2 tests passed, 0 failed.

**Green Agent Report:**
```
STATUS: SUCCESS (all tests pass)
Files modified: src/main/java/com/example/service/UserService.java
  - findById() now throws UserNotFoundException instead of returning null
Test results: 2 passed, 0 failed
```

---

#### REFACTOR Phase

**Agent spawn:** Refactor agent (same base prompt as before with updated context):

```
...
## Context
- Just implemented: findById() now throws UserNotFoundException when user
  not found (replaced orElse(null) with orElseThrow)
- Source files:
  - src/main/java/com/example/model/User.java
  - src/main/java/com/example/repository/UserRepository.java
  - src/main/java/com/example/service/UserService.java
  - src/main/java/com/example/exception/UserNotFoundException.java
- Test files:
  - src/test/java/com/example/service/UserServiceTest.java (2 tests)
```

**Simulated Refactor Agent actions:**

1. Reads all files.
2. Identifies opportunities:
   - `UserNotFoundException` is a bare stub — could add a convenience constructor that takes the ID directly. This improves clarity.
   - Test file uses a magic number `999L` — could extract to a constant but with only 2 tests this is premature. Deferred.
3. Refactors `UserNotFoundException` to add a static factory method:

```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String message) {
        super(message);
    }

    public static UserNotFoundException withId(Long id) {
        return new UserNotFoundException("User not found with id: " + id);
    }
}
```

4. Updates `UserService.findById()` to use `UserNotFoundException.withId(id)`.
5. Runs `./gradlew test` — 2 passed, 0 failed.

**Refactor Agent Report:**
```
STATUS: Refactored
Changes:
  - Added static factory method UserNotFoundException.withId(Long) for clarity
  - Updated UserService.findById() to use the factory method
Deferred: Test constants extraction (premature with only 2 tests)
Test results: 2 passed, 0 failed
```

---

### Cycle 2 Summary and User Checkpoint

```
── TDD Cycle 2 Complete ──────────────────────────────
Task: findById throws exception when user not found

RED:      ✅ Test written: UserServiceTest.shouldThrowExceptionWhenUserNotFoundById()
GREEN:    ✅ Implementation: UserService.findById() — throws UserNotFoundException
REFACTOR: ✅ Extracted UserNotFoundException.withId() factory method

Tests: 2 passed, 0 failed
Files changed: UserService.java, UserServiceTest.java, UserNotFoundException.java

── Progress ──────────────────────────────────────────
[x] 1. findById returns user when exists           (Cycle 1)
[x] 2. findById throws exception when not found    (Cycle 2)
[>] 3. createUser saves and returns user
[ ] 4. createUser throws on duplicate email
[ ] 5. deleteUser removes existing user
[ ] 6. deleteUser throws when user not found

Continue with task 3? (or modify the remaining tasks)
```

At this checkpoint, the user can:

- **Continue as-is** — proceed with task 3 (createUser saves and returns user)
- **Modify tasks** — e.g., "4번은 빼고 진행하자" (skip duplicate email check)
- **Add tasks** — e.g., "findById에 null id 체크도 추가해줘" → inserts a new task
- **Reorder** — e.g., "deleteUser부터 하자" → move tasks 5-6 before 3-4
- **Stop** — end the TDD session and get a final summary

---

## Summary of Remaining Cycles (not walked through in detail)

If the user continues, the remaining cycles would follow the same pattern:

| Cycle | Task | RED | GREEN | REFACTOR |
|-------|------|-----|-------|----------|
| 3 | createUser saves and returns user | Test: call createUser, verify repository.save() called and user returned | Implement: delegate to repository.save() | Possibly extract validation helper |
| 4 | createUser throws on duplicate email | Test: mock repository to indicate email exists, expect exception | Implement: check existence before save | Possibly extract a DuplicateEmailException |
| 5 | deleteUser removes existing user | Test: call deleteUser, verify repository.deleteById() called | Implement: delegate to repository.deleteById() | Possibly unify "exists" checks |
| 6 | deleteUser throws when not found | Test: mock repository.existsById() returning false, expect exception | Implement: add existence check before delete | Final cleanup pass across all methods |

Each cycle follows the strict RED-GREEN-REFACTOR sequence with agent prompts, test verification, and user checkpoints.
