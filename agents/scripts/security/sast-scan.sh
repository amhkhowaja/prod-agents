#!/usr/bin/env bash
# sast-scan.sh — non-destructive static analysis. Prefers semgrep with OWASP rulesets.
# Usage: security/sast-scan.sh [path]   (default: current dir)
# Read-only.
set -uo pipefail
TARGET="${1:-.}"

echo "== SAST scan: $TARGET =="

if command -v semgrep >/dev/null 2>&1; then
  echo "[tool] semgrep (auto + owasp-top-ten)"
  semgrep --config auto --config "p/owasp-top-ten" --error --quiet "$TARGET" || true
  exit 0
fi

if command -v trivy >/dev/null 2>&1; then
  echo "[tool] trivy misconfig/secret (no semgrep found)"
  trivy fs --scanners misconfig,secret --quiet "$TARGET" || true
  exit 0
fi

echo "[fallback] high-signal dangerous-pattern grep (install semgrep for real SAST)"
echo
echo "--- possible injection: string-built SQL ---"
grep -rInE "(execute|query|createQuery|rawQuery)\s*\(.*\+|f\"(SELECT|INSERT|UPDATE|DELETE)" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target "$TARGET" 2>/dev/null | head -50 || true
echo
echo "--- command execution sinks ---"
grep -rInE "(Runtime\.getRuntime|ProcessBuilder|os\.system|subprocess\.(call|Popen)|child_process\.exec|eval\()" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target "$TARGET" 2>/dev/null | head -50 || true
echo
echo "--- XSS / dangerous DOM sinks ---"
grep -rInE "(dangerouslySetInnerHTML|innerHTML\s*=|v-html|document\.write\()" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target "$TARGET" 2>/dev/null | head -50 || true
echo
echo "--- weak crypto / insecure random ---"
grep -rInE "(MD5|SHA1|DES|ECB|Math\.random\(\)|new Random\()" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target "$TARGET" 2>/dev/null | head -50 || true
echo
echo "--- insecure transport / disabled verification ---"
grep -rInE "(http://|verify=False|InsecureSkipVerify|TrustAllCerts|CURLOPT_SSL_VERIFYPEER.*0)" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target "$TARGET" 2>/dev/null | head -50 || true
echo
echo "NOTE: grep fallback is indicative only. Confirm reachability/exploitability before reporting."
