---
name: springboot-resilience
description: Production resilience for Spring Boot microservices using Resilience4j — circuit breaker, retry with backoff+jitter, rate limiter, bulkhead, time limiter — plus timeouts on outbound calls and graceful shutdown. Use when a service makes remote calls or must degrade gracefully under dependency failure.
---

# Spring Boot Resilience (Resilience4j)

## Principle
Every outbound/remote call needs: a **timeout**, a **retry policy**, and a **fallback
or circuit breaker**. Assume dependencies fail. Never let one slow dependency exhaust
your threads.

## Dependency
```gradle
implementation 'io.github.resilience4j:resilience4j-spring-boot3'
implementation 'org.springframework.boot:spring-boot-starter-aop'
```

## Config (application.yml)
```yaml
resilience4j:
  circuitbreaker.instances.inventory:
    slidingWindowSize: 20
    failureRateThreshold: 50
    waitDurationInOpenState: 10s
    permittedNumberOfCallsInHalfOpenState: 5
  retry.instances.inventory:
    maxAttempts: 3
    waitDuration: 200ms
    enableExponentialBackoff: true
    exponentialBackoffMultiplier: 2
    enableRandomizedWait: true          # jitter
  ratelimiter.instances.inventory:
    limitForPeriod: 100
    limitRefreshPeriod: 1s
    timeoutDuration: 0
  bulkhead.instances.inventory:
    maxConcurrentCalls: 25
  timelimiter.instances.inventory:
    timeoutDuration: 2s
```

## Usage
```java
@CircuitBreaker(name = "inventory", fallbackMethod = "inventoryFallback")
@Retry(name = "inventory")
@Bulkhead(name = "inventory")
public InventoryResponse check(String sku) {
    return inventoryClient.check(sku);   // RestClient/WebClient with its own timeout
}

private InventoryResponse inventoryFallback(String sku, Throwable t) {
    // safe degraded response — never rethrow blindly
    return InventoryResponse.unknown(sku);
}
```

## Outbound client timeouts (always set)
```java
RestClient.builder()
  .requestFactory(new SimpleClientHttpRequestFactory() {{
      setConnectTimeout(1000); setReadTimeout(2000);
  }})
  .build();
```

## Graceful shutdown
```yaml
server.shutdown: graceful
spring.lifecycle.timeout-per-shutdown-phase: 30s
```
Wire readiness to drain traffic before shutdown; return NOT_READY on `readiness` probe
during shutdown so the load balancer stops routing.

## Anti-patterns to avoid
- Retrying non-idempotent operations without idempotency keys.
- Retry storms (no backoff/jitter) amplifying an outage.
- Circuit breaker without a meaningful fallback.
- Blocking calls inside a reactive (WebFlux) pipeline.
