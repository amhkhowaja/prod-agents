---
name: governance-control-frameworks
description: Mapping regulatory and framework requirements (SOC 2 TSC, ISO 27001 Annex A, PCI-DSS, HIPAA) to concrete engineering controls and evidence via a single reusable control matrix. Use when scoping a compliance effort, building a control matrix, or preparing for an audit.
---

# Control Frameworks & Mapping

## Principle: map once, satisfy many
Most frameworks overlap heavily (access control, encryption, logging, change mgmt).
Maintain **one control matrix** and map each control to multiple framework
requirements — test once, evidence once, satisfy SOC 2 + ISO + others.

## The frameworks (scope carefully — scope drives cost)
| Framework | Applies when | Core idea |
|-----------|--------------|-----------|
| **SOC 2** | SaaS/B2B trust | Trust Services Criteria; Type I (point-in-time) vs Type II (operating over time) |
| **ISO/IEC 27001** | formal ISMS / international | risk-based ISMS + Annex A controls + Statement of Applicability |
| **PCI-DSS** | store/process/transmit card data | protect cardholder data; minimize scope aggressively |
| **HIPAA** | US PHI (health) | Privacy + Security Rules; safeguards for PHI |
| **GDPR** | EU personal data | data-protection principles + data-subject rights (see governance-data-privacy skill) |

## SOC 2 Trust Services Criteria
- **Security (Common Criteria, CC)** — always in scope. CC1 governance, CC2 comms,
  CC3 risk, CC4 monitoring, CC5 control activities, CC6 access/logical security,
  CC7 operations/incident, CC8 change mgmt, CC9 risk mitigation.
- Optional: **Availability, Confidentiality, Processing Integrity, Privacy** — add only
  if you commit to them.

## Control matrix format
```
| Control ID | Control description | SOC2 | ISO A. | Owner | Status | Evidence / Gap |
|-----------|---------------------|------|--------|-------|--------|----------------|
| AC-01 | MFA enforced for all admin access | CC6.1 | A.9.4 | Platform | implemented | IdP config + access log |
| CM-01 | All prod changes via reviewed PR + CI gate | CC8.1 | A.12.1 | SysArch | partial | PR rule yes; emergency-change process missing |
```
Status = implemented / partial / missing. Evidence must be concrete and retrievable.

## Evidence types (prefer automated/continuous)
Config exports, IdP/access logs, CI pipeline definitions, IaC, audit-log samples,
ticket history, signed policies, access-review records, backup-restore test results.

## Type II mindset
SOC 2 Type II and ISO require controls that **operate over a period**. Design for
continuous evidence (scheduled access reviews, automated control checks) — not a
one-time scramble before the audit.

## Review questions
1. Is scope minimized and explicit (systems, data, frameworks)?
2. Does every in-scope requirement map to a control with an owner?
3. Is every control backed by retrievable evidence?
4. Are controls designed to operate continuously (Type II)?
5. Is there a gap register with remediation owners and dates?
