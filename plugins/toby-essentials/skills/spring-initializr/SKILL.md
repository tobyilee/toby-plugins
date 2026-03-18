---
name: Spring Initializr
version: 0.4.0
description: >
  Use this skill whenever a user wants to start a new Spring Boot project from scratch.
  Trigger phrases include "create a Spring Boot project", "generate a Spring project",
  "scaffold Spring Boot", "new Spring Boot app", "set up a Spring project",
  "Spring Boot 프로젝트 생성", "스프링 부트 프로젝트 만들어줘", "스프링 프로젝트 생성",
  "새 스프링 프로젝트", "스프링 부트 프로젝트 세팅", "Spring Boot 프로젝트부터 시작",
  "Kotlin Spring project", "Spring AI project", "Spring Native project".
  Also trigger when the user describes a new backend they want to build with Spring Boot,
  even indirectly — e.g. "Spring Boot + Kafka로 프로젝트 세팅해줘", "I want to build
  a REST API with Spring", "Spring Boot microservice 하나 만들어야 하는데",
  "챗봇 백엔드를 Spring Boot로 시작하고 싶어", "spring boot rest api project with h2",
  or mentions wanting to prototype/bootstrap/initialize a Spring-based application.
  Do NOT trigger for modifications to existing Spring projects (adding dependencies,
  changing config, upgrading versions, writing tests, debugging). This skill ensures
  Spring Initializr (start.spring.io) is always used instead of manually creating
  project files.
---

# Spring Initializr

Always use the Spring Initializr REST API when creating a new Spring Boot project. Never manually create build files, wrapper scripts, or project directory structures.

## Why Spring Initializr

Spring Initializr generates the canonical project structure with correct dependency coordinates, compatible versions, proper Gradle/Maven wrappers, and up-to-date starter names. Manual creation risks version mismatches, deprecated starters, and missing wrapper files.

## Express Mode vs Interactive Mode

Before starting the wizard, check whether the user's prompt already contains enough detail to skip interactive steps. If the user specified most of these — Boot version, language, dependencies, or project name — go directly to a **confirmation summary** (Step 5) instead of asking each question individually. Fill in sensible defaults for anything not specified.

**Express mode example:** "Spring Boot 3.4 + Kotlin + JPA + Security + Actuator 프로젝트 만들어줘" → skip to confirmation with those choices pre-filled.

**Interactive mode:** If the user just says "스프링 부트 프로젝트 만들어줘" without details, walk through the wizard steps below.

## Procedure

### Step 1. Fetch Metadata from Spring Initializr

Query the metadata endpoint to get available Boot versions, Java versions, and dependencies:

```bash
curl -s -H "Accept: application/json" https://start.spring.io | jq '{
  bootVersions: [.bootVersion.values[] | select(.id | test("SNAPSHOT|M[0-9]|RC[0-9]") | not) | .id],
  javaVersions: [.javaVersion.values[].id],
  defaultBootVersion: .bootVersion.default,
  defaultJavaVersion: .javaVersion.default,
  languages: [.language.values[].id],
  dependencies: [.dependencies.values[] | {group: .name, items: [.values[] | {id: .id, name: .name, description: .description}]}]
}'
```

Use this live data for all subsequent steps — do not hardcode versions.

**Important**: The metadata API may return version IDs with a `.RELEASE` suffix (e.g., `4.0.3.RELEASE`). Strip it before using in the download URL: `sed 's/.RELEASE$//'`.

### Step 2. Project Basics

Ask the user to configure core project settings in a **single** AskUserQuestion. Show all options with defaults so the user can confirm or override selectively:

```
── Project Configuration ──

1. Spring Boot version: 3.4.3 (available: 3.4.3, 3.3.8, 3.2.12)
2. Language: java (available: java, kotlin, groovy)
3. Java version: 21 (available: 24, 21, 17)
4. Build tool: gradle-project-kotlin (options: gradle-project-kotlin, gradle-project, maven-project)
5. Artifact ID: {current-dir-name}
6. Package name: toby.ai.{artifactId}
7. Config format: yaml (options: yaml, properties)

Press enter to accept all defaults, or specify changes like "2: kotlin, 3: 24, 7: properties"
```

Parse the user's response and apply changes. Anything not mentioned keeps its default.

**Language-specific adjustments:**
- If **Kotlin** is selected: default build tool becomes `gradle-project-kotlin`, and the generated project will use Kotlin source files
- If **Groovy** is selected: default build tool becomes `gradle-project`

### Step 3. Select Dependencies (Interactive)

Using the dependency data from Step 1, present dependencies grouped by category. Pre-select these defaults: **web**, **data-jpa**, **h2**, **lombok**.

If Kotlin was selected, swap **lombok** for **configuration-processor** since Kotlin data classes replace most Lombok use cases.

Format as a grouped list. Show each group with its dependencies, marking pre-selected ones with `[x]`:

