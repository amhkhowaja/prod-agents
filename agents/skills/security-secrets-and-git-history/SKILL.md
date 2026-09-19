---
name: security-secrets-and-git-history
description: How to review for secret exposure in code, config, and full git history, using the security scan scripts, and how to remediate (rotate + purge history). Use when checking for leaked credentials, keys, or tokens.
---

# Secrets & Git History Review

## Scan the working tree
Use the provided script (prefers gitleaks/trufflehog, falls back to redacted regex):
```bash
bash agents/scripts/security/secret-scan.sh .
```
Look in: source, config (`*.yml/.properties/.env`), CI files, Dockerfiles, IaC,
comments, test fixtures, and notebooks.

## Scan the FULL history (critical)
A secret deleted from HEAD is **still in history** and still compromised:
```bash
bash agents/scripts/security/git-history-scan.sh .
```
Also check the remote/forks and CI logs where the value may have propagated.

## What counts as a secret
Cloud keys (AKIA…), private keys (`BEGIN PRIVATE KEY`), OAuth/PAT tokens (ghp_…,
xox…), API keys (sk-…), JWTs, DB connection strings with passwords, webhook signing
secrets, and high-entropy strings assigned to `password/secret/token/api_key`.

## Reporting rule
**Never print the secret value.** Report location (file:line or commit hash) and type
only. Treat any real-looking credential as compromised.

## Remediation (order matters)
1. **Rotate immediately** — assume the secret is public the moment it hit git.
2. **Revoke** the old credential at the provider.
3. **Purge history** — `git filter-repo` (preferred) or BFG to remove the blob from all
   commits; then coordinate a force-push and have collaborators re-clone.
4. **Migrate** the secret to a vault/secret manager; inject at runtime.
5. **Prevent recurrence** — pre-commit secret hooks (gitleaks) and CI secret scanning;
   `.gitignore` for env/secret files.

## Quick review questions
1. Are there secrets in the working tree?
2. Are there secrets anywhere in git history (not just HEAD)?
3. For each found secret: rotated, revoked, purged, and moved to a vault?
4. Is there a pre-commit/CI guard to stop the next leak?
