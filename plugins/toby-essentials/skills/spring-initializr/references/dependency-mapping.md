# Spring Initializr Dependency Mapping

Map user-friendly terms to Spring Initializr dependency IDs.

## Web & API

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Web, REST API, MVC | `web` | Spring MVC + embedded Tomcat |
| WebFlux, Reactive Web | `webflux` | Reactive web with Netty |
| GraphQL | `graphql` | Spring for GraphQL |
| WebSocket | `websocket` | WebSocket support |
| HATEOAS | `hateoas` | Hypermedia-driven REST |
| REST Docs | `restdocs` | API documentation via tests |

## Data & Persistence

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| JPA, Hibernate | `data-jpa` | Spring Data JPA |
| JDBC | `data-jdbc` | Spring Data JDBC (lighter than JPA) |
| H2 | `h2` | Embedded in-memory DB |
| MySQL | `mysql` | MySQL driver |
| PostgreSQL, Postgres | `postgresql` | PostgreSQL driver |
| MariaDB | `mariadb` | MariaDB driver |
| MongoDB, Mongo | `data-mongodb` | Spring Data MongoDB |
| Redis | `data-redis` | Spring Data Redis |
| Elasticsearch | `data-elasticsearch` | Spring Data Elasticsearch |
| R2DBC | `data-r2dbc` | Reactive relational DB access |
| Flyway | `flyway` | DB migration (SQL-based) |
| Liquibase | `liquibase` | DB migration (XML/YAML-based) |

## Messaging

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Kafka | `kafka` | Spring for Apache Kafka |
| RabbitMQ, AMQP | `amqp` | Spring AMQP + RabbitMQ |
| Pulsar | `pulsar` | Spring for Apache Pulsar |

## Security

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Security | `security` | Spring Security |
| OAuth2 Client | `oauth2-client` | OAuth2/OpenID Connect client |
| OAuth2 Resource Server | `oauth2-resource-server` | JWT/opaque token validation |

## Observability & Operations

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Actuator | `actuator` | Production monitoring endpoints |
| Prometheus | `prometheus` | Prometheus metrics exporter |
| Zipkin, Tracing | `distributed-tracing` | Distributed tracing |

## Developer Tools

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Lombok | `lombok` | Boilerplate reduction annotations |
| DevTools | `devtools` | Live reload, auto-restart |
| Docker Compose | `docker-compose` | Docker Compose integration |
| Testcontainers | `testcontainers` | Integration testing with containers |
| Configuration Processor | `configuration-processor` | IDE metadata for @ConfigurationProperties |

## Template Engines

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Thymeleaf | `thymeleaf` | Server-side HTML templates |
| Mustache | `mustache` | Logic-less templates |
| Freemarker | `freemarker` | Apache FreeMarker templates |

## Scheduling & Batch

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Batch | `batch` | Spring Batch (chunk processing) |
| Quartz | `quartz` | Quartz scheduler |

## Cloud & Infrastructure

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Cloud Config Client | `cloud-config-client` | Externalized config |
| Cloud Config Server | `cloud-config-server` | Config server |
| Eureka Client | `cloud-eureka` | Service discovery client |
| Eureka Server | `cloud-eureka-server` | Service discovery server |
| Gateway | `cloud-gateway` | API Gateway (reactive) |

## AI

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Spring AI, OpenAI | `spring-ai-openai` | Spring AI with OpenAI |
| Spring AI Anthropic, Claude | `spring-ai-anthropic` | Spring AI with Anthropic Claude |
| Spring AI Ollama | `spring-ai-ollama` | Spring AI with Ollama (local) |
| Spring AI Azure OpenAI | `spring-ai-azure-openai` | Spring AI with Azure OpenAI |

## Miscellaneous

| User says | Dependency ID | Notes |
|-----------|---------------|-------|
| Mail, Email | `mail` | JavaMail / Jakarta Mail |
| Cache, Caching | `cache` | Spring Cache abstraction |
| Validation | `validation` | Bean Validation (Hibernate Validator) |
| AOP | `aop` | Spring AOP + AspectJ |
| Retry | `retry` | Spring Retry |

## Lookup Unknown Dependencies

If a dependency is not in this table, query the Spring Initializr capabilities endpoint:

```bash
curl -s https://start.spring.io/dependencies | jq '.dependencies[].values[].id' | grep -i "{keyword}"
```
