---
name: springboot-observability
description: Production observability for Spring Boot — Actuator health with liveness/readiness probes, Micrometer metrics to Prometheus, distributed tracing via Micrometer Tracing/OpenTelemetry, and structured JSON logging with correlation IDs. Use when making a service observable or wiring Kubernetes probes.
---

# Spring Boot Observability

## Dependencies
```gradle
implementation 'org.springframework.boot:spring-boot-starter-actuator'
implementation 'io.micrometer:micrometer-registry-prometheus'
implementation 'io.micrometer:micrometer-tracing-bridge-otel'
implementation 'io.opentelemetry:opentelemetry-exporter-otlp'
```

## Actuator + probes
```yaml
management:
  endpoints.web.exposure.include: health,info,prometheus,metrics
  endpoint.health:
    probes.enabled: true          # /actuator/health/liveness & /readiness
    group.readiness.include: readinessState,db,redis
  metrics.tags.application: ${spring.application.name}
  tracing.sampling.probability: 0.1   # sample 10% in prod
```
- **Liveness**: is the app alive? Fail → restart the pod.
- **Readiness**: can it serve traffic? Fail → remove from load balancer (also used to
  drain during graceful shutdown).

Kubernetes:
```yaml
livenessProbe:  { httpGet: { path: /actuator/health/liveness,  port: 8080 } }
readinessProbe: { httpGet: { path: /actuator/health/readiness, port: 8080 } }
```

## Metrics (Micrometer → Prometheus)
- RED/USE signals come free (http.server.requests, jvm, hikari pool).
- Custom:
```java
meterRegistry.counter("orders.placed", "channel", channel).increment();
Timer.builder("orders.process").register(meterRegistry).record(() -> process());
```
Alert against SLOs on latency percentiles, error rate, and saturation.

## Distributed tracing
Micrometer Tracing auto-propagates trace/span IDs across RestClient/WebClient/Kafka.
Export via OTLP to your collector (Tempo/Jaeger). Every log line should carry the
`traceId`/`spanId` for correlation.

## Structured logging
- JSON logs in prod (logstash-logback-encoder), with `traceId`, `spanId`, service name.
- **Never log secrets/PII** — mask tokens, card numbers, emails; centralize masking.
- Log levels per profile; INFO in prod, DEBUG locally.

## Correlation
Propagate a correlation/request ID at the edge (filter or gateway) and include it in
logs, traces, and outbound headers so a single request is traceable end-to-end.
