# TDD Team Skill Simulation

**Task (user request):** "이 기능 테스트 먼저 만들고 하나씩 구현하자: UserService에 findById, createUser, deleteUser 추가해줘"

**Translation:** "Let's write tests first and implement one by one: Add findById, createUser, deleteUser to UserService"

---

## Phase 0: Environment Detection

### What the skill instructs

The skill says: "Before creating the team, detect the project's language and build tool." It lists checking for `build.gradle`, `pom.xml`, `package.json`, etc.

### Simulated actions

1. **Glob for build files** in the project root:
   - Look for `build.gradle`, `build.gradle.kts`, `pom.xml`, `package.json`, `Cargo.toml`, `go.mod`
2. **Assume we find** `build.gradle.kts` (the Korean language and "Service" naming convention strongly suggest a Java/Kotlin + Spring project).
3. **Run** `./gradlew build` to verify the build tool works.
4. **Capture environment variables:**

```
PROJECT_ROOT: /Users/tobylee/workspace/project
SOURCE_DIR: src/main/java
TEST_DIR: src/test/java
BUILD_CMD: ./gradlew build
TEST_CMD: ./gradlew test
TEST_FRAMEWORK: JUnit 5
```

---

## Phase 1: Team Setup

### Simulated tool calls

#### 1. TeamCreate

```
TeamCreate(name: "tdd-cycle")
```

#### 2. Spawn three agents (in parallel)

Each agent gets its prompt from `references/agent-prompts.md` with the environment block appended.

```
TaskCreate(agent_type: "general-purpose", name: "red", team_name: "tdd-cycle",
  prompt: "<RED Agent Prompt from agent-prompts.md> + Environment block")

TaskCreate(agent_type: "general-purpose", name: "green", team_name: "tdd-cycle",
  prompt: "<GREEN Agent Prompt from agent-prompts.md> + Environment block")

TaskCreate(agent_type: "general-purpose", name: "refactor", team_name: "tdd-cycle",
  prompt: "<REFACTOR Agent Prompt from agent-prompts.md> + Environment block")
```

#### 3. Wait for all agents to report ready

All three agents confirm they are idle and waiting for instructions.

---

## Phase 2: Task Decomposition

The user wants three methods: `findById`, `createUser`, `deleteUser`. Per the skill's "Incremental Progress" principle: **each cycle adds ONE behavior**. So we plan three TDD cycles:

| Cycle | Behavior |
|-------|----------|
| 1 | `UserService.findById(Long id)` — returns a User by ID |
| 2 | `UserService.createUser(User user)` — saves and returns a new User |
| 3 | `UserService.deleteUser(Long id)` — deletes a User by ID |

**What we show the user at this point:**

> TDD 팀이 준비되었습니다. 3개의 기능을 하나씩 TDD 사이클로 구현합니다:
>
> 1. `findById` — 사용자 ID로 조회
> 2. `createUser` — 새 사용자 생성
> 3. `deleteUser` — 사용자 삭제
>
> 첫 번째 사이클 (`findById`)을 시작합니다.

---

## TDD Cycle 1: `findById`

### Step 1: RED Phase

#### Task creation (three tasks with dependencies)

```
TaskCreate(
  title: "[RED] Write failing test for UserService.findById",
  description: "Write a JUnit 5 test that calls UserService.findById(id) and asserts it returns the correct User. Create minimal stubs (UserService class, User entity) if they don't exist. The test must compile but FAIL.",
  team: "tdd-cycle"
) → Task #1

TaskCreate(
  title: "[GREEN] Implement UserService.findById to pass the test",
  description: "Implement the simplest code in UserService.findById that makes the RED test pass. Minimum viable implementation — hardcoding is acceptable.",
  team: "tdd-cycle",
  blocked_by: [Task #1]
) → Task #2

TaskCreate(
  title: "[REFACTOR] Clean up after findById implementation",
  description: "Review UserService and its test for duplication, naming, and structure improvements. All tests must still pass.",
  team: "tdd-cycle",
  blocked_by: [Task #2]
) → Task #3
```

