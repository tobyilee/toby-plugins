---
name: spring-boot4-guide
description: >
  Guide for developing with Spring Boot 4 and Spring Framework 7. Use this skill
  whenever the user is working on a Spring Boot 4 project, asking about Spring Boot 4
  or Spring Framework 7 changes, migrating from Boot 3 to 4, or encountering issues
  related to Boot 4 breaking changes. Trigger on "Spring Boot 4", "Spring 7",
  "Boot 4 migration", "Spring Boot 4 변경사항", "Boot 4로 업그레이드",
  "Spring Boot 4 프로젝트", "spring-boot 4.x", "Spring Framework 7 변경",
  "Boot 4 에러", "Jackson 3 마이그레이션". Also trigger when the user creates a
  new Spring Boot project and the version is 4.x, or when build errors suggest
  Boot 4 compatibility issues (e.g., missing starters, Jakarta EE 11 issues,
  Jackson 3 package errors, HttpHeaders API changes). Do NOT trigger for
  Spring Boot 3.x or earlier questions that don't involve upgrading.
version: 0.1.0
---

# Spring Boot 4 / Spring Framework 7 Guide

Spring Boot 4 (November 2025) is built on Spring Framework 7 and introduces significant structural changes. This skill provides the essential knowledge for developing with or migrating to Boot 4.

## Baseline Requirements

| Dependency | Minimum | Recommended |
|-----------|---------|-------------|
| Java | 17 | 25 (LTS) |
| Jakarta EE | 11 | — |
| Servlet | 6.1 (Tomcat 11+, Jetty 12.1+) | — |
| JPA | 3.2 (Hibernate 7.1/7.2) | — |
| Jackson | 3.x (2.x deprecated) | — |
| Kotlin | 2.2+ | — |
| GraalVM | 25+ | — |
| JUnit | 6 (JUnit 4 deprecated) | — |

## Critical Breaking Changes

These are the changes most likely to cause immediate build or runtime failures.

### 1. Modularization — Starter POM overhaul

Boot 4's biggest structural change: the monolithic `spring-boot-autoconfigure` has been split into technology-specific modules. Starter POMs are renamed and restructured.

**Immediate impact:**
```xml
<!-- BEFORE (Boot 3) -->
<artifactId>spring-boot-starter-web</artifactId>

<!-- AFTER (Boot 4) -->
<artifactId>spring-boot-starter-webmvc</artifactId>
```

Key renames:

| Boot 3 | Boot 4 |
|--------|--------|
| `spring-boot-starter-web` | `spring-boot-starter-webmvc` |
| `spring-boot-starter-aop` | `spring-boot-starter-aspectj` |
| `spring-boot-starter-oauth2-client` | `spring-boot-starter-security-oauth2-client` |
| `spring-boot-starter-oauth2-resource-server` | `spring-boot-starter-security-oauth2-resource-server` |

Technologies that previously only needed a 3rd-party dependency (e.g., Flyway, Liquibase) now require a dedicated starter:
- `spring-boot-starter-flyway`
- `spring-boot-starter-liquibase`

Test starters are also separated: `spring-boot-starter-<tech>-test`. For example, `@WithMockUser` requires `spring-boot-starter-security-test`.

**Quick migration path:** Use `spring-boot-starter-classic` / `spring-boot-starter-test-classic` temporarily, then migrate incrementally.

For the full starter mapping table, see `references/modularization.md`.

### 2. Jackson 3.x

Boot 4 defaults to Jackson 3. The package name changed from `com.fasterxml.jackson` to `tools.jackson` (except annotations which stay in `com.fasterxml.jackson.annotation`).

Key changes:
- `Jackson2ObjectMapperBuilder` removed → use `JsonMapper.builder()`
- `@JsonComponent` → `@JacksonComponent`
- `@JsonMixin` → `@JacksonMixin`
- Properties: `spring.jackson.read.*` → `spring.jackson.json.read.*`

For Jackson 2 compatibility during migration, add `spring-boot-jackson2` module and use `spring.jackson.use-jackson2-defaults=true`.

For detailed migration steps, see `references/jackson3-migration.md`.

### 3. `javax.*` completely removed

`javax.annotation` and `javax.inject` annotations are no longer supported. All code must use `jakarta.annotation` / `jakarta.inject` equivalents. This is not new from Jakarta EE 9 migration, but Spring 7 removes any remaining fallback support.

### 4. `HttpHeaders` no longer extends `MultiValueMap`

This is a subtle but widespread breaking change. Code that treats `HttpHeaders` as a `MultiValueMap` will fail. Use `HttpHeaders#asMultiValueMap()` as a temporary bridge (itself deprecated).

### 5. Null Safety — JSpecify

Spring's own `@Nullable` / `@NonNull` annotations (`org.springframework.lang`) are deprecated in favor of JSpecify (`org.jspecify.annotations`). Kotlin projects may see compilation errors from changed nullability.

### 6. Undertow removed

