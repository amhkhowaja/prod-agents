---
name: system-cicd-and-deployment
description: CI/CD pipeline design, dev/staging/prod environment strategy and parity, deployment strategies (blue-green, canary, shadow), automated rollback, backup/restore and upgrade strategies, and version control/branching. Use when designing delivery, release, or rollback for a system.
---

# CI/CD, Environments & Deployment

## Pipeline stages (with gates)
1. **Build** — reproducible, pinned deps, SBOM.
2. **Test** — unit, integration (Testcontainers), contract tests between services.
3. **Security gates** — SAST, dependency/CVE scan, secret scan, IaC scan (fail on
   Critical/High).
4. **Package** — immutable, versioned artifact/image (scanned, signed).
5. **Deploy** — progressive rollout with automated verification + rollback.
Every stage is a gate; a red gate blocks promotion.

## Version control & branching
- Trunk-based or short-lived branches; PR review required; protected `main`.
- **Semantic versioning** of artifacts and APIs; tag releases; changelog.
- No secrets in VCS; pre-commit secret hooks.

## Environments (parity)
| Env | Purpose | Notes |
|-----|---------|-------|
| dev | fast iteration | ephemeral/preview envs per PR ideal |
| staging | prod-like validation | same IaC modules, prod-like data (masked) |
| prod | live | change-controlled, gated |
Keep environments **from the same IaC** with per-env config/secrets injected at runtime
(12-factor). Differences must be explicit, never silent.

## Deployment strategies
- **Blue-green:** two environments, switch traffic; instant rollback by switching back.
- **Canary:** shift a small % of traffic, watch SLIs, then ramp; auto-rollback on
  regression.
- **Shadow:** mirror prod traffic to the new version without serving responses (safe
  validation).
- **Rolling:** replace instances gradually (default in k8s); ensure backward-compatible.

## Backward compatibility & migrations
- **Expand-contract** for schema/API: add new (expand), migrate, then remove old
  (contract) — never break live consumers.
- DB migrations forward-compatible; every migration has a tested **rollback**.

## Automated rollback
- Define rollback triggers on SLIs (error rate, latency, saturation).
- Rollback must be one action and always available; practice it.

## Backup / restore & upgrade
- Automated, encrypted backups; **restore drills** (a backup you never restored isn't a
  backup). Define **RPO/RTO**.
- Upgrade strategy for platforms/dependencies (staged, tested, reversible).

## Review questions
1. Do security/quality gates block promotion on failure?
2. Are dev/staging/prod built from the same IaC with only config differing?
3. Is there a canary/blue-green path with automated rollback on SLI regression?
4. Are schema/API changes expand-contract and backward compatible?
5. Are backups restore-tested with defined RPO/RTO?