#### Assign RED task

```
TaskUpdate(task_id: #1, assignee: "red", status: "in_progress")
```

#### Send message to RED agent

```
SendMessage(
  to: "red",
  type: "message",
  content: """
    Task #1: [RED] Write failing test for UserService.findById

    Create a test for UserService.findById(Long id):
    - The method should return a User object matching the given ID
    - If no UserService or User class exists yet, create minimal stubs in src/main/java
    - Stubs must compile but NOT implement real logic (throw UnsupportedOperationException or return null)
    - Test file: src/test/java/com/example/service/UserServiceTest.java
    - Source stubs: src/main/java/com/example/service/UserService.java, src/main/java/com/example/domain/User.java
    - Run: ./gradlew test
    - Verify: test compiles, test FAILS
  """
)
```

#### RED agent works (simulated)

The RED agent:
1. Reads existing files — finds no UserService or User class yet.
2. Creates stub `User.java` with `id`, `name`, `email` fields, a constructor, and getters.
3. Creates stub `UserService.java` with `findById(Long id)` that throws `UnsupportedOperationException`.
4. Creates `UserServiceTest.java`:

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @InjectMocks
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    @Test
    void findById_shouldReturnUser_whenUserExists() {
        // given
        Long userId = 1L;
        User expectedUser = new User(userId, "Alice", "alice@example.com");
        when(userRepository.findById(userId)).thenReturn(Optional.of(expectedUser));

        // when
        User result = userService.findById(userId);

        // then
        assertThat(result).isEqualTo(expectedUser);
    }
}
```

5. Also creates a stub `UserRepository` interface.
6. Runs `./gradlew test` — build succeeds, test FAILS with `UnsupportedOperationException`.

#### RED agent reports back

```
SendMessage(
  to: "team-lead",
  type: "message",
  content: """
    Task #1 complete.
    - Test file: src/test/java/com/example/service/UserServiceTest.java
    - Test method: findById_shouldReturnUser_whenUserExists
    - Result: Test FAILS (UnsupportedOperationException) — RED state confirmed.
    - Stubs created: User.java, UserService.java, UserRepository.java
  """
)
```

#### Orchestrator receives — proceeds to GREEN

```
TaskUpdate(task_id: #1, status: "completed")
```

### Step 2: GREEN Phase

#### Assign GREEN task

```
TaskUpdate(task_id: #2, assignee: "green", status: "in_progress")
```

#### Send message to GREEN agent

```
SendMessage(
  to: "green",
  type: "message",
  content: """
    Task #2: [GREEN] Implement UserService.findById to pass the test

    The RED test expects:
    - UserService.findById(Long id) delegates to UserRepository.findById(id)
    - Returns the User from the Optional
    - Test file: src/test/java/com/example/service/UserServiceTest.java
    - Source file: src/main/java/com/example/service/UserService.java
    - Write the MINIMUM code to make the test pass. Do NOT modify the test.
    - Run: ./gradlew test
    - Verify: ALL tests pass
  """
)
```

#### GREEN agent works (simulated)

The GREEN agent:
1. Reads `UserServiceTest.java` to understand what is expected.
2. Reads `UserService.java` — sees the stub throwing `UnsupportedOperationException`.
3. Implements the simplest passing code:

```java
@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User findById(Long id) {
        return userRepository.findById(id).orElse(null);
    }
}
```

4. Runs `./gradlew test` — ALL tests pass.

#### GREEN agent reports back

```
SendMessage(
  to: "team-lead",
  type: "message",
  content: """
    Task #2 complete.
    - Modified: src/main/java/com/example/service/UserService.java
    - Added constructor injection of UserRepository
    - Implemented findById: delegates to repository.findById().orElse(null)
    - All tests pass (1 test, 0 failures)
  """
)
```

#### Orchestrator receives — proceeds to REFACTOR

```
TaskUpdate(task_id: #2, status: "completed")
```

### Step 3: REFACTOR Phase

#### Assign REFACTOR task

```
TaskUpdate(task_id: #3, assignee: "refactor", status: "in_progress")
```

#### Send message to REFACTOR agent

```
SendMessage(
  to: "refactor",
  type: "message",
  content: """
    Task #3: [REFACTOR] Clean up after findById implementation

    Review the current state of:
    - src/main/java/com/example/service/UserService.java
    - src/main/java/com/example/domain/User.java
    - src/main/java/com/example/repository/UserRepository.java
    - src/test/java/com/example/service/UserServiceTest.java

    Look for: naming improvements, unnecessary code, test readability.
    Do NOT change behavior. All tests must still pass after changes.
    Run: ./gradlew test
  """
)
```

#### REFACTOR agent works (simulated)

The REFACTOR agent:
1. Reads all four files.
2. Notes: `findById` returns `null` when user not found — could throw an exception, but that would change behavior. Defers.
3. Notes: test is clean and well-structured. No duplication yet (only one test).
4. Minor improvement: adds `@RequiredArgsConstructor` (Lombok) to `UserService` if Lombok is available, removing boilerplate constructor.
5. Runs `./gradlew test` — all tests pass.

#### REFACTOR agent reports back

```
SendMessage(
  to: "team-lead",
  type: "message",
  content: """
    Task #3 complete.
    - Applied @RequiredArgsConstructor to UserService (removed manual constructor)
    - No other refactoring needed — code is minimal and clean
    - Deferred: Consider throwing an exception for user-not-found (behavior change, needs its own TDD cycle)
    - All tests pass (1 test, 0 failures)
  """
)
```

```
TaskUpdate(task_id: #3, status: "completed")
```

### Step 4: Report to User (Cycle 1 Complete)

The orchestrator reads the current source and test files, then presents:

> **TDD Cycle 1 완료: `findById`**
>
> | Phase | Result |
> |-------|--------|
> | RED | `findById_shouldReturnUser_whenUserExists` 테스트 작성 — 실패 확인 |
> | GREEN | `UserService.findById()` 구현 — `UserRepository`에 위임 |
> | REFACTOR | `@RequiredArgsConstructor` 적용, 불필요한 생성자 제거 |
>
> **생성된 파일:**
> - `src/main/java/com/example/domain/User.java`
> - `src/main/java/com/example/repository/UserRepository.java`
> - `src/main/java/com/example/service/UserService.java`
> - `src/test/java/com/example/service/UserServiceTest.java`
>
> **테스트 결과:** 1 passed, 0 failed
>
> 다음 사이클 (`createUser`)을 시작합니다.

---

## TDD Cycle 2: `createUser`

### Step 1: RED Phase

#### Task creation

```
TaskCreate(
  title: "[RED] Write failing test for UserService.createUser",
  description: "Write a JUnit 5 test that calls UserService.createUser(User) and asserts it saves and returns the created User. The test must compile but FAIL.",
  team: "tdd-cycle"
) → Task #4

TaskCreate(
  title: "[GREEN] Implement UserService.createUser to pass the test",
  description: "Implement the simplest code in UserService.createUser that makes the RED test pass.",
  team: "tdd-cycle",
  blocked_by: [Task #4]
) → Task #5

TaskCreate(
  title: "[REFACTOR] Clean up after createUser implementation",
  description: "Review UserService and its tests for cleanup opportunities. All tests must still pass.",
  team: "tdd-cycle",
  blocked_by: [Task #5]
) → Task #6
```

#### Assign RED task

```
TaskUpdate(task_id: #4, assignee: "red", status: "in_progress")
```

#### Send message to RED agent

```
SendMessage(
  to: "red",
  type: "message",
  content: """
    Task #4: [RED] Write failing test for UserService.createUser

    Add a new test to UserServiceTest for UserService.createUser(User user):
    - The method should save the user via UserRepository.save() and return the saved user
    - Add a stub method to UserService that throws UnsupportedOperationException
    - Test file: src/test/java/com/example/service/UserServiceTest.java
    - Source file: src/main/java/com/example/service/UserService.java
    - Run: ./gradlew test
    - Verify: new test FAILS, existing findById test still PASSES
  """
)
```

#### RED agent works (simulated)

The RED agent:
1. Reads existing `UserServiceTest.java` — sees one test method, follows the same pattern.
2. Adds a stub method to `UserService.java`:
   ```java
   public User createUser(User user) {
       throw new UnsupportedOperationException();
   }
   ```
3. Adds a `save` method to `UserRepository` if not present.
4. Writes the new test:

```java
@Test
void createUser_shouldSaveAndReturnUser() {
    // given
    User newUser = new User(null, "Bob", "bob@example.com");
    User savedUser = new User(1L, "Bob", "bob@example.com");
    when(userRepository.save(newUser)).thenReturn(savedUser);

    // when
    User result = userService.createUser(newUser);

    // then
    assertThat(result).isEqualTo(savedUser);
    assertThat(result.getId()).isNotNull();
    verify(userRepository).save(newUser);
}
```

5. Runs `./gradlew test`:
   - `findById_shouldReturnUser_whenUserExists` — PASSES
   - `createUser_shouldSaveAndReturnUser` — FAILS (UnsupportedOperationException)

#### RED agent reports back

```
SendMessage(
  to: "team-lead",
  type: "message",
  content: """
    Task #4 complete.
    - Test method: createUser_shouldSaveAndReturnUser
    - Result: new test FAILS (UnsupportedOperationException), existing test still passes
    - RED state confirmed
    - Stub added: UserService.createUser(User) throws UnsupportedOperationException
  """
)
```

```
TaskUpdate(task_id: #4, status: "completed")
```

### Step 2: GREEN Phase

#### Assign GREEN task

```
TaskUpdate(task_id: #5, assignee: "green", status: "in_progress")
```

#### Send message to GREEN agent

```
SendMessage(
  to: "green",
  type: "message",
  content: """
    Task #5: [GREEN] Implement UserService.createUser to pass the test

    The RED test expects:
    - UserService.createUser(User) calls userRepository.save(user)
    - Returns the saved User object
    - Test file: src/test/java/com/example/service/UserServiceTest.java
    - Source file: src/main/java/com/example/service/UserService.java
    - Write MINIMUM code. Do NOT modify tests.
    - Run: ./gradlew test
    - Verify: ALL tests pass (both findById and createUser)
  """
)
```

#### GREEN agent works (simulated)

The GREEN agent:
1. Reads the failing test to understand expectations.
2. Replaces the stub in `UserService.java`:

```java
public User createUser(User user) {
    return userRepository.save(user);
}
```

3. Runs `./gradlew test` — 2 tests, 0 failures. All pass.

#### GREEN agent reports back

```
SendMessage(
  to: "team-lead",
  type: "message",
  content: """
    Task #5 complete.
    - Modified: UserService.java — implemented createUser as repository.save(user)
    - All tests pass (2 tests, 0 failures)
  """
)
```

```
TaskUpdate(task_id: #5, status: "completed")
```

### Step 3: REFACTOR Phase

#### Assign REFACTOR task

```
TaskUpdate(task_id: #6, assignee: "refactor", status: "in_progress")
```

#### Send message to REFACTOR agent

```
SendMessage(
  to: "refactor",
  type: "message",
  content: """
    Task #6: [REFACTOR] Clean up after createUser implementation

    Review:
    - src/main/java/com/example/service/UserService.java (now has findById + createUser)
    - src/test/java/com/example/service/UserServiceTest.java (now has 2 tests)
    - Look for: test setup duplication, naming, common patterns to extract
    - Run: ./gradlew test
  """
)
```

#### REFACTOR agent works (simulated)

The REFACTOR agent:
1. Reads both files.
2. Notices both tests create `User` objects with similar patterns — but with only 2 tests, extracting a helper is premature.
3. Checks if test class could benefit from a `@BeforeEach` setup — mock injection is already handled by `@InjectMocks`, so no gain.
4. Notes that `findById` returns `null` on miss while `createUser` has no validation — these are behavior additions for future cycles.
5. Decides: **no refactoring needed** at this point. Code is clean and minimal.
6. Runs `./gradlew test` — all pass (no changes made).

#### REFACTOR agent reports back

```
SendMessage(
  to: "team-lead",
  type: "message",
  content: """
    Task #6 complete.
    - No refactoring needed — code is clean and minimal with only 2 methods
    - Deferred opportunities:
      - Extract test data factory when more tests accumulate
      - Consider adding input validation to createUser (needs its own TDD cycle)
    - All tests pass (2 tests, 0 failures)
  """
)
```

```
TaskUpdate(task_id: #6, status: "completed")
```

### Step 4: Report to User (Cycle 2 Complete)

> **TDD Cycle 2 완료: `createUser`**
>
> | Phase | Result |
> |-------|--------|
> | RED | `createUser_shouldSaveAndReturnUser` 테스트 작성 — 실패 확인 |
> | GREEN | `UserService.createUser()` 구현 — `repository.save()` 위임 |
> | REFACTOR | 리팩터링 불필요 — 코드가 깔끔하고 최소한의 상태 |
>
> **현재 상태:**
> - `UserService`: `findById`, `createUser` 구현 완료
> - 테스트: 2 passed, 0 failed
>
> 다음 사이클 (`deleteUser`)을 시작합니다.

---

## Remaining Cycle 3 (not fully walked through)

Cycle 3 (`deleteUser`) would follow the identical pattern:
- **RED:** Write `deleteUser_shouldCallRepositoryDelete` test, stub `deleteUser` to throw.
- **GREEN:** Implement `userRepository.deleteById(id)`.
- **REFACTOR:** With 3 methods and 3 tests, possibly extract test data builders or a `@BeforeEach` setup. Verify all 3 tests pass.

---

## Summary of Orchestration Flow

```
User Request
  │
  ├─ Environment Detection (Glob, Bash: ./gradlew build)
  │
  ├─ TeamCreate("tdd-cycle")
  ├─ Spawn: red, green, refactor agents (parallel)
  │
  ├─ Cycle 1: findById
  │   ├─ TaskCreate x3 (RED/GREEN/REFACTOR with dependencies)
  │   ├─ RED:  TaskUpdate → SendMessage → wait → TaskUpdate(completed)
  │   ├─ GREEN: TaskUpdate → SendMessage → wait → TaskUpdate(completed)
  │   ├─ REFACTOR: TaskUpdate → SendMessage → wait → TaskUpdate(completed)
  │   └─ Report to user
  │
  ├─ Cycle 2: createUser
  │   ├─ TaskCreate x3
  │   ├─ RED → GREEN → REFACTOR (same flow)
  │   └─ Report to user
  │
  ├─ Cycle 3: deleteUser
  │   ├─ TaskCreate x3
  │   ├─ RED → GREEN → REFACTOR (same flow)
  │   └─ Report to user
  │
  └─ Session complete — TeamDelete("tdd-cycle")
```

### Tool Call Count per Cycle

| Tool | Calls per cycle |
|------|----------------|
| TaskCreate | 3 |
| TaskUpdate | 6 (assign x3, complete x3) |
| SendMessage | 3 (one to each agent) |
| **Total** | **12 tool calls per cycle** |
| **Total for 3 cycles** | **36 + setup (~5) + teardown (~4) = ~45 tool calls** |

---

## Key Observations

1. **Strict phase separation is maintained:** RED only writes tests and stubs, GREEN only writes production code, REFACTOR only cleans up.
2. **Incremental progress:** Each cycle adds exactly one behavior — `findById`, then `createUser`, then `deleteUser`.
3. **The orchestrator (team lead) never writes code directly** — it delegates everything through agent messages.
4. **Error handling paths exist but were not triggered** in this simulation (e.g., test passes unexpectedly, build fails, refactor breaks tests).
5. **User communication is in Korean** matching the user's language, with technical terms in English.