Undertow doesn't support Servlet 6.1 yet. Use Tomcat 11+ or Jetty 12.1+.

### 7. RestTemplate deprecated

`RestTemplate` is officially deprecated. Use `RestClient` (introduced in 6.1) for imperative HTTP calls.

## New Features Worth Knowing

### API Versioning (built-in)

Spring MVC and WebFlux now support API versioning natively:

```java
@GetMapping("/users")
@ApiVersion("1")
public List<UserV1> getUsersV1() { ... }

@GetMapping("/users")
@ApiVersion("2")
public List<UserV2> getUsersV2() { ... }
```

Configurable version resolution (header, path, query param), deprecation marking, and client-side support in `RestClient`/`WebClient`.

### Resilience — Built-in Retry & Concurrency

Spring Retry has been absorbed into Spring Framework core:

```java
@EnableResilientMethods
@Configuration
public class AppConfig { }

@Retryable(maxAttempts = 3)
public String callApi() { ... }

@ConcurrencyLimit(limit = 10)
public String heavy() { ... }
```

Works with reactive methods too (auto-adapts to Reactor retry).

### `RestTestClient` — Non-reactive test client

The community-requested replacement for `WebTestClient` that doesn't require reactive dependencies:

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureRestTestClient
class MyTest {
    @Autowired
    RestTestClient restTestClient;
}
```

### Programmatic Bean Registration

New `BeanRegistrar` contract for flexible, multi-bean registration beyond `@Bean` methods:

```java
public class MyRegistrar implements BeanRegistrar {
    @Override
    public void register(BeanRegistry registry, Environment env) {
        registry.registerBean("myService", MyService.class);
    }
}
```

### `@ImportHttpServices` — Simplified HTTP client config

```java
@Configuration
@ImportHttpServices(group = "weather", types = {WeatherApi.class})
static class Config extends AbstractHttpServiceRegistrar { }
```

### `JmsClient`

Fluent JMS client following the `JdbcClient`/`RestClient` pattern.

### JPA 3.2 Improvements

- `EntityManager` / `EntityManagerFactory` directly injectable via `@Autowired`
- Hibernate `StatelessSession` DI support
- `PersistenceConfiguration` for XML-free JPA setup

For comprehensive feature details, see `references/new-features.md`.

## Testing Changes

These changes will affect almost every test class:

| Change | Action Required |
|--------|----------------|
| `@SpringBootTest` no longer auto-configures MockMVC | Add `@AutoConfigureMockMvc` |
| `@SpringBootTest` no longer provides `TestRestTemplate` | Add `@AutoConfigureTestRestTemplate` |
| `@MockBean` / `@SpyBean` | Deprecated → use `@MockitoBean` / `@MockitoSpyBean` |
| JUnit 4 support | Deprecated → use JUnit Jupiter `SpringExtension` |
| `@Mock` / `@Captor` fields | Require `MockitoExtension` from Mockito directly |

For full testing migration details, see `references/testing-changes.md`.

## Migration Strategy

1. Upgrade to latest **3.5.x** first — fix all deprecation warnings
2. Switch to Boot 4 with `spring-boot-starter-classic` for quick compatibility
3. Fix `javax.*` → `jakarta.*` if any remain
4. Update starter POMs to new names
5. Migrate Jackson 2 → 3 (or use `spring-boot-jackson2` temporarily)
6. Update test annotations (`@AutoConfigureMockMvc`, `@MockitoBean`, etc.)
7. Replace `spring-boot-starter-classic` with individual technology starters
8. Adopt JSpecify nullability annotations
9. Replace `RestTemplate` with `RestClient`

## Property Changes

Some commonly used properties have been renamed:

| Boot 3 | Boot 4 |
|--------|--------|
| `spring.data.mongodb.*` (some) | `spring.mongodb.*` |
| `spring.session.redis.*` | `spring.session.data.redis.*` |
| `spring.jackson.read.*` | `spring.jackson.json.read.*` |
| `spring.jackson.write.*` | `spring.jackson.json.write.*` |
| `spring.dao.exceptiontranslation.enabled` | `spring.persistence.exceptiontranslation.enabled` |

## Package Changes

| Boot 3 | Boot 4 |
|--------|--------|
| `org.springframework.boot.env.EnvironmentPostProcessor` | `org.springframework.boot.EnvironmentPostProcessor` |
| `org.springframework.boot.BootstrapRegistry` | `org.springframework.boot.bootstrap.BootstrapRegistry` |
| `org.springframework.boot.autoconfigure.orm.jpa.EntityScan` (concept) | `org.springframework.boot.persistence.autoconfigure.EntityScan` |
| `org.springframework.boot.test.autoconfigure.properties.PropertyMapping` | `org.springframework.boot.test.context.PropertyMapping` |

## Reference Files

- `references/modularization.md` — Full starter/module mapping tables and migration strategy
- `references/jackson3-migration.md` — Jackson 2→3 detailed migration guide
- `references/new-features.md` — All new features with examples
- `references/testing-changes.md` — Test code migration details