```
Select dependencies (comma-separated numbers, or type dependency names):

── Web & API ──
 [x] 1. web - Spring Web (Build web apps with Spring MVC)
     2. webflux - Spring Reactive Web
     3. graphql - Spring for GraphQL
     ...

── Data & Persistence ──
 [x] 4. data-jpa - Spring Data JPA
 [x] 5. h2 - H2 Database
     6. postgresql - PostgreSQL Driver
     7. mysql - MySQL Driver
     8. flyway - Flyway Migration
     ...

── Developer Tools ──
 [x] 9. lombok - Lombok
     10. devtools - Spring Boot DevTools
     11. docker-compose - Docker Compose Support
     12. testcontainers - Testcontainers
     ...

── Security ──
     13. security - Spring Security
     14. oauth2-client - OAuth2 Client
     15. oauth2-resource-server - OAuth2 Resource Server
     ...

── Observability ──
     16. actuator - Spring Boot Actuator
     17. prometheus - Prometheus
     ...

── AI ──
     18. spring-ai-openai - Spring AI OpenAI
     19. spring-ai-anthropic - Spring AI Anthropic (Claude)
     20. spring-ai-ollama - Spring AI Ollama
     ...

── Cloud & Infrastructure ──
     21. cloud-gateway - Spring Cloud Gateway
     22. cloud-eureka - Eureka Client
     ...

(... remaining groups ...)

Pre-selected: web, data-jpa, h2, lombok
Enter additional numbers to add, or -N to remove a pre-selected one.
Press enter to accept defaults only.
```

The user can:
- Press enter to accept pre-selected defaults only
- Type numbers like `10,13,16` to add devtools, security, actuator
- Type `-9` to remove a pre-selected dependency
- Type dependency names directly like `security, actuator`

### Step 4. Spring Boot Feature Options

If the user's selections indicate advanced features, ask about them. Otherwise skip this step.

**Show this step only when relevant:**

- **Java 21+ selected** → offer Virtual Threads: "Enable virtual threads? (Adds `spring.threads.virtual.enabled=true`)"
- **GraalVM Native Image** → ask: "Do you want GraalVM Native Image support? This adds the native build plugin for ahead-of-time compilation."
- **Spring AI dependency selected** → note: "Spring AI requires additional configuration (API keys, model selection). I'll set up placeholder config after generation."

If none of these conditions apply, skip directly to Step 5.

### Step 5. Confirm and Generate

Show a summary of all selected parameters:

```
── Project Summary ──
Spring Boot: 3.4.3
Language: Kotlin
Java: 21
Build tool: Gradle (Kotlin DSL)
Group: toby
Artifact: my-service
Package: toby.ai.myservice
Config format: YAML
Dependencies: web, data-jpa, postgresql, security, actuator
Options: Virtual Threads enabled

Proceed? (yes/no)
```

### Step 6. Download and Extract

```bash
curl -s "https://start.spring.io/starter.zip?\
type={type}&language={language}&bootVersion={bootVersion}&\
baseDir={artifactId}&groupId=toby&artifactId={artifactId}&\
name={artifactId}&packageName={packageName}&\
javaVersion={javaVersion}&dependencies={dep1},{dep2},{dep3}" \
  -o $TMPDIR/{artifactId}.zip
```

Extract into the current directory:
```bash
unzip -o $TMPDIR/{artifactId}.zip -d .
mv {artifactId}/* {artifactId}/.* . 2>/dev/null; rmdir {artifactId} 2>/dev/null
```

If the current directory already has project files (build.gradle, pom.xml, src/), ask whether to extract into a subdirectory instead.

### Step 7. Post-Setup Configuration

After extraction, apply configuration based on the user's choices:

**Config file format:**
- If **YAML** was selected: rename `application.properties` to `application.yml` and convert content to YAML format
- If **properties** was selected: keep as-is

**Smart defaults by dependency:**

| Dependency | Configuration applied |
|------------|----------------------|
| H2 | Enable H2 console, set `datasource.url=jdbc:h2:mem:testdb`, `jpa.hibernate.ddl-auto=create-drop` |
| Docker Compose | Generate `compose.yaml` stub matching selected DB/messaging deps |
| Virtual Threads | Add `spring.threads.virtual.enabled=true` |
| Spring AI | Add placeholder API key config with comments explaining setup |
| Actuator | Expose health and info endpoints by default |

**GraalVM Native Image** (if selected):
- For Gradle: verify the `org.graalvm.buildtools.native` plugin is present
- For Maven: verify the `native-maven-plugin` is configured
- Add a note about native compilation: `./gradlew nativeCompile` or `./mvnw -Pnative native:compile`

### Step 8. Verify Build

```bash
./gradlew build    # Gradle projects
./mvnw verify      # Maven projects
```

### Step 9. Show Results

After a successful build:
1. Show the generated build file contents (`build.gradle.kts`, `build.gradle`, or `pom.xml`)
2. Show the project directory structure
3. Ask what to build next (entities, controllers, services, etc.)

## Error Handling

| Situation | Action |
|-----------|--------|
| `start.spring.io` unreachable | Inform user, suggest checking network connectivity |
| Invalid `bootVersion` | Use the fetched metadata to suggest valid alternatives |
| Unrecognized dependency | Query `https://start.spring.io/dependencies` for closest match |
| Directory not empty | Ask whether to extract into subdirectory or confirm overwrite |
| Build fails after extraction | Read error output, check Java version compatibility, suggest fixes |
| Kotlin + Lombok selected | Warn that Lombok has limited Kotlin support; suggest using data classes instead |

## Constraints

- **NEVER** manually write `build.gradle`, `pom.xml`, `gradlew`, or `gradle-wrapper.properties` for new projects
- **NEVER** guess dependency coordinates or plugin versions — let Spring Initializr resolve them
- **ALWAYS** use the generated Gradle/Maven wrapper for builds
- Prefer Kotlin DSL (`build.gradle.kts`) unless the user explicitly requests Groovy DSL

## Additional Resources

### Reference Files

For the complete dependency mapping table with all categories:
- **`references/dependency-mapping.md`** — Full mapping of user-friendly terms to Spring Initializr dependency IDs, used as fallback when the API is unreachable
