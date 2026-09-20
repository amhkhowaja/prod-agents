# prod-agents

A crew of specialized, senior-level software-engineering AI agents for **extensive
production hardening**. Each agent is a domain expert — a "senior engineer" that
architects (or, where noted, builds and reviews) its domain with an eye on both
**development** and **production** realities: scale, resilience, security, compliance,
and long-term evolution.

The agents are designed for [Kiro CLI](https://github.com/aws/kiro) custom-agent
format (JSON config + prompt file + optional skills/hooks/scripts).

## Philosophy

- **Spec-driven & production-hardened.** Every agent reconstructs requirements/SLOs
  before designing, and always considers dev *and* prod.
- **Architect, not vibes.** Agents justify decisions with explicit tradeoffs and
  produce structured decision documents.
- **Composable crew.** Agents are cross-aware: the System Architect orchestrates the
  domain specialists; the Security and Governance reviewers gate the whole.
- **Least privilege by default.** Pure architects are read-only; the developer agent
  gets scoped write/build tools; reviewers get scoped read-only scan tooling.

## The Crew

### Architects (`agents/architects/`)

| Agent | Role | Mode |
|-------|------|------|
| **senior-system-architect** | Chief architect — orchestrates the crew; turns use-case stories into a full System Architecture Document (decomposition, contracts, consistency, cloud/infra, resilience, observability, delivery, ADRs, risk). | Read-only architect |
| **senior-database-architect** | Data architecture across polyglot stores (SQL, NoSQL, vector, graph, time-series, streaming, search, object); modeling, consistency, RLS, partitioning, migration. | Read-only architect |
| **senior-api-architect** | Contract-first API design (REST, gRPC, GraphQL, WebSocket/SSE, webhooks, event-driven); OpenAPI/AsyncAPI/Protobuf, versioning, resilience, security. | Read-only architect |
| **senior-agentic-architect** | LLM/agent systems — topology & orchestration, memory, RAG/Agentic RAG, tools/MCP, guardrails, evaluation, cost, observability. | Read-only architect |
| **senior-ui-architect** | Frontend architecture — rendering strategy, component system & tokens, state/data-fetching, performance budgets, security, testing. | Read-only architect |
| **senior-ux-architect** | Experience architecture — users & mental models, flows, unhappy-path state design, interaction principles, accessibility. | Read-only architect |
| **senior-springboot-architect** | Java/Spring Boot microservices — Spring Initializr, microservice patterns, concurrency, resilience, persistence, observability, testing. | **Architect + developer** (scoped write/build) |

### Reviewers (`agents/reviewers/`)

| Agent | Role | Mode |
|-------|------|------|
| **senior-security-reviewer** | Security master reviewer — SAST, dependency/CVE, secret & git-history scanning, OWASP Top 10 / API Top 10, authn/authz/RBAC, RLS, encryption/TLS, network hardening, logging/audit. Produces risk-ranked findings. | Read-only + scoped scan scripts |
| **senior-governance-compliance** | GRC architect — maps SOC 2 / ISO 27001 / PCI-DSS / HIPAA / GDPR to engineering controls, data inventory & privacy, vendor risk, audit-readiness. Complements the Security Reviewer. | Read-only + scoped read commands |

Each agent has two files:
- `<name>.json` — the Kiro agent configuration (tools, permissions, resources, skills).
- `<name-with-underscores>.md` — the detailed system prompt / role specification.

## Skills (`agents/skills/`)

Progressively-loaded knowledge modules (`SKILL.md` with YAML frontmatter). Agents load
the skills relevant to their domain; the System Architect loads across domains.

**Spring Boot (6):** `springboot-project-bootstrap`, `springboot-microservice-patterns`,
`springboot-concurrency`, `springboot-resilience`, `springboot-observability`,
`springboot-testing`

**Security (7):** `security-database-review`, `security-api-review`,
`security-production-hardening`, `security-authn-authz-review`,
`security-secrets-and-git-history`, `security-sast-dast-deps`,
`security-compliance-and-audit`

**System (5):** `system-architecture-decisions`, `system-cloud-infrastructure`,
`system-distributed-and-eventing`, `system-cicd-and-deployment`,
`system-observability-and-slo`

**Governance (3):** `governance-control-frameworks`, `governance-data-privacy`,
`governance-vendor-and-audit-readiness`

## Scripts (`agents/scripts/`)

Reusable, **non-destructive** shell scripts used by the Security Reviewer. Each prefers
a real tool if installed and falls back to redacted regex, degrading gracefully.

- `security/secret-scan.sh` — secret exposure in the working tree (gitleaks/trufflehog → regex fallback).
- `security/git-history-scan.sh` — full git-history secret sweep (secrets deleted from HEAD still live in history).
- `security/dep-audit.sh` — dependency/CVE audit across npm/pip/Maven/Gradle/Go/Cargo (+ trivy fallback).
- `security/sast-scan.sh` — static analysis (semgrep OWASP rulesets → dangerous-pattern grep fallback).

## Repository Layout

```
prompts/                     # source considerations for each agent (input notes)
agents/
├── architects/              # architect agents: <name>.json + <name>.md
├── reviewers/               # reviewer agents: <name>.json + <name>.md
├── skills/                  # progressively-loaded SKILL.md knowledge modules
│   ├── springboot-*/
│   ├── security-*/
│   ├── system-*/
│   └── governance-*/
└── scripts/
    └── security/            # non-destructive scan scripts
```

## Using the Agents with Kiro CLI

Kiro discovers custom agents in `.kiro/agents/` (workspace) or `~/.kiro/agents/`
(global). The `file://` and `skill://` paths in each config resolve **relative to the
config file's own directory**.

**Validate a config:**
```bash
kiro-cli agent validate --path agents/architects/senior-system-architect.json
```

**Make an agent discoverable** (workspace), e.g. by symlinking a config into
`.kiro/agents/` (keep it alongside its prompt/skills, or adjust the relative paths):
```bash
mkdir -p .kiro/agents
ln -s "$(pwd)/agents/architects/senior-system-architect.json" .kiro/agents/
```

**Switch to an agent in a chat session:**
```
/agent senior-system-architect
```

> Note: because paths are relative to the config's directory, keep each config next to
> its prompt/skills or update the paths when relocating it.

## How the Crew Composes

1. **System Architect** frames use cases → SLOs → risk, decomposes the system into
   bounded contexts, and assigns each to a specialist.
2. **Domain architects** (database, API, agentic, UI, UX) design their contexts.
3. **Spring Boot Architect & Developer** implements backend services against those
   designs and verifies with the build.
4. **Security Reviewer** gates the result with non-destructive scans and risk-ranked
   findings.
5. **Governance & Compliance Architect** maps controls, evidences them, and drives
   audit-readiness — consuming the security findings as evidence.

## Contributing

New agents follow the established pattern:
- A `prompts/<domain>.txt` with the key considerations (input).
- A detailed `<name>.md` role spec (spec-driven, dev + prod, explicit tradeoffs,
  a standard deliverable format, and a Boundaries section).
- A `<name>.json` config with least-privilege tools, cross-references to sibling
  specs, and any relevant `skill://` modules.
- Validate with `kiro-cli agent validate` before committing.
