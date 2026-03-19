# Spring Boot 4 Modularization

Boot 4's most impactful change: the monolithic `spring-boot-autoconfigure` is split into technology-specific modules.

## Naming Convention

- Module: `spring-boot-<technology>`
- Root package: `org.springframework.boot.<technology>`
- Starter: `spring-boot-starter-<technology>`
- Test module: `spring-boot-<technology>-test`
- Test starter: `spring-boot-starter-<technology>-test`

## Starter Mapping

### Web

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| Spring Web MVC | `spring-boot-starter-webmvc` | `spring-boot-starter-webmvc-test` |
| Spring WebFlux | `spring-boot-starter-webflux` | `spring-boot-starter-webflux-test` |
| Jersey | `spring-boot-starter-jersey` | `spring-boot-starter-jersey-test` |
| Spring GraphQL | `spring-boot-starter-graphql` | `spring-boot-starter-graphql-test` |
| Spring HATEOAS | `spring-boot-starter-hateoas` | `spring-boot-starter-hateoas-test` |
| Websockets | `spring-boot-starter-websocket` | `spring-boot-starter-websocket-test` |

### Web Client

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| RestClient / RestTemplate | `spring-boot-starter-restclient` | `spring-boot-starter-restclient-test` |
| WebClient (reactive) | `spring-boot-starter-webclient` | `spring-boot-starter-webclient-test` |

### Database

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| JDBC | `spring-boot-starter-jdbc` | `spring-boot-starter-jdbc-test` |
| JPA (Hibernate) | `spring-boot-starter-data-jpa` | `spring-boot-starter-data-jpa-test` |
| R2DBC | `spring-boot-starter-r2dbc` | `spring-boot-starter-r2dbc-test` |
| MongoDB | `spring-boot-starter-mongodb` | `spring-boot-starter-mongodb-test` |
| Elasticsearch | `spring-boot-starter-elasticsearch` | `spring-boot-starter-elasticsearch-test` |
| Flyway | `spring-boot-starter-flyway` | `spring-boot-starter-flyway-test` |
| Liquibase | `spring-boot-starter-liquibase` | `spring-boot-starter-liquibase-test` |
| jOOQ | `spring-boot-starter-jooq` | `spring-boot-starter-jooq-test` |

### Messaging

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| Spring Kafka | `spring-boot-starter-kafka` | `spring-boot-starter-kafka-test` |
| Spring AMQP | `spring-boot-starter-amqp` | `spring-boot-starter-amqp-test` |
| JMS | `spring-boot-starter-jms` | `spring-boot-starter-jms-test` |
| ActiveMQ | `spring-boot-starter-activemq` | `spring-boot-starter-activemq-test` |
| Artemis | `spring-boot-starter-artemis` | `spring-boot-starter-artemis-test` |
| Pulsar | `spring-boot-starter-pulsar` | `spring-boot-starter-pulsar-test` |

### Security

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| Spring Security | `spring-boot-starter-security` | `spring-boot-starter-security-test` |
| OAuth2 Auth Server | `spring-boot-starter-security-oauth2-authorization-server` | `spring-boot-starter-security-oauth2-authorization-server-test` |
| OAuth2 Client | `spring-boot-starter-security-oauth2-client` | `spring-boot-starter-security-oauth2-client-test` |
| OAuth2 Resource Server | `spring-boot-starter-security-oauth2-resource-server` | `spring-boot-starter-security-oauth2-resource-server-test` |
| SAML2 | `spring-boot-starter-security-saml2` | `spring-boot-starter-security-saml2-test` |

### JSON

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| Jackson | `spring-boot-starter-jackson` | `spring-boot-starter-jackson-test` |
| GSON | `spring-boot-starter-gson` | `spring-boot-starter-gson-test` |
| JSONB | `spring-boot-starter-jsonb` | `spring-boot-starter-jsonb-test` |

### Production-Ready

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| Actuator | `spring-boot-starter-actuator` | `spring-boot-starter-actuator-test` |
| Micrometer | `spring-boot-starter-micrometer-metrics` | `spring-boot-starter-micrometer-metrics-test` |
| OpenTelemetry | `spring-boot-starter-opentelemetry` | `spring-boot-starter-opentelemetry-test` |

### Other

| Technology | Main Starter | Test Starter |
|-----------|-------------|-------------|
| Spring Batch | `spring-boot-starter-batch` | `spring-boot-starter-batch-test` |
| Spring Batch (JDBC) | `spring-boot-starter-batch-jdbc` | `spring-boot-starter-batch-jdbc-test` |
| Cache | `spring-boot-starter-cache` | `spring-boot-starter-cache-test` |
| Validation | `spring-boot-starter-validation` | `spring-boot-starter-validation-test` |
| Mail | `spring-boot-starter-mail` | `spring-boot-starter-mail-test` |
| Quartz | `spring-boot-starter-quartz` | `spring-boot-starter-quartz-test` |
| Thymeleaf | `spring-boot-starter-thymeleaf` | `spring-boot-starter-thymeleaf-test` |
| AspectJ | `spring-boot-starter-aspectj` | `spring-boot-starter-aspectj-test` |

## Deprecated Starters (still work, will be removed)

| Deprecated | Replacement |
|-----------|------------|
| `spring-boot-starter-web` | `spring-boot-starter-webmvc` |
| `spring-boot-starter-aop` | `spring-boot-starter-aspectj` |
| `spring-boot-starter-oauth2-authorization-server` | `spring-boot-starter-security-oauth2-authorization-server` |
| `spring-boot-starter-oauth2-client` | `spring-boot-starter-security-oauth2-client` |
| `spring-boot-starter-oauth2-resource-server` | `spring-boot-starter-security-oauth2-resource-server` |
| `spring-boot-starter-web-services` | `spring-boot-starter-webservices` |

## Classic Starters (migration aid)

For quick migration, use classic starters that bundle all modules like Boot 3 did:

| Previous | Classic Equivalent |
|----------|-------------------|
| `spring-boot-starter` | `spring-boot-starter-classic` |
| `spring-boot-starter-test` | `spring-boot-starter-test-classic` |

Recommended workflow:
1. Switch to classic starters to get running
2. Fix broken imports and validate
3. Replace classic with individual technology starters

## Important Notes

- Test starters transitively include `spring-boot-starter-test`, so you don't need to declare it separately
- `@WithMockUser` and `@WithUserDetails` now require `spring-boot-starter-security-test`
- Spring Batch defaults to in-memory mode; use `spring-boot-starter-batch-jdbc` for database persistence
- Supporting both Boot 3 and Boot 4 in the same artifact is strongly discouraged
