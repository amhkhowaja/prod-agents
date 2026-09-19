---
name: springboot-microservice-patterns
description: Microservice design patterns for Spring Boot — service decomposition, sync vs async communication, Saga and Outbox for distributed data consistency, CQRS, API Gateway/BFF, service discovery and centralized config, and anti-patterns to avoid. Use when designing service boundaries or inter-service communication.
---

# Spring Boot Microservice Patterns

## Decomposition
- Split by **business capability / bounded context**, one service per context.
- Each service owns its data; **no shared database** across services.
- Use **strangler-fig** to carve services out of a monolith incrementally.

## Communication
| Style | When | Spring |
|-------|------|--------|
| Sync REST | simple request/response, low fan-out | RestClient/WebClient, OpenFeign |
| Sync gRPC | low-latency, typed, internal | grpc-spring-boot-starter |
| Async events | decoupling, buffering, workflows | Spring Kafka / Spring AMQP / Spring Cloud Stream |

Prefer **async/event-driven** to reduce temporal coupling and cascade failures.

## Distributed data consistency
**Saga** (no distributed transactions):
- *Orchestration* — a central coordinator issues commands and compensations (easier to
  reason about, single point of logic).
- *Choreography* — services react to each other's events (looser, harder to trace).
- Every step needs a **compensating action** for rollback.

**Transactional Outbox** (reliable event publishing):
- Write domain change + outbox row in the **same DB transaction**.
- A relay/CDC (Debezium) publishes outbox rows to the broker → no dual-write problem.

**CQRS** — separate write and read models when read/write shapes diverge; combine with
event sourcing only when the audit/replay value justifies the complexity.

## Integration & edge
- **API Gateway**: Spring Cloud Gateway (routing, auth, rate limiting, TLS termination).
- **BFF**: a gateway/aggregator tailored to a client to avoid chatty UIs.

## Cross-cutting infrastructure
- **Config**: Spring Cloud Config / Vault; externalized, environment-specific.
- **Discovery**: platform DNS (Kubernetes Services) or Eureka/Consul.
- **Resilience**: Resilience4j (see springboot-resilience skill).
- **Observability**: correlation IDs + distributed tracing across hops (see
  springboot-observability skill).

## Anti-patterns to avoid
- **Distributed monolith**: services that must deploy together / share a DB.
- **Chatty communication**: N synchronous calls to render one response (use
  aggregation/BFF or events).
- **Shared mutable data store** across services.
- **Synchronous call chains** with no timeouts/circuit breakers (cascading failure).
- **Dual writes** to DB and broker without an outbox (lost/duplicate events).
