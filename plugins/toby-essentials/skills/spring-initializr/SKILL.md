---
name: Spring Initializr
version: 0.2.0
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

### 1. Gather Requirements

Extract parameters from the user's request:

| Parameter | API Key | Default |
|-----------|---------|---------|
| Build tool | `type` | `gradle-project` |
| Language | `language` | `java` |
| Spring Boot version | `bootVersion` | _(latest stable)_ |
| Java version | `javaVersion` | `25` |
| Group ID | `groupId` | `toby` |
| Artifact ID | `artifactId` | _(ask user)_ |
| Package name | `packageName` | `toby.{artifactId}` |
| Dependencies | `dependencies` | _(from user request)_ |

**Build tool `type` values:**
- `gradle-project` — Gradle with Groovy DSL (default)
- `gradle-project-kotlin` — Gradle with Kotlin DSL
- `maven-project` — Maven

**Critical**: If the user did NOT explicitly specify `artifactId` or `packageName`, ask before proceeding. Present defaults and request confirmation.

### 2. Map Dependencies

Consult `references/dependency-mapping.md` for the full mapping table. Common examples:

| User says | Dependency ID |
|-----------|---------------|
| Web, REST API | `web` |
| JPA | `data-jpa` |
| H2 | `h2` |
| Security | `security` |
| Lombok | `lombok` |
| Spring AI Claude | `spring-ai-anthropic` |

For unknown dependencies, query the capabilities endpoint:
```bash
curl -s https://start.spring.io/dependencies | jq '.dependencies[].values[].id' | grep -i "{keyword}"
```

### 3. Download and Extract

```bash
curl -s "https://start.spring.io/starter.zip?\
type={type}&language={language}&bootVersion={bootVersion}&\
baseDir={artifactId}&groupId={groupId}&artifactId={artifactId}&\
name={artifactId}&packageName={packageName}&\
javaVersion={javaVersion}&dependencies={dep1},{dep2},{dep3}" \
  -o $TMPDIR/{artifactId}.zip
```

Extract into the target directory:
```bash
# Into current directory (if empty or user confirms)
unzip -o $TMPDIR/{artifactId}.zip -d .
mv {artifactId}/* {artifactId}/.* . 2>/dev/null; rmdir {artifactId} 2>/dev/null

# Or into a new subdirectory
unzip -o $TMPDIR/{artifactId}.zip -d .
```

**Before extracting**: Check if the current directory already has project files. If so, ask whether to extract into a subdirectory or overwrite.

### 4. Verify Build

```bash
./gradlew build    # Gradle projects
./mvnw verify      # Maven projects
```

### 5. Post-Setup

After a successful build:
1. Show the generated `build.gradle` (or `pom.xml`) contents
2. Show the project directory structure
3. Apply smart defaults for common dependencies:
   - **H2**: Enable H2 console, set datasource URL/credentials, configure JPA ddl-auto
   - **Docker Compose**: Generate a `compose.yaml` stub matching selected DB/messaging dependencies
4. Ask what to build next (entities, controllers, services, etc.)

## Error Handling

| Situation | Action |
|-----------|--------|
| `start.spring.io` unreachable | Inform user, suggest checking network connectivity |
| Invalid `bootVersion` | Fetch available versions from `https://start.spring.io` and suggest alternatives |
| Unrecognized dependency | Query `https://start.spring.io/dependencies` for closest match |
| Directory not empty | Ask whether to extract into subdirectory or confirm overwrite |
| Build fails after extraction | Read error output, check Java version compatibility, suggest fixes |

## Constraints

- **NEVER** manually write `build.gradle`, `pom.xml`, `gradlew`, or `gradle-wrapper.properties` for new projects
- **NEVER** guess dependency coordinates or plugin versions — let Spring Initializr resolve them
- **ALWAYS** use the generated Gradle/Maven wrapper for builds
- Prefer Groovy DSL (`build.gradle`) unless the user explicitly requests Kotlin DSL

## Additional Resources

### Reference Files

For the complete dependency mapping table with all categories:
- **`references/dependency-mapping.md`** — Full mapping of user-friendly terms to Spring Initializr dependency IDs, including Web, Data, Security, Cloud, AI, and more
