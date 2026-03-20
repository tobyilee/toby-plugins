---
name: spring-boot-init
description: "Spring Boot 프로젝트를 Spring Initializr를 이용해 생성하는 스킬. 사용자가 Spring Boot 프로젝트 생성, 스프링 부트 새 프로젝트, Spring Initializr, 새 스프링 앱 만들기, create spring boot app, 스프링 부트 시작 등을 요청할 때 반드시 이 스킬을 사용한다. 간단한 Spring Boot 시작 요청이라도 이 스킬을 사용해야 한다."
---

# Spring Boot Project Generator

Spring Initializr API(https://start.spring.io)를 활용하여 Spring Boot 프로젝트를 인터랙티브하게 생성한다.
빌드 도구는 Gradle Kotlin DSL로 고정하고, 사용자가 버전과 의존성을 선택할 수 있도록 안내한다.

## 전체 흐름

1. Spring Initializr 메타데이터 조회
2. Boot Version / Java Version / Language 선택 (AskUserQuestion 1회)
3. Artifact, Package 확인 (AskUserQuestion 1회)
4. Dependency 선택 (AskUserQuestion 1~2회)
5. 프로젝트 다운로드 및 압축 해제
6. Gradle build 실행

---

## Step 1: 메타데이터 조회

WebFetch로 Spring Initializr API 메타데이터를 가져온다.

```
URL: https://start.spring.io/metadata/client
Prompt: "Extract all bootVersion values (id, default), javaVersion values (id, default), language values, and all dependency groups with each dependency's id, name, description. Return as structured data."
```

응답에서 추출할 정보:
- **bootVersion**: 안정 버전만 (SNAPSHOT, M*, RC* 제외). default 표시된 버전 기억.
- **javaVersion**: 사용 가능한 Java 버전들. default 표시된 버전 기억.
- **language**: java, kotlin, groovy
- **dependencies**: 그룹명과 각 그룹 내 의존성의 id, name

## Step 2: Boot Version / Java Version / Language 선택

AskUserQuestion **1회 호출**로 3개 질문을 동시에 묻는다.

```
questions:
  - question: "Spring Boot 버전을 선택하세요"
    header: "Boot Ver"
    multiSelect: false
    options:
      - label: "[default 버전] (Recommended)"    # 메타데이터의 default
        description: "현재 안정 버전"
      - label: "[다음 안정 버전]"
        description: "..."
      # 안정 버전 최대 4개까지

  - question: "Java 버전을 선택하세요"
    header: "Java Ver"
    multiSelect: false
    options:
      - label: "[default 버전] (Recommended)"
        description: "현재 LTS 버전"
      - label: "[다른 버전들]"
        description: "..."

  - question: "언어를 선택하세요"
    header: "Language"
    multiSelect: false
    options:
      - label: "Java (Recommended)"
        description: "가장 널리 사용되는 Spring 언어"
      - label: "Kotlin"
        description: "간결한 문법, Spring과 완벽 호환"
      - label: "Groovy"
        description: "동적 타입 JVM 언어"
```

## Step 3: Artifact / Package 확인

현재 작업 디렉토리의 **폴더명**을 기본 Artifact로 사용한다.

- **Artifact**: 현재 디렉토리명 (예: `myapp`)
- **Group**: `toby.ai`
- **Package**: `toby.ai.[artifact]` (점(.) 이나 하이픈(-) 은 제거. 예: `my-app` → `toby.ai.myapp`)

AskUserQuestion으로 확인:

```
questions:
  - question: "프로젝트 설정을 확인해주세요.\n- Artifact: [artifact]\n- Group: toby.ai\n- Package: [package]\n이대로 진행할까요?"
    header: "Project"
    multiSelect: false
    options:
      - label: "확인 (Recommended)"
        description: "위 설정대로 진행"
      - label: "수정"
        description: "Artifact와 Package를 직접 입력 (Other에 'artifact=xxx, package=yyy' 형태로 입력)"
```

사용자가 "수정" 또는 "Other"를 선택하면 입력값에서 artifact와 package를 파싱한다.

## Step 4: Dependency 선택

### 기본 의존성 (자동 포함)

사용자에게 먼저 안내한다: "다음 의존성이 기본으로 포함됩니다:"

| 의존성 | ID | 조건 |
|--------|-----|------|
| Spring Web | `web` | 항상 |
| Spring Data JPA | `data-jpa` | 항상 |
| H2 Database | `h2` | 항상 |
| Lombok | `lombok` | Language가 **Java**인 경우에만 |

### 추가 의존성 선택

메타데이터에서 가져온 의존성 그룹을 기반으로 AskUserQuestion을 구성한다.
**각 그룹이 하나의 탭(질문)**이 되고, **multiSelect: true**로 설정하여 여러 의존성을 고를 수 있게 한다.

AskUserQuestion 1회에 최대 4개 탭이므로, 가장 많이 쓰이는 그룹 4개를 먼저 묻는다.

**첫 번째 AskUserQuestion** — 주요 그룹:

```
questions:
  - question: "Developer Tools에서 추가할 의존성을 선택하세요"
    header: "DevTools"
    multiSelect: true
    options:  # 메타데이터의 Developer Tools 그룹에서 인기 4개
      - label: "DevTools"
        description: "spring-boot-devtools: 자동 재시작, 라이브 리로드"
      - label: "Docker Compose"
        description: "docker-compose: Docker Compose 개발 지원"
      - label: "Config Processor"
        description: "configuration-processor: 설정 메타데이터 생성"
      - label: "Modulith"
        description: "modulith: 모듈러 아키텍처 지원"

  - question: "Security에서 추가할 의존성을 선택하세요"
    header: "Security"
    multiSelect: true
    options:  # 메타데이터의 Security 그룹에서 인기 4개
      - label: "Spring Security"
        description: "security: 인증/인가 프레임워크"
      - label: "OAuth2 Client"
        description: "oauth2-client: OAuth2 로그인"
      - label: "OAuth2 Resource Server"
        description: "oauth2-resource-server: JWT/Opaque 토큰"
      - label: "SAML 2.0"
        description: "saml2-service-provider: SAML SSO"

  - question: "추가 데이터베이스 드라이버를 선택하세요 (JPA/H2는 기본 포함)"
    header: "SQL"
    multiSelect: true
    options:  # 메타데이터의 SQL 그룹에서 인기 DB 드라이버 4개
      - label: "MySQL"
        description: "mysql: MySQL 드라이버"
      - label: "PostgreSQL"
        description: "postgresql: PostgreSQL 드라이버"
      - label: "MariaDB"
        description: "mariadb: MariaDB 드라이버"
      - label: "Flyway"
        description: "flyway: DB 마이그레이션"

  - question: "템플릿 엔진을 선택하세요"
    header: "Template"
    multiSelect: true
    options:
      - label: "Thymeleaf"
        description: "thymeleaf: 서버사이드 HTML 템플릿"
      - label: "Mustache"
        description: "mustache: 로직 없는 템플릿"
      - label: "Freemarker"
        description: "freemarker: 강력한 템플릿 엔진"
      - label: "jte"
        description: "jte: 타입 세이프 템플릿"
```

첫 번째 선택 완료 후, 추가 의존성이 필요한지 묻는다:

```
questions:
  - question: "추가 의존성 그룹을 더 선택하시겠습니까? (NoSQL, Messaging, Ops, Testing)"
    header: "More Deps"
    multiSelect: false
    options:
      - label: "건너뛰기 (Recommended)"
        description: "추가 의존성 없이 프로젝트 생성"
      - label: "더 선택하기"
        description: "NoSQL, Messaging, Ops, Testing 그룹에서 추가 선택"
```

"더 선택하기"를 고른 경우 **두 번째 AskUserQuestion**:

```
questions:
  - question: "NoSQL에서 추가할 의존성을 선택하세요"
    header: "NoSQL"
    multiSelect: true
    options:  # 메타데이터의 NoSQL 그룹에서 4개
      - label: "Redis"
        description: "data-redis: Redis 키-값 스토어"
      - label: "MongoDB"
        description: "data-mongodb: MongoDB 문서 DB"
      - label: "Elasticsearch"
        description: "data-elasticsearch: 검색 엔진"
      - label: "Cassandra"
        description: "data-cassandra: 분산 NoSQL"

  - question: "Messaging에서 추가할 의존성을 선택하세요"
    header: "Messaging"
    multiSelect: true
    options:
      - label: "Kafka"
        description: "kafka: Apache Kafka 메시징"
      - label: "RabbitMQ"
        description: "amqp: RabbitMQ AMQP 메시징"
      - label: "WebSocket"
        description: "websocket: WebSocket 지원"
      - label: "Pulsar"
        description: "pulsar: Apache Pulsar 메시징"

  - question: "운영/관측에서 추가할 의존성을 선택하세요"
    header: "Ops"
    multiSelect: true
    options:
      - label: "Actuator"
        description: "actuator: 상태 확인, 메트릭"
      - label: "Prometheus"
        description: "prometheus: Prometheus 메트릭 노출"
      - label: "Micrometer Tracing"
        description: "distributed-tracing: 분산 추적"
      - label: "Spring Boot Admin"
        description: "spring-boot-admin-client: 관리 UI"

  - question: "Testing에서 추가할 의존성을 선택하세요"
    header: "Testing"
    multiSelect: true
    options:
      - label: "Testcontainers"
        description: "testcontainers: Docker 기반 통합 테스트"
      - label: "REST Docs"
        description: "restdocs: API 문서 자동 생성"
      - label: "Contract Verifier"
        description: "cloud-contract-verifier: 컨슈머 주도 계약 테스트"
      - label: "Embedded LDAP"
        description: "unboundid-ldapsdk: 테스트용 LDAP"
```

위 옵션의 label과 description은 고정된 예시가 아닌 **가이드라인**이다. 실제로는 Step 1에서 가져온 메타데이터의 의존성 목록을 기반으로 옵션을 구성해야 한다. description 뒤의 ID(예: `data-redis`)가 curl 요청의 dependencies 파라미터에 들어가는 값이다.

### 의존성 목록 조합

최종 의존성 = 기본 의존성 + 사용자 선택 의존성

```
기본: web,data-jpa,h2 (+ Java면 lombok)
추가: 사용자가 선택한 것들의 ID를 콤마로 연결
```

## Step 5: 프로젝트 다운로드

Bash로 Spring Initializr API에서 프로젝트를 다운로드하고 압축을 해제한다.

```bash
curl -s -G https://start.spring.io/starter.zip \
  -d type=gradle-project-kotlin \
  -d language=[language] \
  -d bootVersion=[bootVersion] \
  -d baseDir=[artifact] \
  -d groupId=toby.ai \
  -d artifactId=[artifact] \
  -d name=[artifact] \
  -d packageName=[package] \
  -d packaging=jar \
  -d javaVersion=[javaVersion] \
  -d dependencies=[콤마로 구분된 전체 의존성 목록] \
  -o starter.zip && unzip -o starter.zip && rm starter.zip
```

파라미터 설명:
- `type=gradle-project-kotlin`: Gradle Kotlin DSL (고정)
- `language`: java, kotlin, groovy 중 하나
- `bootVersion`: 선택된 Spring Boot 버전 (예: `4.0.4`)
- `baseDir`: 생성될 프로젝트 디렉토리명 = artifact
- `dependencies`: 콤마 구분 (예: `web,data-jpa,h2,lombok,security`)

## Step 6: Gradle Build 실행

```bash
cd [artifact] && chmod +x gradlew && ./gradlew build
```

- 빌드 성공: "BUILD SUCCESSFUL" 확인 후 프로젝트 생성 완료 메시지 표시
- 빌드 실패: 에러 로그를 확인하고 원인을 파악하여 해결 시도

## 주의사항

- 빌드 도구는 **Gradle Kotlin DSL** 고정 — 사용자에게 묻지 않는다.
- Packaging은 **jar** 고정.
- SNAPSHOT, Milestone(M*), Release Candidate(RC*) 버전은 옵션에서 제외한다.
- 메타데이터 조회 실패 시 폴백: Boot 4.0.4, Java 17, dependencies는 하드코딩된 목록 사용.
- 의존성 ID는 반드시 Spring Initializr API의 실제 ID를 사용한다 (예: `web`, `data-jpa`, `h2`, `lombok`, `security`, `data-redis`).
- Package명에서 하이픈은 제거한다 (예: `my-app` → `toby.ai.myapp`).
- 사용자가 프롬프트에서 특정 의존성을 언급한 경우 (예: "Redis랑 Security 필요해"), 해당 의존성을 기본 선택에 추가하거나 미리 선택된 상태로 안내한다.
