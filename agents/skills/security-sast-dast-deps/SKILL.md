---
name: security-sast-dast-deps
description: How to run and interpret static analysis (SAST), dependency/CVE audits, and plan dynamic testing (DAST) using the provided scan scripts. Covers reducing false positives and SBOM/supply-chain checks. Use when performing a code/dependency security scan.
---

# SAST, DAST & Dependency (CVE) Review

## SAST — static analysis
```bash
bash agents/scripts/security/sast-scan.sh .
```
Prefers semgrep (`auto` + `p/owasp-top-ten`); falls back to dangerous-pattern grep
(injection sinks, command exec, XSS sinks, weak crypto, disabled TLS verification).

**Interpreting results — reduce false positives:**
- Confirm the sink is reachable from untrusted input (trace the taint path).
- Check for existing mitigations (parameterization, encoding, framework escaping).
- Downgrade/drop findings that aren't exploitable in context; say why.

## Dependencies & CVEs
```bash
bash agents/scripts/security/dep-audit.sh .
```
Auto-detects npm/pnpm/yarn, pip, Maven/Gradle, Go, Cargo; universal fallback via trivy.

**Review:**
- Map each CVE to a fixed version; note if it's reachable/affected config.
- **FOSS health:** unmaintained/abandoned packages, single-maintainer risk,
  typosquatting, suspicious postinstall scripts.
- Pin versions; verify lockfile integrity.
- Generate an **SBOM** (syft/cyclonedx) and gate CVEs in CI.

## DAST — dynamic testing (recommend, don't attack)
Do **not** run intrusive/active attacks against live systems without written
authorization. Instead:
- Identify the dynamic surfaces that need testing: auth flows, access control (BOLA),
  injection points, SSRF, business-logic abuse.
- Recommend an authorized DAST tool (OWASP ZAP, Burp) and a scoped pentest plan, run
  against a non-prod environment with sign-off.

## Container / IaC
If images or IaC are present, run trivy for image CVEs and misconfiguration
(public buckets, open SGs, unencrypted resources, disabled logging).

## Output
Feed confirmed findings into the Security Review Report with severity, CWE/OWASP
mapping, evidence, exploit path, and remediation routed to the owning crew agent.
