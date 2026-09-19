#!/usr/bin/env bash
# secret-scan.sh — non-destructive secret exposure scan of the working tree.
# Prefers gitleaks/trufflehog if installed; falls back to regex grep.
# Usage: security/secret-scan.sh [path]   (default: current dir)
# Read-only. Never prints matched secret values in the fallback (redacts).
set -uo pipefail
TARGET="${1:-.}"

echo "== Secret scan: $TARGET =="

if command -v gitleaks >/dev/null 2>&1; then
  echo "[tool] gitleaks"
  gitleaks detect --source "$TARGET" --no-banner --redact -v || true
  exit 0
fi

if command -v trufflehog >/dev/null 2>&1; then
  echo "[tool] trufflehog"
  trufflehog filesystem "$TARGET" --no-update || true
  exit 0
fi

echo "[fallback] regex scan (install gitleaks for full coverage)"
# High-signal patterns. Matches are reported by file:line with the value redacted.
PATTERNS='(AKIA[0-9A-Z]{16})|(aws_secret_access_key\s*=)|(-----BEGIN [A-Z ]*PRIVATE KEY-----)|(ghp_[A-Za-z0-9]{36})|(github_pat_[A-Za-z0-9_]{20,})|(xox[baprs]-[A-Za-z0-9-]+)|(sk-[A-Za-z0-9]{20,})|(eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,})|((password|passwd|secret|token|api[_-]?key)\s*[:=]\s*["'"'"'][^"'"'"']{6,})'

grep -rInE "$PATTERNS" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target \
  --exclude-dir=dist --exclude-dir=build --exclude-dir=.venv \
  "$TARGET" 2>/dev/null \
  | sed -E 's/(=|:)[[:space:]]*.{0,}/\1 [REDACTED]/' \
  | sort -u \
  || echo "(no matches by fallback patterns — not a guarantee; use gitleaks)"
