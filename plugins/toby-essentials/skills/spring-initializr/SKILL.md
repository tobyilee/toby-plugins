---
name: Spring Initializr
version: 0.3.0
description: >
  This skill should be used when the user asks to "create a Spring Boot project",
  "generate a Spring project", "scaffold Spring Boot", "new Spring Boot app",
  "Spring Boot 프로젝트 생성", "스프링 부트 프로젝트 만들어", "스프링 프로젝트 생성",
  "새 스프링 프로젝트", or any request that involves creating a new Spring Boot/Spring
  Framework project from scratch. Ensures that Spring Initializr (start.spring.io) is
  always used instead of manually creating project files.
---

# Spring Initializr

Always use the Spring Initializr REST API when creating a new Spring Boot project. Never manually create build files, wrapper scripts, or project directory structures.

## Why Spring Initializr

Spring Initializr generates the canonical project structure with correct dependency coordinates, compatible versions, proper Gradle/Maven wrappers, and up-to-date starter names. Manual creation risks version mismatches, deprecated starters, and missing wrapper files.

## Procedure

This skill follows an interactive wizard flow. Use AskUserQuestion at each step so the user can confirm or change defaults. Present defaults clearly — the goal is to let the user press enter for common cases while still having full control.

### Step 1. Fetch Metadata from Spring Initializr

Query the metadata endpoint to get available Boot versions, Java versions, and dependencies:

```bash
curl -s -H "Accept: application/json" https://start.spring.io | jq '{
  bootVersions: [.bootVersion.values[] | select(.id | test("SNAPSHOT|M[0-9]|RC[0-9]") | not) | .id],
  javaVersions: [.javaVersion.values[].id],
  defaultBootVersion: .bootVersion.default,
  defaultJavaVersion: .javaVersion.default,
  dependencies: [.dependencies.values[] | {group: .name, items: [.values[] | {id: .id, name: .name, description: .description}]}]
}'
```

This gives you the real-time available versions and dependencies. Use this data for all subsequent steps — do not hardcode versions.

**Important**: The metadata API may return version IDs with a `.RELEASE` suffix (e.g., `4.0.3.RELEASE`). When constructing the download URL, strip the `.RELEASE` suffix — the generation endpoint expects just the version number (e.g., `4.0.3`). You can do this with: `sed 's/.RELEASE$//'`.

### Step 2. Ask Boot Version and Java Version

Use AskUserQuestion to ask the user to select a Spring Boot version and Java version. Show the available options from the metadata response.

Example:
```
Available Spring Boot versions: 3.4.3, 3.3.8, 3.2.12
Default: 3.4.3

Available Java versions: 24, 21, 17
Default: 21

Which Spring Boot version and Java version would you like?
(Press enter to use defaults: Boot 3.4.3, Java 21)
```

### Step 3. Ask Artifact ID

The **artifact ID** defaults to the current directory name (basename of `$PWD`). Use AskUserQuestion to confirm or change.

Example:
```
Artifact ID (project name): springinit
(This is based on your current folder name. Change it or press enter to confirm.)
```

### Step 4. Ask Package Name

The **package name** defaults to `toby.ai.{artifactId}` (dots replace hyphens). Use AskUserQuestion to confirm or change.

Example:
```
Package name: toby.ai.springinit
(Change it or press enter to confirm.)
```

### Step 5. Ask Build Tool

Present build tool options with `gradle-project-kotlin` as default:

- `gradle-project-kotlin` — Gradle with Kotlin DSL (default)
- `gradle-project` — Gradle with Groovy DSL
- `maven-project` — Maven

Use AskUserQuestion. Most users will accept the default.

### Step 6. Select Dependencies (Interactive)

This is the most important interactive step. Using the dependency data fetched in Step 1, present dependencies **grouped by category**. Pre-select these four by default: **web** (Spring Web MVC), **data-jpa** (Spring Data JPA), **h2** (H2 Database), **lombok**.

