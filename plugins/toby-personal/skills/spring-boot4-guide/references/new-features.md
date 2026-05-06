# New Features in Spring Framework 7 / Spring Boot 4

## API Versioning

First-class support for API versioning in Spring MVC and WebFlux.

### Server-side

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    @ApiVersion("1")
    public List<UserV1> getUsersV1() { ... }

    @GetMapping
    @ApiVersion("2")
    public List<UserV2> getUsersV2() { ... }
}
```

- Configure version resolution strategy (header, path, query param)
- Mark versions as deprecated to notify clients
- Works with functional endpoints too

### Client-side

```java
RestClient client = RestClient.builder()
    .baseUrl("https://api.example.com")
    .defaultApiVersion("2")
    .build();
```

Also supported in `WebClient` and HTTP interface clients.

### Testing

```java
restTestClient.get().uri("/api/users")
    .apiVersion("2")
    .exchange()
    .expectStatus().isOk();
```

Reference: [Spring MVC Versioning docs](https://docs.spring.io/spring-framework/reference/web/webmvc-versioning.html)

## Resilience: RetryTemplate, @Retryable, @ConcurrencyLimit

Spring Retry has been merged into Spring Framework core (`org.springframework.core.retry`).

### Setup

```java
@Configuration
@EnableResilientMethods
public class AppConfig { }
```

### @Retryable

```java
@Service
public class ExternalService {

    @Retryable(maxAttempts = 3)
    public String callExternalApi() {
        // Automatically retried on failure
        return restClient.get().uri("/data").retrieve().body(String.class);
    }
}
```

- Adapts automatically to reactive methods (uses Reactor retry)
- Customizable retry policy via annotation attributes

### @ConcurrencyLimit

```java
@ConcurrencyLimit(limit = 10)
public String heavyOperation() {
    // At most 10 concurrent executions
    return process();
}
```

Reference: [Resilience chapter](https://docs.spring.io/spring/reference/core/resilience.html)

## RestTestClient

Non-reactive alternative to `WebTestClient` — the most requested community feature.

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureRestTestClient
class UserApiTest {

    @Autowired
    RestTestClient restTestClient;

    @Test
    void shouldReturnUsers() {
        restTestClient.get().uri("/api/users")
            .exchange()
            .expectStatus().isOk()
            .expectBody()
            .jsonPath("$[0].name").isEqualTo("Alice");
    }
}
```

Binding options:
- Live server (random port)
- MVC `@Controller` (mock)
- ApplicationContext

Reference: [RestTestClient docs](https://docs.spring.io/spring-framework/reference/testing/resttestclient.html)

## Programmatic Bean Registration

New `BeanRegistrar` contract for cases where `@Bean` methods are too limiting:

```java
public class InfraRegistrar implements BeanRegistrar {

    @Override
    public void register(BeanRegistry registry, Environment env) {
        if (env.getProperty("feature.cache", Boolean.class, false)) {
            registry.registerBean("cacheManager", CacheManager.class);
        }
        // Register multiple beans conditionally
        registry.registerBean("auditService", AuditService.class);
    }
}
```

Reference: [Programmatic Bean Registration](https://docs.spring.io/spring-framework/reference/7.0.0/core/beans/java/programmatic-bean-registration.html)

## @ImportHttpServices

Simplifies HTTP interface client configuration for multiple services:

```java
@Configuration(proxyBeanMethods = false)
@ImportHttpServices(group = "weather", types = {FreeWeather.class, CommercialWeather.class})
@ImportHttpServices(group = "user", types = {UserServiceInternal.class})
static class HttpConfig extends AbstractHttpServiceRegistrar {

    @Bean
    public RestClientHttpServiceGroupConfigurer configurer() {
        return groups -> groups.filterByName("weather", "user")
            .forEachClient((group, builder) ->
                builder.defaultHeader("User-Agent", "My-App"));
    }
}
```

The framework creates proxy beans for each HTTP interface automatically.

Reference: [HTTP Service Client docs](https://docs.spring.io/spring-framework/reference/integration/rest-clients.html#rest-http-service-client-group-config)

## HTTP Interface Client: InputStream/OutputStream Support

```java
public interface FileService {

    @GetExchange("/files/{id}")
    InputStream download(@PathVariable String id);

    @PostExchange("/files")
    void upload(StreamingHttpOutputMessage.Body body);
}
```

## JmsClient

Fluent JMS client following the `JdbcClient`/`RestClient` pattern:

```java
@Autowired
JmsClient jmsClient;

// Send
jmsClient.send("orders").body(orderMessage);

// Receive
Message response = jmsClient.receive("responses").get();
```

Features reusable operation handles with custom QoS settings. `JdbcClient` also gains statement-level settings (fetch size, max rows, query timeout).

## JPA 3.2 Improvements

### Direct EntityManager injection

```java
@Service
public class UserService {
    @Autowired  // Works in JPA 3.2 — no need for @PersistenceContext
    private EntityManager entityManager;
}
```

`EntityManagerFactory` and `EntityManager` are injectable via `@Inject`/`@Autowired` with qualifier support.

### Hibernate StatelessSession

```java
@Autowired
private StatelessSession statelessSession;  // From LocalSessionFactoryBean
```

Recommended with Hibernate 7.2 for best support.

### XML-free JPA Setup

```java
@Bean
public LocalEntityManagerFactoryBean entityManagerFactory() {
    var config = new HibernatePersistenceConfiguration("my-pu");
    config.managedClass(User.class, Order.class);
    var factory = new LocalEntityManagerFactoryBean();
    factory.setPersistenceConfiguration(config);
    return factory;
}
```

## SpEL Optional Support

```java
// Null-safe navigation on Optional
@Value("#{user.address?.city}")  // Works if address is Optional<Address>

// Elvis operator unwraps Optional
@Value("#{user.nickname ?: 'Anonymous'}")  // Unwraps Optional<String>
```

## Null Safety with JSpecify

The entire Spring Framework codebase uses JSpecify annotations. Benefits:
- Generic type nullability: `List<@Nullable String>`
- Array element nullability
- Better Kotlin integration
- Better IDE/tool support

```java
import org.jspecify.annotations.Nullable;
import org.jspecify.annotations.NonNull;

public class MyService {
    public @Nullable User findUser(String id) { ... }
    public @NonNull User getUser(String id) { ... }
}
```

## PathPattern: Leading Multi-Segment Wildcards

Previously unsupported pattern now works:

```java
@GetMapping("/**/pages/index.html")  // Now valid in PathPattern
```

## Proxy Configuration

CGLIB proxy defaulting is now consistent across all proxy processors (including `@Async`).

```java
@Proxyable(INTERFACES)  // Opt out of CGLIB for this bean
@Component
public class MyService implements MyInterface { ... }
```

## Test Context Pausing

Unused test ApplicationContexts are automatically paused (background processes stopped) and restarted when needed. Configurable via `spring.test.context.cache.pause` property.

## Bean Overrides for Non-Singleton Beans

`@MockitoBean`, `@MockitoSpyBean`, and `@TestBean` now work with `prototype` and custom-scoped beans.

## GraalVM Native: Simplified Hints

```java
// Before (Boot 3)
hints.reflection().registerType(MyType.class, MemberCategory.DECLARED_FIELDS);

// After (Boot 4) — just register the type
hints.reflection().registerType(MyType.class);
```

Resource hints now use glob patterns instead of regex.
