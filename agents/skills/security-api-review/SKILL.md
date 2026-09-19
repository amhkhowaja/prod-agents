---
name: security-api-review
description: Checklist for reviewing API security — OWASP API Security Top 10 (BOLA/IDOR, broken auth, excessive data exposure, mass assignment, function-level authz), input validation, TLS, rate limiting, SSRF, and error handling. Use when reviewing REST/gRPC/GraphQL endpoints or gateway configuration.
---

# API Security Review (OWASP API Top 10 aligned)

## Access control (the #1 API risk)
- **BOLA / IDOR (object-level authz):** every endpoint that takes an ID must verify the
  caller owns/may access *that* object — server-side, not just "is authenticated".
  Test by swapping IDs across users/tenants.
- **Function-level authz:** admin/internal endpoints must enforce role checks; don't
  rely on the UI hiding them.
- Enforce authz at the service layer, not only the gateway.

## Authentication
- Strong scheme (OAuth2/OIDC); validate JWT signature, `iss`, `aud`, `exp`; reject
  `alg: none`; short-lived tokens with rotation/revocation.
- Service-to-service via mTLS or M2M tokens; API keys scoped and rotatable.

## Data exposure
- **Excessive data exposure:** responses return only needed fields; no dumping full
  entities (internal flags, password hashes, other users' data). Use DTOs, not raw
  models.
- **Mass assignment:** binding request bodies straight to entities lets clients set
  fields they shouldn't (roles, ownership). Allow-list bindable fields.

## Input validation & injection
- Validate/sanitize all input (schema validation at the edge); enforce types, ranges,
  lengths.
- Parameterize downstream queries; prevent SSRF (validate/allow-list outbound URLs,
  block link-local/metadata endpoints like 169.254.169.254).

## Transport & resources
- **TLS everywhere**, strong ciphers, HSTS; no plaintext internal hops (mTLS).
- **Rate limiting & quotas** per consumer/tenant; `429` with `Retry-After`; payload and
  page-size caps to prevent resource exhaustion.
- Pagination bounded; no unbounded queries.

## Error handling & headers
- Consistent error envelope; no stack traces / internal detail leaked; no verbose
  framework errors in prod.
- Security headers (CORS locked down, CSP for browser APIs, no wildcard `*` with
  credentials).

## Quick review questions
1. Does every object-scoped endpoint check ownership (BOLA)?
2. Can a request body set fields it shouldn't (mass assignment)?
3. Do responses over-expose data?
4. Is authz enforced at the service, not just the gateway/UI?
5. Are rate limits and payload caps in place?
6. Is TLS enforced and are outbound calls SSRF-guarded?
