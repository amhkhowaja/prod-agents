#!/usr/bin/env bash
# dep-audit.sh — non-destructive dependency vulnerability (CVE) audit.
# Auto-detects ecosystem and runs the native auditor if available.
# Usage: security/dep-audit.sh [path]   (default: current dir)
# Read-only (no installs, no upgrades).
set -uo pipefail
TARGET="${1:-.}"
cd "$TARGET" || { echo "not a path: $TARGET"; exit 1; }

echo "== Dependency / CVE audit: $TARGET =="
found=0

run() { echo; echo "--- $1 ---"; shift; "$@" || true; }

# Node
if [ -f package.json ]; then
  found=1
  if command -v npm >/dev/null 2>&1;  then run "npm audit"  npm audit --omit=dev || true; fi
  if command -v pnpm >/dev/null 2>&1 && [ -f pnpm-lock.yaml ]; then run "pnpm audit" pnpm audit || true; fi
  if command -v yarn >/dev/null 2>&1 && [ -f yarn.lock ];      then run "yarn npm audit" yarn npm audit || true; fi
fi

# Python
if ls requirements*.txt pyproject.toml Pipfile >/dev/null 2>&1; then
  found=1
  if command -v pip-audit >/dev/null 2>&1; then run "pip-audit" pip-audit || true;
  else echo "(install 'pip-audit' for Python CVE scanning)"; fi
fi

# Java / Maven / Gradle
if [ -f pom.xml ]; then
  found=1
  if command -v mvn >/dev/null 2>&1; then run "mvn dependency:tree" mvn -q dependency:tree || true; fi
  echo "(run OWASP Dependency-Check or 'mvn org.owasp:dependency-check-maven:check' for CVEs)"
fi
if ls build.gradle build.gradle.kts >/dev/null 2>&1; then
  found=1
  echo "(add the OWASP dependency-check-gradle plugin and run './gradlew dependencyCheckAnalyze')"
fi

# Go
if [ -f go.mod ]; then
  found=1
  if command -v govulncheck >/dev/null 2>&1; then run "govulncheck" govulncheck ./... || true;
  else echo "(install 'govulncheck' for Go CVE scanning)"; fi
fi

# Rust
if [ -f Cargo.toml ]; then
  found=1
  if command -v cargo-audit >/dev/null 2>&1; then run "cargo audit" cargo audit || true;
  else echo "(install 'cargo-audit' for Rust CVE scanning)"; fi
fi

# Universal fallback: Trivy scans many ecosystems + IaC + images
if command -v trivy >/dev/null 2>&1; then
  run "trivy fs" trivy fs --scanners vuln,secret,misconfig --quiet .
elif [ "$found" -eq 0 ]; then
  echo "No recognized manifest found. Install 'trivy' for a universal scan."
fi

echo
echo "Recommend: generate an SBOM (syft/cyclonedx) and gate CVEs in CI."