Format the dependency selection as a grouped list for AskUserQuestion. Show each group with its dependencies, marking pre-selected ones with `[x]`:

```
Select dependencies (comma-separated numbers, or type dependency names):

── Web & API ──
 [x] 1. web - Spring Web (Build web apps with Spring MVC)
     2. webflux - Spring Reactive Web
     3. graphql - Spring for GraphQL
     4. websocket - WebSocket
     ...

── Data & Persistence ──
 [x] 5. data-jpa - Spring Data JPA
 [x] 6. h2 - H2 Database
     7. postgresql - PostgreSQL Driver
     8. mysql - MySQL Driver
     9. data-mongodb - Spring Data MongoDB
     ...

── Developer Tools ──
 [x] 10. lombok - Lombok
     11. devtools - Spring Boot DevTools
     12. docker-compose - Docker Compose Support
     13. testcontainers - Testcontainers
     ...

── Security ──
     14. security - Spring Security
     15. oauth2-client - OAuth2 Client
     ...

── Observability ──
     16. actuator - Spring Boot Actuator
     17. prometheus - Prometheus
     ...

(... remaining groups ...)

Pre-selected: web, data-jpa, h2, lombok
Enter additional numbers to add, or -N to remove a pre-selected one.
```

The user can:
- Press enter to accept pre-selected defaults only
- Type numbers like `11,14,16` to add devtools, security, actuator
- Type `-1` to remove a pre-selected dependency
- Type dependency names directly like `security, actuator`

Parse the user's response and build the final dependency list.

### Step 7. Confirm and Generate

Show a summary of all selected parameters before generating:

```
── Project Summary ──
Spring Boot: 3.4.3
Java: 21
Build tool: Gradle (Kotlin DSL)
Group: toby
Artifact: springinit
Package: toby.ai.springinit
Dependencies: web, data-jpa, h2, lombok, security, actuator

Proceed? (yes/no)
```

Use AskUserQuestion for final confirmation.

### Step 8. Download and Extract

```bash
curl -s "https://start.spring.io/starter.zip?\
type={type}&language=java&bootVersion={bootVersion}&\
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

### Step 9. Verify Build

```bash
./gradlew build    # Gradle projects
./mvnw verify      # Maven projects
```

### Step 10. Post-Setup

After a successful build:
1. Show the generated `build.gradle` (or `pom.xml`) contents
2. Show the project directory structure
3. Apply smart defaults for common dependencies:
   - **H2**: Enable H2 console in `application.properties`, set `spring.datasource.url=jdbc:h2:mem:testdb`, configure `spring.jpa.hibernate.ddl-auto=create-drop`
   - **Docker Compose**: Generate a `compose.yaml` stub matching selected DB/messaging dependencies
4. Ask what to build next (entities, controllers, services, etc.)

## Error Handling

| Situation | Action |
|-----------|--------|
| `start.spring.io` unreachable | Inform user, suggest checking network connectivity |
| Invalid `bootVersion` | Use the fetched metadata to suggest valid alternatives |
| Unrecognized dependency | Query `https://start.spring.io/dependencies` for closest match |
| Directory not empty | Ask whether to extract into subdirectory or confirm overwrite |
| Build fails after extraction | Read error output, check Java version compatibility, suggest fixes |

## Constraints

- **NEVER** manually write `build.gradle`, `pom.xml`, `gradlew`, or `gradle-wrapper.properties` for new projects
- **NEVER** guess dependency coordinates or plugin versions — let Spring Initializr resolve them
- **ALWAYS** use the generated Gradle/Maven wrapper for builds
- Prefer Kotlin DSL (`build.gradle.kts`) unless the user explicitly requests Groovy DSL

## Additional Resources

### Reference Files

For the complete dependency mapping table with all categories:
- **`references/dependency-mapping.md`** — Full mapping of user-friendly terms to Spring Initializr dependency IDs, used as fallback when the API is unreachable
