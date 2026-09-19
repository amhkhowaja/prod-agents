#!/usr/bin/env bash
# git-history-scan.sh — scan full git history for secrets committed and later removed.
# Secrets deleted from HEAD still live in history and must be rotated + purged.
# Usage: security/git-history-scan.sh [repo-path]   (default: current dir)
# Read-only.
set -uo pipefail
REPO="${1:-.}"
cd "$REPO" || { echo "not a path: $REPO"; exit 1; }

if [ ! -d .git ]; then
  echo "Not a git repository: $REPO"; exit 1
fi

echo "== Git history secret scan: $REPO =="

if command -v gitleaks >/dev/null 2>&1; then
  echo "[tool] gitleaks (full history via --log-opts)"
  gitleaks detect --source . --no-banner --redact -v || true
  exit 0
fi

if command -v trufflehog >/dev/null 2>&1; then
  echo "[tool] trufflehog git"
  trufflehog git "file://$(pwd)" --no-update || true
  exit 0
fi

echo "[fallback] scanning added lines across all commits (install gitleaks for full coverage)"
PATTERNS='(AKIA[0-9A-Z]{16})|(-----BEGIN [A-Z ]*PRIVATE KEY-----)|(ghp_[A-Za-z0-9]{36})|(xox[baprs]-[A-Za-z0-9-]+)|(sk-[A-Za-z0-9]{20,})|((password|secret|token|api[_-]?key)\s*[:=]\s*["'"'"'][^"'"'"']{6,})'

# Search every commit's added content; report commit + file, redact the value.
git log -p --all --no-color 2>/dev/null \
  | grep -InE "^\+.*($PATTERNS)" \
  | sed -E 's/(=|:)[[:space:]]*.{0,}/\1 [REDACTED]/' \
  | head -200 \
  || echo "(no matches by fallback patterns — use gitleaks for authoritative results)"

echo
echo "NOTE: any confirmed secret in history requires (1) immediate rotation and"
echo "      (2) history purge with git-filter-repo or BFG, then force-push coordination."
