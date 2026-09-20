---
name: system-observability-and-slo
description: System-level observability strategy — SLIs/SLOs and error budgets, the three pillars (logging at all levels, metrics, distributed tracing), alerting/alarms tied to SLOs, dashboards and runbooks, and audit trails. Use when designing observability, alerting, or reliability targets across a system.
---

# System Observability & SLOs

## SLIs, SLOs, error budgets
- **SLI:** a measured signal (p99 latency, success rate, freshness).
- **SLO:** the target for an SLI (e.g. 99.9% success, p99 < 300ms).
- **Error budget:** 1 − SLO; spend it on change velocity, halt risky releases when
  exhausted. Alert on **budget burn rate**, not on every blip.

## Three pillars
**Logging (all levels)**
- Structured (JSON), with correlation/trace IDs; consistent levels per environment.
- Centralized aggregation; retention per policy.
- **No secrets/PII in logs** — central masking.

**Metrics**
- RED (Rate, Errors, Duration) for services; USE (Utilization, Saturation, Errors) for
  resources. Business metrics too.
- Micrometer/Prometheus/OTEL → time-series backend; per-service + system dashboards.

**Tracing**
- Distributed tracing across every hop (sync and async); propagate context through
  queues. Sample in prod; keep exemplars for slow/error traces.

## Alerting / alarms
- Alert on **symptoms that affect users / SLOs**, not causes. Reduce noise: page only
  on actionable, user-impacting conditions; everything else is a ticket/dashboard.
- Every alert links to a **runbook** with diagnosis + remediation steps.
- Define severities and escalation; test alerts.

## Dashboards & operations
- Per-service and system-level dashboards (SLOs, RED/USE, dependencies).
- On-call rotation and runbooks; post-incident reviews feed back into design.

## Audit trail
- Immutable, tamper-evident audit log of security- and compliance-relevant events
  (authn/authz decisions, privileged actions, data access, config changes), retained
  and access-controlled — distinct from operational logs.

## Review questions
1. Are SLOs defined with SLIs and error budgets, and do alerts fire on burn rate?
2. Are logs structured, correlated, and free of secrets/PII?
3. Is there end-to-end distributed tracing, including across async hops?
4. Do alerts map to user impact and link to runbooks?
5. Is there an immutable audit trail separate from operational logs?
