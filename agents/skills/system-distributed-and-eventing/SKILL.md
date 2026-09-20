---
name: system-distributed-and-eventing
description: Designing distributed and event-driven architectures — sync vs async, event patterns (event notification/carried state/sourcing), messaging semantics (ordering, idempotency, exactly-once vs at-least-once), Saga/Outbox for cross-service consistency, and avoiding the distributed-monolith. Use when services must communicate or share state across boundaries.
---

# Distributed & Event-Driven Architecture

## Fallacies to respect
The network is unreliable, latency is not zero, bandwidth/ topology/ order change.
Design for **partial failure** everywhere — every remote call can time out, retry, or
arrive twice.

## Sync vs async
- **Sync (REST/gRPC):** simple request/response, immediate result; couples caller to
  callee availability — always add timeout + circuit breaker.
- **Async (queue/stream/pub-sub):** decoupling, buffering, resilience to downstream
  outages, natural scaling; costs eventual consistency and harder debugging.
Prefer async between services to cut temporal coupling and cascade failures.

## Event styles
| Style | Payload | Use |
|-------|---------|-----|
| Event notification | "something happened" + id | trigger, low coupling; consumer calls back for detail |
| Event-carried state transfer | full state in event | consumer needs no callback; watch staleness/duplication |
| Event sourcing | events are the source of truth | audit/replay value; higher complexity |

## Messaging semantics
- Assume **at-least-once** delivery → make consumers **idempotent** (idempotency key +
  dedupe). Exactly-once is usually effectively-once via idempotency.
- **Ordering:** per-key/partition ordering (Kafka partitions) if order matters; don't
  assume global order.
- Handle poison messages with dead-letter queues and retry with backoff.

## Cross-service data consistency
- No distributed ACID transactions. Use:
  - **Saga** (orchestration or choreography) with **compensating actions** for rollback.
  - **Transactional Outbox** (+ CDC/Debezium) to publish events atomically with the DB
    write — avoids dual-write loss/duplication.
- **No data redundancy** as source of truth: one owner per datum; replicas are
  read-only projections rebuilt from events, with the owner clearly identified.
- Decide **strong vs eventual** consistency per use case and make the UI honest about it.

## Patterns & anti-patterns
- Patterns: gateway/BFF, CQRS (split read/write models), materialized views from events.
- Anti-patterns: **distributed monolith** (services deploy together / share a DB),
  chatty sync call chains, dual writes without outbox, shared mutable store.

## Review questions
1. Is every remote call bounded by timeout + retry + breaker?
2. Are consumers idempotent under at-least-once delivery?
3. Is cross-service consistency handled via Saga/Outbox, not distributed txns?
4. Does each datum have exactly one owner (no conflicting sources of truth)?
5. Are you accidentally building a distributed monolith?
