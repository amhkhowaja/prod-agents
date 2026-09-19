---
name: security-compliance-and-audit
description: Checklist for reviewing GDPR and SOC 2 compliance controls, data protection, and logging/audit-logging practices — including keeping secrets and PII out of logs. Use when reviewing compliance posture, data handling, or logging.
---

# Compliance (GDPR / SOC 2) & Audit Logging Review

## GDPR / data protection
- **Lawful basis & consent** captured where required; purpose limitation.
- **Data minimization:** only necessary PII collected/stored/returned.
- **Right to erasure / access / portability:** mechanisms exist and actually delete
  across primaries, replicas, backups, caches, and logs.
- **Data residency:** data stored/processed in allowed regions; check cross-region
  replication and third-party processors.
- **Processor obligations / DPAs** for subprocessors; data-flow mapping exists.
- PII classification and encryption; pseudonymization/tokenization where feasible.

## SOC 2 (common criteria)
- **Access control:** least privilege, provisioning/deprovisioning, MFA — evidence.
- **Change management:** PR review, CI gates, audit trail of changes.
- **Encryption:** at rest and in transit, documented key management.
- **Monitoring:** security event monitoring and alerting; incident response process.
- **Availability/backup:** tested backups, DR, uptime monitoring.
- Controls should be **evidenced**, not just claimed.

## Logging & audit logging
- **Security events logged:** authn success/failure, authz denials, privileged actions,
  data access to sensitive records, config changes.
- **Audit trail** is tamper-evident (append-only/immutable store), time-synced, and
  retained per policy.
- **No sensitive data in logs:** no secrets, tokens, passwords, full PANs, or excessive
  PII. Masking/redaction enforced centrally (not per-developer discretion).
- Logs support incident forensics (correlation/trace IDs) without over-collecting.
- Log access is itself restricted and audited.

## Quick review questions
1. Is PII minimized, classified, and encrypted?
2. Does erasure actually remove data everywhere (incl. backups/logs)?
3. Is data residency honored across replication and processors?
4. Are security-relevant events audit-logged, immutably and retained?
5. Are secrets/PII kept out of logs via central masking?
6. Are SOC 2 controls (access, change, encryption, monitoring) evidenced?
