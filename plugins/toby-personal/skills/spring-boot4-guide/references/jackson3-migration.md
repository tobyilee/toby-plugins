# Jackson 3 Migration Guide

Spring Boot 4 defaults to Jackson 3.x. Jackson 2.x is deprecated and will be removed in a future release.

## Package Changes

| Jackson 2 | Jackson 3 |
|-----------|-----------|
| `com.fasterxml.jackson.databind.*` | `tools.jackson.databind.*` |
| `com.fasterxml.jackson.core.*` | `tools.jackson.core.*` |
| `com.fasterxml.jackson.datatype.*` | `tools.jackson.datatype.*` |
| `com.fasterxml.jackson.annotation.*` | **Unchanged** (stays `com.fasterxml.jackson.annotation`) |

The annotations package is intentionally kept the same to ease migration.

## Spring Boot Class Renames

| Boot 3 / Jackson 2 | Boot 4 / Jackson 3 |
|--------------------|-------------------|
| `@JsonComponent` | `@JacksonComponent` |
| `@JsonMixin` | `@JacksonMixin` |
| `JsonObjectSerializer` | `ObjectValueSerializer` |
| `JsonValueDeserializer` | `ObjectValueDeserializer` |
| `Jackson2ObjectMapperBuilderCustomizer` | `JsonMapperBuilderCustomizer` |

## ObjectMapper → JsonMapper

`Jackson2ObjectMapperBuilder` is removed. Use Jackson's native builder:

```java
// Jackson 2 (Boot 3)
@Bean
public Jackson2ObjectMapperBuilderCustomizer customizer() {
    return builder -> builder.featuresToEnable(SerializationFeature.INDENT_OUTPUT);
}

// Jackson 3 (Boot 4)
@Bean
public JsonMapperBuilderCustomizer customizer() {
    return builder -> builder.enable(SerializationFeature.INDENT_OUTPUT);
}
```

Or build directly:

```java
JsonMapper mapper = JsonMapper.builder()
    .findAndAddModules()
    .enable(SerializationFeature.INDENT_OUTPUT)
    .build();
```

## Property Changes

| Boot 3 | Boot 4 |
|--------|--------|
| `spring.jackson.read.*` | `spring.jackson.json.read.*` |
| `spring.jackson.write.*` | `spring.jackson.json.write.*` |
| `spring.jackson.parser.*` | `spring.jackson.json.read.*` (where equivalent exists) |

Boot 4 auto-detects and registers all Jackson modules on the classpath (Boot 3 only registered "well-known" modules). Disable with `spring.jackson.find-and-add-modules=false`.

## WebMvc Message Converter Configuration

```java
// Boot 4 way
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void configureMessageConverters(HttpMessageConverters.ServerBuilder builder) {
        JsonMapper jsonMapper = JsonMapper.builder()
                .findAndAddModules()
                .enable(SerializationFeature.INDENT_OUTPUT)
                .build();
        builder.jsonMessageConverter(new JacksonJsonHttpMessageConverter(jsonMapper));
    }
}
```

## Jackson 2 Compatibility Mode

If you can't migrate to Jackson 3 immediately:

```xml
<!-- Add Jackson 2 module (deprecated, temporary) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-jackson2</artifactId>
</dependency>
```

```properties
# Use Jackson 2 defaults
spring.jackson.use-jackson2-defaults=true
```

Jackson 2 properties are available under `spring.jackson2.*` (equivalent to Boot 3's `spring.jackson.*`).

Both Jackson 2 and Jackson 3 ObjectMappers can coexist if needed.

## Jersey Note

Jersey 4.0 does not yet support Jackson 3. If using Jersey, you must use `spring-boot-jackson2`.
