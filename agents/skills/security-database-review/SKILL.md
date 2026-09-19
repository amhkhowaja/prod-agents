---
name: security-database-review
description: Checklist and techniques for reviewing database-layer security — SQL/NoSQL injection, Row-Level Security (RLS), least-privilege DB roles, encryption at rest, backup security, tenant isolation, and audit of privileged actions. Use when reviewing data-access code, schema, or database configuration.
---

# Database Security Review

## Injection (SQL / NoSQL / ORM)
- Every query must be **parameterized**. Flag string concatenation / interpolation
  into SQL, JPQL/HQL, or NoSQL filters.
- ORMs: `@Query` with concatenation, `createQuery(String)` built from input, MongoDB
  `$where`/`$expr` with user input, dynamic sort/column names not allow-listed.
- Verify: does user input ever reach a query without binding? Trace the taint path.

## Row-Level Security (RLS) & tenant scoping
- For multi-tenant / row-scoped data, confirm RLS policies exist and are **enabled**
  (e.g. Postgres `ENABLE ROW LEVEL SECURITY` + `FORCE`), not just defined.
- Check the policy predicate uses the *session/tenant* identity, not a client-supplied
  value that can be spoofed.
- If RLS is app-enforced instead of DB-enforced, verify every query path applies the
  tenant filter — one missed query = cross-tenant leak.

## Least privilege (DB roles)
- No app connecting as superuser/`root`/`postgres`. Per-service accounts with only the
  needed grants (no `DROP`, no cross-schema unless required).
- Separate migration credentials (DDL) from runtime credentials (DML).
- Read replicas accessed with read-only roles.

## Encryption & key management
- Encryption at rest on the DB, disks, **and backups/snapshots**.
- TLS required for DB connections (`sslmode=require`/`verify-full`); reject plaintext.
- Column/field-level encryption or tokenization for the most sensitive fields; keys in
  KMS/HSM, rotated.

## Backups & recovery
- Backups encrypted, access-controlled, and tested (restore drills).
- No production dumps copied to dev without masking/anonymization.

## Auditing
- Audit logging of privileged/DDL actions and sensitive-data access; tamper-evident,
  retained per policy. No secrets/PII in the audit stream beyond what's required.

## Quick review questions
1. Can any input reach a query unparameterized?
2. Is tenant isolation enforced at the DB (RLS) or only hopefully in the app?
3. Does the app login have more privilege than it needs?
4. Is data encrypted at rest, in transit, and in backups?
5. Are privileged actions audited?
