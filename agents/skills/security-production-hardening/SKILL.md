---
name: security-production-hardening
description: Production hardening review — network/VPC segmentation, TLS/mTLS, secrets management (vault), container and image hardening, IaC misconfiguration, least-privilege cloud IAM, and safe defaults. Use when reviewing deployment, infrastructure-as-code, or production configuration.
---

# Production Hardening Review

## Network & VPC
- Data tiers (DB, cache, queues) in **private subnets**; never publicly reachable.
- Security groups / NACLs least-exposure: no `0.0.0.0/0` on SSH/DB/admin ports; ingress
  scoped to known sources.
- Egress controls where feasible; block access to cloud metadata endpoint from
  workloads that don't need it (SSRF pivot).
- TLS in transit end-to-end; internal service-to-service mTLS.

## Secrets management
- Secrets in a **vault/secret manager** (AWS Secrets Manager, Vault, SSM), injected at
  runtime — never in images, env files committed to git, or IaC plaintext.
- Rotation enabled; separate secrets per environment; no shared prod/dev secrets.
- Encryption keys in KMS/HSM; token/at-rest encryption to the highest standard.

## IAM / least privilege
- Cloud roles scoped to the minimum actions/resources; no wildcard `*:*`.
- Distinct roles per service; no long-lived static keys where role assumption works.
- No overly broad trust policies; audit privilege escalation paths.

## Containers & images
- Non-root user; read-only root filesystem where possible; drop Linux capabilities.
- Minimal/distroless base; no build tools or secrets baked into layers.
- Image scanning in CI (trivy/grype); pinned base image digests.
- Resource limits set; no `privileged` containers.

## IaC misconfiguration
- Scan Terraform/CloudFormation/K8s manifests (trivy/checkov/tfsec) for public buckets,
  unencrypted resources, open security groups, disabled logging.
- Enforce encryption-at-rest defaults on storage/DB resources.

## Runtime & operations
- Health-gated readiness; graceful shutdown; no debug endpoints exposed in prod.
- Centralized, tamper-evident logging and monitoring/alerting on security events.
- Backups encrypted and restore-tested; DR posture defined.

## Quick review questions
1. Are data stores private and least-exposed at the network layer?
2. Are all secrets in a vault, rotated, and out of git/images?
3. Is cloud IAM least-privilege (no wildcards)?
4. Are containers non-root, minimal, and scanned?
5. Do IaC scans show public/unencrypted/open resources?
6. Is TLS/mTLS enforced everywhere in transit?
