# Spring Boot 4 Testing Changes

## @SpringBootTest Changes

`@SpringBootTest` is now more minimal — it no longer auto-configures several testing utilities.

### MockMVC

```java
// Boot 3 — worked without @AutoConfigureMockMvc
@SpringBootTest
class MyTest {
    @Autowired MockMvc mockMvc;  // auto-configured
}

// Boot 4 — must add annotation explicitly
@SpringBootTest
@AutoConfigureMockMvc
class MyTest {
    @Autowired MockMvc mockMvc;
}
```

HtmlUnit configuration moved to nested attribute:

```java
// Boot 3
@AutoConfigureMockMvc(webClientEnabled = false, webDriverEnabled = false)

// Boot 4
@AutoConfigureMockMvc(htmlUnit = @HtmlUnit(webClient = false, webDriver = false))
```

### TestRestTemplate

```java
// Boot 4 — add annotation + dependencies
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
class MyTest {
    @Autowired TestRestTemplate restTemplate;
}
```

Requires `spring-boot-resttestclient` and `spring-boot-restclient` dependencies.

Package changed to `org.springframework.boot.resttestclient.TestRestTemplate`.

Consider migrating to `RestTestClient` instead:

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureRestTestClient
class MyTest {
    @Autowired RestTestClient restTestClient;
}
```

## @MockBean / @SpyBean → @MockitoBean / @MockitoSpyBean

Spring Boot's `@MockBean` and `@SpyBean` are deprecated. Use the new annotations:

```java
// Boot 3
@MockBean
private UserRepository userRepository;

@SpyBean
private NotificationService notificationService;

// Boot 4
@MockitoBean
private UserRepository userRepository;

@MockitoSpyBean
private NotificationService notificationService;
```

The new annotations also work with non-singleton beans (prototype, custom scopes).

## @Mock / @Captor Fields

`MockitoTestExecutionListener` has been removed. If `@Mock` or `@Captor` fields stop working:

```java
// Add MockitoExtension from Mockito itself
@ExtendWith(MockitoExtension.class)
class MyUnitTest {
    @Mock
    private UserRepository userRepository;

    @Captor
    private ArgumentCaptor<User> userCaptor;
}
```

## JUnit 4 Support Deprecated

All JUnit 4 support classes are deprecated:
- `SpringRunner`
- `SpringClassRule`
- `SpringMethodRule`
- `AbstractJUnit4SpringContextTests`
- `AbstractTransactionalJUnit4SpringContextTests`

Migration:

```java
// Boot 3 (JUnit 4)
@RunWith(SpringRunner.class)
@SpringBootTest
public class MyTest { }

// Boot 4 (JUnit Jupiter)
@SpringBootTest  // SpringExtension is auto-registered
class MyTest { }
```

## @Nested Test Class Improvements

`SpringExtension` now uses test-method scoped `ExtensionContext`, enabling consistent DI in `@Nested` hierarchies.

If `@Nested` tests break after upgrade:

```java
@SpringExtensionConfig(useTestClassScopedExtensionContext = true)
class TopLevelTest {
    @Nested
    class InnerTest { ... }
}
```

## Test Context Pausing

Unused test contexts are automatically paused (background processes stopped) to save resources. Control via:

```properties
# Options: auto (default), always, never
spring.test.context.cache.pause=auto
```

## @PropertyMapping

Package changed:
- `org.springframework.boot.test.autoconfigure.properties.PropertyMapping` → `org.springframework.boot.test.context.PropertyMapping`
- `Skip` enum also moved to `org.springframework.boot.test.context.PropertyMapping.Skip`

## Spring Batch Testing

Spring Batch now defaults to in-memory (no database). For tests that rely on database-backed job metadata:

```xml
<!-- Switch to JDBC variant -->
<artifactId>spring-boot-starter-batch-jdbc-test</artifactId>
```

## Security Testing

`@WithMockUser`, `@WithUserDetails`, and other Spring Security test annotations require:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security-test</artifactId>
    <scope>test</scope>
</dependency>
```

This is a new requirement — Boot 3 included security test support transitively.

## Liveness and Readiness Probes

Now enabled by default in Boot 4. The health endpoint exposes `liveness` and `readiness` groups automatically. Disable with:

```properties
management.endpoint.health.probes.enabled=false
```
