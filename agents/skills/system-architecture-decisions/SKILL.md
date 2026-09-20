---
name: system-architecture-decisions
description: How to turn use-case stories into an architecture, write Architecture Decision Records (ADRs), model quality attributes/SLOs, apply C4 diagrams, and produce a risk assessment. Use when framing a new system, making a significant architectural choice, or documenting tradeoffs.
---

# Architecture Decisions, ADRs & Risk

## From use cases to architecture
1. Capture **use-case stories** (actor → goal → outcome) and rank by value/frequency.
2. Derive **quality attributes** and **SLOs/SLIs**: latency, throughput, availability,
   durability, security, cost. These drive the architecture more than features do.
3. State **constraints and non-goals** explicitly; assess **complexity** honestly.
4. **Integrate first:** inventory existing tools/services/platforms and prefer reuse
   (managed cloud or well-defined OSS) over new builds.

## C4 views (as text)
- **Context:** the system, its users, and external systems.
- **Container:** deployable units (services, DBs, queues, frontends) and how they talk.
- **Component:** inside a container (defer to specialists).
Keep diagrams as labeled text/boxes; show protocols and sync/async on each edge.

## ADR format
```
# ADR-000: <title>
Status: proposed | accepted | superseded by ADR-00X
Date: YYYY-MM-DD
## Context
Forces at play: requirements, constraints, SLOs, existing tooling.
## Options considered
1. Option A — pros / cons / cost / risk
2. Option B — pros / cons / cost / risk
## Decision
The chosen option and why it best fits the forces.
## Consequences
What becomes easier/harder; follow-up work; what we accept.
```
Record every significant, hard-to-reverse decision. Supersede rather than delete.

## Managing complexity
- Prefer a modular monolith or few well-bounded services; each new service/queue/store
  must earn its keep against operational cost.
- Avoid the distributed monolith and speculative generality.

## Risk assessment
| Risk | Category | Likelihood | Impact | Mitigation | Owner |
|------|----------|-----------|--------|------------|-------|
| ... | tech/ops/sec/delivery | L/M/H | L/M/H | ... | ... |
- Call out single points of failure, consistency hazards, scaling cliffs, vendor
  lock-in, compliance gaps, and delivery risks.
- Pair each significant risk with a concrete mitigation and an owner.

## Output
Feed decisions into the System Architecture Document: SLOs, C4 views, ADRs, and the
risk register, with each bounded context routed to the owning specialist agent.
