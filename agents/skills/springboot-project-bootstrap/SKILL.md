---
name: springboot-project-bootstrap
description: How to bootstrap a production-ready Spring Boot service with Spring Initializr (spring init CLI or start.spring.io REST API), choose starters, LTS Java, build tool, profiles, and a Testcontainers-ready test skeleton. Use when starting a new Spring Boot service or standardizing project structure.
---

# Spring Boot Project Bootstrap (Spring Initializr)

## Generate the project

**CLI (spring init):**
```bash
spring init \
  --build=gradle \
  --java-version=21 \
  --packaging=jar \
  --dependencies=web,actuator,validation,data-jpa,postgresql,flyway,security,testcontainers \
  --group-id=com.example \
  --artifact-id=orders-service \
  --name=orders-service \
  orders-service
```

**REST API (start.spring.io):**
```bash
curl https://start.spring.io/starter.zip \
  -d type=gradle-project -d language=java -d javaVersion=21 -d bootVersion=3.3.x \
  -d dependencies=web,actuator,validation,data-jpa,postgresql,flyway,security,testcontainers \
  -d groupId=com.example -d artifactId=orders-service -d name=orders-service \
  -o orders-service.zip && unzip orders-service.zip
```

## Choosing starters (only what you need)
- Web: `web` (MVC) or `webflux` (reactive) — not both.
- Persistence: `data-jpa` + driver (`postgresql`) or `data-r2dbc` for reactive; `flyway`/`liquibase` for migrations.
- Ops: `actuator` (always), `prometheus` (micrometer-registry-prometheus).
- Security: `security`, `oauth2-resource-server` for JWT.
- Resilience: add `io.github.resilience4j:resilience4j-spring-boot3`.
- Testing: `testcontainers` + `spring-boot-testcontainers`.

## Baseline structure (package-by-feature)
```
com.example.orders
├── OrdersServiceApplication.java
├── order/            # controller, service, repository, domain, dto per feature
├── config/           # security, resilience, observability config
└── common/           # error model, shared components
```

## Profiles (application.yml)
```yaml
spring:
  application.name: orders-service
  profiles.active: ${SPRING_PROFILES_ACTIVE:dev}
management:
  endpoints.web.exposure.include: health,info,prometheus
  endpoint.health.probes.enabled: true   # liveness + readiness groups
---
spring.config.activate.on-profile: dev
---
spring.config.activate.on-profile: prod
# externalized config/secrets injected at runtime
```

## Verify immediately
```bash
./gradlew build     # or: mvn verify
```
A generated project should build and run its (empty) test suite before you add code.

## Multi-service standardization
- Share a **parent/BOM** and a common starter module (error model, logging, tracing,
  security defaults) so all services stay consistent.
- Pin the Spring Boot version via the BOM; avoid per-service drift.
