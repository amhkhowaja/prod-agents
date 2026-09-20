---
name: system-cloud-infrastructure
description: Choosing cloud model (public/private/hybrid), VPC/network topology, runtime (Kubernetes vs Docker vs serverless), managed cloud services vs self-hosted open source, and IaC — with cost, lock-in, and ops tradeoffs. Use when designing infrastructure, deployment topology, or making build-vs-buy platform decisions.
---

# Cloud & Infrastructure Topology

## Cloud model
| Model | When | Tradeoffs |
|-------|------|-----------|
| Public cloud | default; elasticity, managed services, speed | cost at scale, lock-in |
| Private cloud / on-prem | data residency, regulation, existing capex | ops burden, slower elasticity |
| Hybrid | migration, burst, regulated + non-regulated split | integration + networking complexity |

Decide per **quality attributes** (residency, compliance, latency, cost) — not fashion.

## Network / VPC topology
- Public subnets: only load balancers / bastion; **data tiers in private subnets**.
- Segment by tier/trust; security groups least-exposure (no `0.0.0.0/0` on sensitive
  ports); private endpoints for managed services.
- TLS in transit end-to-end; internal mTLS; egress controls; block workload access to
  the cloud metadata endpoint unless needed (SSRF pivot).

## Runtime choice
| Runtime | Fits | Watch out |
|---------|------|-----------|
| Kubernetes | many services, portability, complex orchestration | operational complexity; needs platform skill |
| Containers/Docker (ECS/Fargate/Nomad) | moderate service count, less ops | fewer primitives than k8s |
| Serverless (Lambda/Cloud Run) | event-driven, spiky, low ops | cold starts, limits, per-invoke cost |
Match to team maturity and workload; don't adopt k8s for three services.

## Managed vs open-source
- Prefer **managed** for undifferentiated heavy lifting (DB, queue, cache) to cut ops.
- Prefer **well-defined OSS** where lock-in/cost/control matters — but price the ops.
- **Integrate existing/conventional tools first** before introducing new platforms.
- Record the build-vs-buy call as an ADR (cost, lock-in, ops, time-to-market).

## Infrastructure as code
- Everything reproducible in IaC (Terraform/Pulumi/CloudFormation); no click-ops.
- Environment parity (dev/staging/prod) from the same modules with per-env config.
- Scan IaC for misconfig (public buckets, open SGs, unencrypted, disabled logging).

## Scaling & resources
- **Horizontal** (stateless services, add replicas) vs **vertical** (bigger instance
  for stateful/CPU-bound) — decide per component; enable **autoscaling** with clear
  signals (CPU/RPS/queue depth/latency).
- Set resource requests/limits; watch **resource utilization** and cost.

## Edge & delivery
- **CDN** for static assets and cacheable responses; regional presence for latency.
- Load balancing (L7) with health-gated routing.

## Quick decisions to record as ADRs
1. Public vs private vs hybrid, and why.
2. Runtime (k8s / containers / serverless).
3. Each managed-vs-OSS build-or-buy call.
4. Scaling model and autoscaling signals per service.
