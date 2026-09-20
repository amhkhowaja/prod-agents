---
name: governance-vendor-and-audit-readiness
description: Third-party/vendor risk management, subprocessor/DPA governance, supply-chain risk, and audit-readiness (evidence collection, control testing, gap and remediation tracking). Use when assessing vendor risk or preparing an organization for a SOC 2 / ISO audit.
---

# Vendor Risk & Audit Readiness

## Third-party / vendor risk
Your compliance is only as strong as your critical vendors' — you inherit their risk.
- **Vendor inventory**: every third party touching your data or infrastructure.
- **Risk tiering**: by data sensitivity + criticality; deeper diligence for high tier.
- **Due diligence**: obtain and review their **SOC 2 Type II / ISO 27001** reports;
  check scope, exceptions, and the report period; note complementary user-entity
  controls (things *you* must do).
- **Contracts**: DPAs / subprocessor agreements for processors of personal data; SLAs;
  breach-notification and audit clauses.
- **Ongoing monitoring**: re-review annually or on report expiry; track incidents and
  status changes; maintain a subprocessor list (and notify customers on change if
  contractually required).

## Supply-chain / open source
- Dependency governance: license compliance, **SBOM**, CVE policy and remediation SLAs
  (coordinate with the Security Reviewer's dep-audit).
- Provenance/integrity: pinned versions, lockfiles, signed artifacts where possible.

## Audit readiness
- **Evidence strategy**: prefer automated/continuous collection over manual scrambles;
  store evidence with the control it supports and a timestamp.
- **Control testing cadence**: schedule operating-effectiveness tests (access reviews,
  restore tests, change-log reviews) so Type II evidence accrues over the period.
- **Gap register**: every gap has an owner, remediation, and target date; track to
  closure.
- **Walkthrough readiness**: be able to demonstrate each control end-to-end to an
  auditor with sampling; prepare management assertions.
- **Complementary controls**: document what you rely on vendors for and what your
  customers must do.

## Assessment output (routes into the Governance & Compliance Assessment)
- Vendor register with tier, report status, DPA status, next-review date.
- Supply-chain risk summary and CVE/license exceptions.
- Audit-readiness scorecard: controls with evidence vs gaps, by framework.

## Review questions
1. Is there a complete vendor inventory with risk tiers?
2. Do critical vendors have current SOC 2/ISO reports and DPAs?
3. Are subprocessors tracked and customers notified on change (if required)?
4. Is dependency/supply-chain risk governed (SBOM, CVE SLA, licenses)?
5. Is evidence collected continuously, with a gap register tracked to closure?
6. Could you pass an auditor walkthrough of each control today?
