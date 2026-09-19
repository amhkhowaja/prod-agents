---
name: security-authn-authz-review
description: Checklist for reviewing authentication, authorization, RBAC/ABAC, and least privilege — session/JWT handling, RBAC correctness, IDOR/BOLA, privilege escalation, and least-privilege enforcement across app, DB, and cloud. Use when reviewing auth flows or access-control logic.
---

# Authentication & Authorization Review

## Authentication
- Standard, vetted mechanism (OAuth2/OIDC); avoid hand-rolled auth.
- **JWT:** verify signature, `iss`/`aud`/`exp`/`nbf`; reject `alg:none` and algorithm
  confusion (RS256↔HS256); short TTL; refresh rotation; server-side revocation/logout.
- **Sessions:** secure, httpOnly, SameSite cookies; regeneration on login; idle +
  absolute timeout; CSRF protection for cookie-based auth.
- **Credentials:** strong password hashing (bcrypt/argon2/scrypt, salted); no plaintext;
  brute-force/lockout/rate-limit; MFA where warranted.

## Authorization & RBAC/ABAC
- Enforce **server-side** on every sensitive operation — never trust client claims/UI.
- **RBAC:** roles map to permissions; check the permission at the action, not just
  presence of a login. **ABAC:** attribute/context checks are evaluated correctly.
- **BOLA/IDOR:** object-level ownership verified for every ID-scoped operation; test by
  accessing another user's/tenant's object.
- **Function-level:** admin/privileged endpoints gated; no hidden-but-reachable routes.

## Least privilege (everywhere)
- App roles, **DB roles**, cloud **IAM**, and service accounts each scoped to the
  minimum. No shared admin/superuser for routine operations.
- Segregate duties: migration vs runtime, read vs write, human vs machine identities.

## Privilege escalation
- Look for: mass-assignment of role/permission fields, IDOR into admin objects,
  missing authz on internal APIs, trusting `X-Forwarded-*`/headers for identity,
  confused-deputy via service accounts.

## Multi-tenant authz
- Tenant boundary enforced on every path (app + DB RLS); no cross-tenant IDOR; caches
  keyed by tenant.

## Quick review questions
1. Is authz enforced server-side on every sensitive action?
2. Is object ownership checked (BOLA/IDOR) for ID-scoped operations?
3. Are JWTs fully validated (sig, claims, alg) with sane TTL/rotation?
4. Is least privilege applied to app, DB, and cloud identities?
5. Can a user escalate via mass assignment or missing internal-endpoint authz?
6. Is the tenant boundary enforced on every path?
