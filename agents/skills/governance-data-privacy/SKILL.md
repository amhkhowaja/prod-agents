---
name: governance-data-privacy
description: Data governance and privacy program design — data inventory and flow mapping, classification, GDPR data-subject rights, lawful basis and consent, retention/disposal, DPIA, and cross-border transfers. Use when assessing privacy posture, GDPR readiness, or how a system handles personal data.
---

# Data Governance & Privacy (GDPR-centered)

## Data inventory & flow mapping (do this first)
You cannot govern data you haven't mapped. Build a record of:
- **What** personal/sensitive data exists (and special categories: health, biometrics,
  etc.).
- **Where** it lives (DBs, caches, logs, backups, object storage, third parties, agent
  traces).
- **How** it flows (ingestion → processing → storage → sharing → deletion).
- **Who** accesses it and under what basis; **cross-border** transfers.

## Classification
Public / Internal / Confidential / Restricted; tag PII / PHI / PCI. Classification
drives encryption, access, retention, and logging rules.

## GDPR principles → controls
- **Lawful basis** for each processing purpose (consent, contract, legitimate interest…).
- **Purpose limitation** — data used only for the stated purpose.
- **Data minimization** — collect/store/return only what's needed.
- **Accuracy**, **storage limitation** (retention), **integrity & confidentiality**.
- **Accountability** — be able to demonstrate all of the above.

## Data-subject rights (must be operationally fulfillable)
Access, rectification, **erasure ("right to be forgotten")**, portability, restriction,
objection. Critical test: when you erase, does it delete across **primaries, replicas,
backups, caches, search indexes, logs, and processors** — or just the main table?
Provide an SLA and an auditable request workflow.

## Consent
Freely given, specific, informed, unambiguous; as easy to withdraw as to give; records
of consent kept. No pre-ticked boxes.

## Retention & disposal
Defined schedule per data category; automated, enforced deletion; secure disposal.
Don't keep data "just in case" — that's a liability.

## DPIA (Data Protection Impact Assessment)
Required for high-risk processing: large-scale special-category data, systematic
profiling/automated decisions, large-scale monitoring. Document risks and mitigations.

## Cross-border transfers
Ensure a valid mechanism (adequacy decision, SCCs) for transfers out of the EEA;
verify subprocessor locations.

## Breach obligations
GDPR: notify the supervisory authority within **72 hours** of becoming aware of a
personal-data breach (where risk to individuals); notify data subjects if high risk.
Have the process and contacts ready.

## Review questions
1. Is there a current data inventory and flow map?
2. Does each processing purpose have a lawful basis and minimized data?
3. Can the system actually fulfill erasure/access everywhere data lives?
4. Are retention schedules defined and enforced by automated deletion?
5. Is a DPIA done for high-risk processing?
6. Are cross-border transfers covered by a valid mechanism?
7. Is the 72-hour breach-notification process ready?

> Not legal advice — flag where a DPO or privacy counsel must confirm.
