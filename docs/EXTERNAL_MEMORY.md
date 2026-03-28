# Work OS — Personal AI Context System

A personal AI operating system — a structured, persistent context layer that makes every AI tool aware of who you are, what you know, how you work, and what you've learned. Portable across any AI tool, compounding over time.

```
Work OS = identity + knowledge + learned context + active projects + skill memory
```

The org layer plugs in later as a submodule. For now, this is personal.

## Goals

1. **Persistent context** — full context available for every AI chat/agent session
2. **Two-way memory** — AI reads and writes back, knowledge compounds over time
3. **Persistent skill context** — skills reference and auto-update shared knowledge
4. **Cross-tool** — same memory across Claude Code, Copilot, Copilot CLI, custom agents
5. **Org-ready** — structured so a team/org layer can plug in without restructuring

## Usage Flow

1. User initiates AI task
2. AI tool reads AGENTS.md/CLAUDE.md — contains instructions to read external context
3. AI reads `~/.ai-context/ROUTER.md` — routes to relevant knowledge files
4. AI reads/updates specific context files as needed
5. Context informs the AI agent's task execution
6. AI writes back to `learned/` or `skills/` if something new was discovered

## Current State (What Exists Today)

| Layer | Where | Gap |
|-------|-------|-----|
| Personal skills + hooks | `ai-files/` | Logs sessions but doesn't write structured knowledge |
| Org skills + agents | `fastpass-ai/` (submodule) | `context/` dirs are repo-specific customization, not shared knowledge |
| Machine config | `work-machine-assistant/` | Config only, no knowledge |
| Claude Code memory | `.claude/projects/*/memory/` | Per-project, per-tool, not shareable |
| Session telemetry | `~/.claude/workflow-log-auto.jsonl` | Raw JSONL, not structured knowledge |
| Obsidian vault | `obsidian-vaults/work/` | Rich notes organized by employer/project, but not AI-accessible or structured for retrieval |

## Assessment

### Pros

- Immediate value from day 1 — AI knows your role, tools, org patterns, and past learnings
- Zero infrastructure — markdown files + git
- Works across Claude Code, Copilot, Copilot CLI, any future tool
- Obsidian as a free UI for browsing and editing
- Builds on what already exists (vault content, hooks, skills, AGENTS.md routing)
- Org layer plugs in later without restructuring

### Cons

- Manual maintenance until automation is built — you're the curator
- Context window cost per session (ROUTER.md + 2-3 files = ~2-3K tokens)
- Cold start — only as useful as what you seed it with
- Discipline required to capture inbox notes consistently

### Alternatives Considered

**1. Expand existing Claude Code memory** — Make `.claude/projects/*/memory/` smarter via hooks and `additionalDirectories`. Simpler but tool-specific, no cross-tool support, doesn't scale.

**2. MCP server as memory layer** — Build `memory_search(query)` / `memory_store(content)` tools. Cleaner AI integration with semantic search, but adds infrastructure (server, embeddings) and loses Obsidian-as-UI.

**3. RAG over existing org docs** — Index Confluence, runbook repos, incident postmortems into vector store. Leverages existing content but RAG quality depends on source quality, and requires infrastructure.

**4. Expand fastpass-ai context layer** — Grow `sidekicks/*/context/` into a full knowledge system. Zero new infra, rides existing governance, but tightly coupled to sidekick model and no personal tier.

**5. (Chosen) Filesystem repo + future automation** — Start with structured markdown, add consolidation pipeline based on real usage data. Immediate value, minimal build, org-ready when needed.

---

## Directory Structure

Standalone git repo at `~/.ai-context/`, symlinked from the actual repo location. Obsidian opens this directory as a vault for authoring/browsing. Underscore-prefixed folders (`_config/`, `_inbox/`, `_archive/`) sort to top in Obsidian and signal "system" directories.

```
~/.ai-context/                          # Standalone git repo, Obsidian vault
├── .obsidian/                          # Obsidian config (auto-generated)
│
├── ROUTER.md                           # AI entry point — index of everything
│
├── _config/                            # Pipeline config
│   ├── consolidation-rules.md          # Promote/merge/discard/archive rubric
│   ├── consolidation-log.jsonl         # Audit trail of all decisions
│   ├── sources.md                      # Where raw data lives
│   └── templates/                      # Obsidian + AI templates (hotkey insert)
│       ├── incident.md                 # Symptoms/root-cause/fix/prevention
│       ├── meeting.md                  # Decisions/impact/action-items
│       ├── decision.md                 # Context/options/rationale/consequences
│       └── capture.md                  # Quick freeform capture
│
├── _inbox/                             # Short-term staging (AI + human writes)
│   ├── notes/                          # Manual notes (standup, meetings, ad-hoc)
│   ├── captures/                       # Skill/hook captures (incidents, gotchas)
│   └── references/                     # Links, docs, architecture diagrams
│
├── _archive/                           # Stale/superseded content (auto-moved)
│
├── identity/                           # About you (manual, stable)
│   ├── role.md                         # Platform/infra engineer, GCP + AWS
│   ├── preferences.md                  # AI interaction style, output format
│   └── tools.md                        # Access: EKS, ArgoCD, Octopus, Observe, etc.
│
├── learned/                            # AI-maintained, two-way writes
│   ├── corrections.md                  # Things AI got wrong, now knows
│   ├── discoveries.md                  # Non-obvious solutions found during sessions
│   └── tool-quirks.md                  # Gotchas with specific tools/APIs
│
├── knowledge/                          # Long-term curated knowledge
│   ├── runbooks/                       # How to do things
│   │   ├── eks-troubleshooting.md
│   │   ├── argocd-recovery.md
│   │   ├── deploy-checklist.md
│   │   └── incident-response.md
│   ├── patterns/                       # Proven approaches, reusable
│   │   ├── argocd-app-of-apps.md
│   │   ├── helm-chart-structure.md
│   │   ├── octopus-k8s-steps.md
│   │   ├── docker-artifactory-mirror.md
│   │   └── opa-policy-patterns.md
│   ├── decisions/                      # ADRs — why we chose X over Y
│   │   ├── weekly/                     # Weekly rollup summaries
│   │   └── 2026-03-otel-over-datadog.md
│   ├── domain/                         # Org/business knowledge
│   │   ├── service-catalog.md          # Services, owners, endpoints
│   │   ├── team-ownership.md           # Who owns what
│   │   └── environment-map.md          # Clusters, regions, env topology
│   └── reference/                      # Tool/CLI cheat sheets, API notes
│       ├── kubectl.md
│       ├── gcloud.md
│       ├── argocd-cli.md
│       ├── terraform.md
│       └── octopus-api.md
│
├── skills/                             # Skill-specific persistent context
│   ├── eks-troubleshooting/
│   │   ├── known-failures.md           # Accumulates over time
│   │   └── cluster-specifics.md        # Environment details
│   ├── deploy-verification/
│   │   └── endpoint-registry.md        # Known endpoints per service
│   └── argocd-operations/
│       └── known-issues.md             # ArgoCD-specific gotchas
│
├── projects/                           # Active project/initiative context
│   ├── kong-to-envoy-migration/
│   │   └── notes.md
│   └── fastpass-ai/
│       └── notes.md
│
├── attachments/                        # Images, diagrams, screenshots
│
├── team/ → submodule                   # Team layer (future)
└── org/ → submodule                    # Org layer (future)
```

### Key structural decisions

**`knowledge/` vs `projects/`** — Knowledge is evergreen and survives project completion or job changes ("how ArgoCD app-of-apps works"). Projects are time-bound initiatives with a start/end ("Kong to Envoy migration"). When a project ends, useful bits get promoted to `knowledge/`, the rest goes to `_archive/`.

**`knowledge/reference/`** — Tool and CLI cheat sheets (kubectl, gcloud, terraform, argocd-cli). A content type naturally produced based on existing Obsidian vault patterns. AI agents frequently need these during troubleshooting and implementation tasks.

**`_config/templates/`** — Obsidian's template plugin inserts from this folder via hotkey. Templates for incidents, meetings, decisions, and quick captures reduce friction for manual inbox entries.

**`attachments/`** — Obsidian convention for images and diagrams. Configure Obsidian to auto-place new attachments here. Architecture diagrams are high-value context for AI agents.

**Underscore prefix** — `_config/`, `_inbox/`, `_archive/` sort to top in Obsidian's file explorer and visually separate system directories from content directories.

### Obsidian compatibility

**Frontmatter properties** — Obsidian renders these natively in the sidebar:
```markdown
---
title: EKS Troubleshooting Runbook
created: 2026-03-15
last_referenced: 2026-03-27
reference_count: 12
tags: [runbook, eks, kubernetes]
---
```

**Tags** — cross-cutting concerns that span folders:
- `#runbook`, `#pattern`, `#decision` — content type
- `#eks`, `#argocd`, `#cicd` — topic
- `#active`, `#stale`, `#archived` — lifecycle

**Wiki links** — `[[argocd]]` links across folders. The consolidation agent can use these too — if a new file references `[[payment-service]]`, it signals a relationship.

**Graph view** — Obsidian's graph view becomes a visual map of your knowledge. Links between project notes and knowledge patterns show up as connections.

### Symlink for AI tool access

The repo lives at its actual git location but is symlinked for easy reference:

```bash
ln -s ~/Dev/git/albertagustin/ai-context ~/.ai-context
```

Skills and instruction files reference `~/.ai-context/ROUTER.md` without caring where the repo physically lives.

## ROUTER.md (The Entry Point)

`ROUTER.md` is the key file every AI reads first. It replaces hardcoded paths with a topic-based lookup:

```markdown
# External Context Router

This directory is persistent external memory. Read this file to find
relevant context for your current task. Update files here when you
learn something that would be useful in future sessions.

## How to use this context

1. Identify what your current task needs (troubleshooting? deployment?
   code review? new feature?)
2. Scan the index below for relevant entries
3. Read only what's relevant — don't load everything
4. After completing a task, update learned/ if you discovered
   something non-obvious

## Index

### Identity & Preferences
| File | When to read |
|------|-------------|
| identity/role.md | Start of any session (understand who you're helping) |
| identity/preferences.md | When formatting output or choosing approach |
| identity/tools.md | When you need to know what's available |

### Knowledge Base
| File | When to read |
|------|-------------|
| knowledge/runbooks/eks-troubleshooting.md | EKS pod/node issues |
| knowledge/runbooks/argocd-recovery.md | ArgoCD sync failures, stuck apps |
| knowledge/runbooks/deploy-checklist.md | Before or during deployments |
| knowledge/runbooks/incident-response.md | Investigating production issues |
| knowledge/patterns/argocd-app-of-apps.md | ArgoCD multi-app patterns |
| knowledge/patterns/helm-chart-structure.md | Helm chart work |
| knowledge/patterns/octopus-k8s-steps.md | Octopus Deploy + Kubernetes |
| knowledge/patterns/docker-artifactory-mirror.md | Docker image sourcing |
| knowledge/patterns/opa-policy-patterns.md | OPA/Rego policy work |
| knowledge/domain/service-catalog.md | Need to know what services exist |
| knowledge/domain/team-ownership.md | Need to know who owns what |
| knowledge/domain/environment-map.md | Cluster/region/env topology |
| knowledge/reference/kubectl.md | kubectl commands and flags |
| knowledge/reference/gcloud.md | GCP CLI operations |
| knowledge/reference/argocd-cli.md | ArgoCD CLI operations |
| knowledge/reference/terraform.md | Terraform commands and patterns |
| knowledge/reference/octopus-api.md | Octopus Deploy API calls |

### Learned (AI-maintained)
| File | When to read | When to update |
|------|-------------|----------------|
| learned/corrections.md | Before assuming approach | When corrected by user |
| learned/discoveries.md | When stuck on a problem | When you find a non-obvious solution |
| learned/tool-quirks.md | When using external tools | When a tool behaves unexpectedly |

### Skill Context (persistent across sessions)
| Directory | Linked skill |
|-----------|-------------|
| skills/eks-troubleshooting/ | eks-troubleshooting skill |
| skills/deploy-verification/ | post-deploy-verification skill |
| skills/argocd-operations/ | argocd-operations skill |

### Active Projects
| Directory | What |
|-----------|------|
| projects/kong-to-envoy-migration/ | API gateway migration (Q3 2026) |
| projects/fastpass-ai/ | AI workflow orchestration rollout |

## Team & Org Context
- For team-specific knowledge: read team/ROUTER.md
- For org standards and compliance: read org/ROUTER.md
```

## Integration Points

### 1. AGENTS.md / CLAUDE.md (per-repo routing)

Every repo's instruction file gets one block:

```markdown
## External Context (Work OS)

Read ~/.ai-context/ROUTER.md for persistent external memory.
Check relevant knowledge files before starting tasks involving
troubleshooting, deployment, architecture, or tool usage.
Update ~/.ai-context/learned/ when you discover something non-obvious.
```

### 2. Skills reference external context

In a SKILL.md:

```markdown
## Gather context
1. Read ~/.ai-context/skills/eks-troubleshooting/known-failures.md
   for previously encountered failure modes
2. Read ~/.ai-context/knowledge/domain/service-catalog.md
   if you need to identify the service owner

## After resolution
Append the failure mode and fix to
~/.ai-context/skills/eks-troubleshooting/known-failures.md
if this was a new pattern.
```

### 3. Hooks auto-populate context

The existing `workflow-autolog.sh` Stop hook can be extended — when pain signals are detected, instead of just writing JSONL, it can also append a structured entry to the relevant `learned/` file.

### 4. Cross-tool compatibility

| Tool | How it reads | How it writes |
|------|-------------|---------------|
| Claude Code | `Read` tool + CLAUDE.md routing | `Edit`/`Write` tool |
| Copilot (VS Code) | `#file` references + agents.md routing | Edit via agent |
| Copilot CLI | File reads + AGENTS.md routing | File writes |
| Custom scripts | `cat` / `grep` | `echo >>` / `sed` |

No MCP server needed for Phase 1. The filesystem IS the protocol.

## Scaling: Personal to Team to Org

```
~/.ai-context/                    # Personal (your repo)
├── team/ → submodule             # Team layer (shared repo)
│   ├── ROUTER.md                 # Team-specific routing
│   ├── runbooks/                 # Team runbooks
│   ├── services/                 # Team service catalog
│   └── conventions/              # Team coding standards
└── org/ → submodule              # Org layer (e.g. fastpass-ai/context)
    ├── ROUTER.md
    ├── compliance/
    ├── architecture/
    └── standards/
```

Each layer has its own ROUTER.md. The personal ROUTER.md points to team and org layers. This mirrors how fastpass-ai already distributes skills via submodules — same pattern applied to knowledge.

## Comparison: Claude Code Memory vs Work OS

| | Claude Code Memory | Work OS |
|---|---|---|
| Scope | Per-project, per-tool | Global, any tool |
| Persistence | Tool-managed, opaque | Git-tracked, auditable |
| Structure | Flat key-value files | Hierarchical, topic-based |
| Two-way | Claude writes MEMORY.md | Any AI writes learned/ |
| Team sharing | Not shareable | Git submodule overlay |
| Skill integration | None | Skills read/write specific files |
| Versioning | No history | Full git history |
| Browsing | No UI | Obsidian as visual frontend |

## Risks and Mitigations

### Staleness
`learned/` files will accumulate cruft. Add `last_verified` frontmatter and a periodic review skill that flags stale entries.

### Noise in two-way writes
AI will want to write everything. ROUTER.md needs clear "only write if X" criteria — only non-obvious discoveries, only corrections that would affect future sessions.

### Context window budget
See [Context Window Analysis](#context-window-analysis) below for detailed token estimates. At MVP scale, Work OS uses ~2-3% of a 200K window per session — negligible. The main mitigation is ensuring AI follows ROUTER.md routing and only loads what's relevant, rather than reading everything "just in case."

### Merge conflicts at team scale
Multiple people's AIs writing to the same files. Solution: personal `learned/` stays personal, team `learned/` uses append-only format or per-person subdirectories.

### Obsidian as frontend
Obsidian is optional — it's a convenient authoring UI for the markdown vault. The system has zero dependency on it. Any editor or tool that reads markdown works.

---

## Context Window Analysis

Token cost estimates for Work OS context across different task types. Based on the dry run activities and a medium-effort agentic workflow (Jira ticket → branch → implement → PR).

### Per-file token estimates

| File | Estimated size | Tokens |
|------|---------------|--------|
| **Always loaded** | | |
| ROUTER.md | ~80 lines, tables + index | ~1,000 |
| **Identity (loaded when relevant)** | | |
| identity/role.md | ~20 lines | ~250 |
| identity/preferences.md | ~15 lines | ~200 |
| identity/tools.md | ~30 lines | ~350 |
| **Knowledge** | | |
| knowledge/domain/service-catalog.md | ~100 lines (10-15 services) | ~1,200 |
| knowledge/patterns/helm-chart-structure.md | ~60 lines | ~700 |
| knowledge/patterns/argocd-app-of-apps.md | ~40 lines | ~500 |
| knowledge/patterns/docker-artifactory-mirror.md | ~30 lines | ~350 |
| knowledge/runbooks/incident-response.md | ~60 lines | ~700 |
| knowledge/runbooks/deploy-checklist.md | ~50 lines | ~600 |
| knowledge/domain/environment-map.md | ~80 lines | ~1,000 |
| knowledge/reference/octopus-api.md | ~80 lines | ~900 |
| **Learned** | | |
| learned/tool-quirks.md | ~30 lines (after a few weeks) | ~350 |
| learned/discoveries.md | ~30 lines | ~350 |
| **Skills** | | |
| skills/argocd-operations/known-issues.md | ~20 lines | ~250 |
| skills/eks-troubleshooting/known-failures.md | ~30 lines | ~350 |

### Per-activity cost (from dry run)

| Activity | Files read | Work OS tokens | % of 200K |
|----------|-----------|---------------|-----------|
| Dev work | ROUTER + service-catalog + helm-patterns + argocd + tool-quirks + known-issues | ~4,600 | 2.3% |
| Incident investigation | ROUTER + incident-response + service-catalog + discoveries + deploy-checklist | ~3,850 | 1.9% |
| Architecture meeting | ROUTER + environment-map + decisions/ | ~2,200 | 1.1% |
| CI/CD admin | ROUTER + docker-mirror + repo-onboarding + octopus-api | ~2,550 | 1.3% |

### Medium-effort agentic workflow: full context budget

Task: "Pick up CD-2891, migrate payment-service Helm chart to ArgoCD app-of-apps, open PR."

| Layer | Tokens | % of total used | Notes |
|-------|--------|----------------|-------|
| System overhead | ~11,500 | 27% | System prompt, tool definitions, MCP tool schemas, CLAUDE.md |
| **Work OS reads** | **~4,600** | **11%** | ROUTER.md + 4-5 knowledge/learned files |
| Skill context | ~2,700 | 6% | SKILL.md for jira-to-branch, copilot-pr-review |
| MCP tool responses | ~3,800 | 9% | Jira ticket, Atlas service details, Octopus config |
| Codebase reads | ~7,000 | 16% | Helm chart files, ArgoCD manifests, CI config |
| Conversation | ~10,500 | 24% | Agent reasoning, user prompts, responses, tool outputs |
| PR creation | ~2,800 | 7% | git diff, git log, PR body |
| **Total used** | **~42,900** | | |
| **Remaining** | **~157,100** | | 78.5% of 200K still available |

```
200K context window:

Used (~43K)                              Available (~157K)
├──────────────────────┤─────────────────────────────────────────────────┤
 System    Work  Skill MCP  Code   Convo  PR
 (11.5K)  OS    (2.7) (3.8)(7.0K) (10.5) (2.8)
          (4.6K)
```

### Scaling with task complexity

| Task type | Total context | Work OS tokens | Work OS % of total | Headroom |
|-----------|---------------|---------------|-------------------|----------|
| Quick fix (1 file, edit, commit) | ~20K | ~2,500 | 12% | 90% of 200K |
| Medium agentic (this example) | ~43K | ~4,600 | 11% | 78% of 200K |
| Large refactor (20+ files, multi-skill) | ~80K | ~6,000 | 8% | 60% of 200K |
| Multi-repo coordination (3 repos) | ~100K | ~8,000 | 8% | 50% of 200K |
| Extended debugging (30+ messages) | ~120K | ~5,000 | 4% | 40% of 200K |

Work OS is a **fixed cost** that doesn't scale with task complexity. Codebase reads and conversation history are what grow. For longer sessions, Work OS becomes a smaller percentage as other layers dominate.

### Growth over time

| File | Day 1 | Month 6 | Notes |
|------|-------|---------|-------|
| ROUTER.md | 1,000 | 2,500 | Index grows as files are added |
| service-catalog.md | 1,200 | 3,000 | More services documented |
| learned/discoveries.md | 350 | 2,000 | Accumulates entries |
| learned/tool-quirks.md | 350 | 1,500 | Accumulates entries |
| knowledge/runbooks/*.md | 700 avg | 1,500 avg | More detail per runbook |

A 6-month session could cost ~8,000-10,000 tokens for Work OS instead of ~4,600. Still under 5% of 200K. The `learned/` files need periodic pruning — they're the main growth risk.

### Mitigations

1. **Keep files concise** — target 50-80 lines max per file. Runbooks should be checklists, not novels.
2. **Split large files** — if `service-catalog.md` hits 200 lines, split by domain (payments, platform, identity). ROUTER.md routes to the right one.
3. **Prune learned/** — monthly review, archive entries older than 90 days with low reference counts.
4. **ROUTER.md diet** — if index exceeds ~150 lines, switch to category-level routing ("read `knowledge/runbooks/` for troubleshooting") instead of listing every file.
5. **Route, don't dump** — the routing block in CLAUDE.md/AGENTS.md should say "read only what's relevant to the current task" not "read all context at session start."

---

## MVP: 2-Day Build Plan

Get a working Work OS with zero automation — just the structure, seed content, and AI tool wiring. Automation comes later based on real usage data.

### What the MVP includes

- Git repo with full directory structure
- ROUTER.md with initial index
- Identity files (role, preferences, tools)
- 8-10 knowledge files seeded from Obsidian vault
- Learned stubs (empty, ready for AI writes)
- Obsidian vault config (templates, attachments folder)
- Routing wired into CLAUDE.md / AGENTS.md in key repos
- 2-3 skills updated to reference Work OS
- `/remember` skill for fast inbox captures

### What the MVP skips

- Consolidation pipeline (no scheduled agents)
- Reference counting (no Stop hook extensions)
- Auto-merge PRs (just commit to main)
- Weekly summaries
- Team/org submodules
- `_archive/` workflow

These come after 2-3 weeks of usage data showing what's actually valuable.

### Day 1: Structure + Seed

**Morning (2-3 hrs): Create the repo and skeleton**

1. Create the repo and symlink:
```bash
mkdir -p ~/Dev/git/albertagustin/ai-context
cd ~/Dev/git/albertagustin/ai-context
git init
ln -s ~/Dev/git/albertagustin/ai-context ~/.ai-context
```

2. Create directory skeleton:
```
_config/templates/
_inbox/notes/
_inbox/captures/
_inbox/references/
identity/
knowledge/runbooks/
knowledge/patterns/
knowledge/decisions/
knowledge/domain/
knowledge/reference/
learned/
skills/
projects/
attachments/
```

3. Write `ROUTER.md` — start with just the files you actually seed

4. Write identity files:
   - `identity/role.md` — platform/infra engineer, GCP + AWS, teams you support
   - `identity/preferences.md` — AI interaction style (terse, no emojis, etc.)
   - `identity/tools.md` — what you have access to (EKS, ArgoCD, Octopus, Observe, Jira, MCP servers)

5. Write `learned/` stubs:
   - `learned/corrections.md` — empty with header explaining when to add
   - `learned/discoveries.md` — same
   - `learned/tool-quirks.md` — same

6. Create templates in `_config/templates/`:
   - `capture.md` — quick freeform (date, source, freeform body)
   - `incident.md` — symptoms / root cause / fix / prevention
   - `meeting.md` — decisions / impact / action items
   - `decision.md` — context / options / rationale / consequences

7. Open folder as Obsidian vault, configure attachments → `attachments/`, templates → `_config/templates/`

**Afternoon (2-3 hrs): Seed from Obsidian vault**

Migrate the highest-value content from `obsidian-vaults/work/`:

| Source | Destination | Action |
|--------|------------|--------|
| `backcountry/kubernetes/argocd.md` + `prog-leasing/ci-cd/argo-cd/*.md` | `knowledge/patterns/argocd.md` | Merge, keep universal parts |
| `backcountry/kubernetes/kubectl.md` | `knowledge/reference/kubectl.md` | Copy, clean up |
| `backcountry/cloud/gcloud.md` | `knowledge/reference/gcloud.md` | Copy, clean up |
| `prog-leasing/platform/kubernetes/*.md` | `knowledge/patterns/` and `knowledge/runbooks/` | Split by type |
| `prog-leasing/observability/Dynatrace.md` | `knowledge/reference/dynatrace.md` | Copy, clean up |
| `prog-leasing/ci-cd/circle-ci/*.md` | `knowledge/reference/circleci.md` | Copy, clean up |
| `prog-leasing/fastpass/architecture.md` | `projects/fastpass-ai/architecture.md` | Copy |
| `prog-leasing/incidents/` | `knowledge/runbooks/` | Extract patterns |
| `backcountry/observability/*.md` | `knowledge/reference/` | Monitoring tool refs |

**Don't migrate:** temp-notes, story-specific working notes, employer-specific configs no longer relevant, binary files.

Update ROUTER.md index as you add each file.

### Day 2: Wire + Test

**Morning (2-3 hrs): Connect AI tools**

1. Add `~/.ai-context` as an additional directory in Claude Code settings

2. Add routing block to CLAUDE.md / AGENTS.md in key repos (work-machine-assistant, ai-files):
```markdown
## External Context (Work OS)

Read ~/.ai-context/ROUTER.md for persistent external memory.
Check relevant knowledge files before starting tasks involving
troubleshooting, deployment, architecture, or tool usage.
Update ~/.ai-context/learned/ when you discover something non-obvious.
```

3. Update 2-3 most-used skills to reference Work OS:
   - `eks-troubleshooting` — read `skills/eks-troubleshooting/known-failures.md` + `knowledge/runbooks/eks-troubleshooting.md`
   - `jira-to-branch` — read `knowledge/domain/service-catalog.md` for service context
   - `post-deploy-verification` — read `skills/deploy-verification/endpoint-registry.md`

4. Build a minimal `/remember` skill:
   - Takes freeform text as input
   - Writes to `_inbox/captures/<date>-<slug>.md` with auto-generated frontmatter
   - Example: `/remember ArgoCD managed-by annotation must point to parent app name`

**Afternoon (2-3 hrs): Test with real work**

Do normal work, pay attention to:
- Does the AI read ROUTER.md and use the context?
- When it reads `knowledge/reference/kubectl.md`, does it give better answers?
- When it reads `identity/tools.md`, does it know what MCP servers you have?
- Is `/remember` fast enough for mid-task captures?
- Drop a note in `_inbox/notes/` after a meeting — does it feel natural?

Fix what doesn't work. Add files you wish existed. Update ROUTER.md.

**End of day 2:** Commit everything, push to GitHub. Working Work OS.

---

## Memory Consolidation Pipeline (Future)

Two designs for automating the inbox → long-term promotion. Build after 2-3 weeks of manual usage.

---

### Design A: Branch-Based Pipeline (Original)

Uses git feature branches as short-term memory buffers. Each data source writes to its own branch, and a daily consolidation agent merges them into long-term memory via PR.

#### Data flow

```
Throughout day:
  ├── Hooks write to workflow-log-auto.jsonl (exists today)
  ├── User adds notes/references ad-hoc
  └── Skills write captures to short-term branches

4:00 PM — Scheduled "Collector" agent:
  ├── Reads today's JSONL entries
  ├── Reads any manual notes/captures
  ├── Summarizes sessions, extracts pain signals & discoveries
  ├── Writes structured short-term memory files:
  │     short-term/
  │     └── 2026-03-27/
  │         ├── sessions.md
  │         ├── notes.md
  │         ├── pain-signals.md
  │         └── discoveries.md
  └── Pushes branch: 2026-03-27/daily-capture

Ad-hoc additions (any time):
  └── Push to branch: 2026-03-27/<short-description>

5:00 PM — Scheduled "Consolidation" agent:
  ├── Checks out all 2026-03-27/* branches
  ├── Reads short-term files from each
  ├── Reads current long-term context (main branch)
  ├── Applies consolidation rules (promote/merge/discard)
  ├── Updates long-term files on a new branch
  ├── Removes processed short-term files
  └── Opens PR: "Memory consolidation — 2026-03-27"
        Body: what was promoted, what was discarded, why

Auto-merge if:
  ├── No conflicts
  └── All changes are append-only

Next morning:
  └── git pull main (or scheduled agent does this)
```

#### Branch naming convention

| Source | Branch pattern | Example |
|--------|---------------|---------|
| Daily collector | `<DATE>/daily-capture` | `2026-03-27/daily-capture` |
| Ad-hoc additions | `<DATE>/<short-description>` | `2026-03-27/manual-eks-runbook` |
| Consolidation output | `memory/<DATE>` | `memory/2026-03-27` |

#### Strengths

- Each addition is atomic and traceable (one branch per source)
- Consolidation has clear inputs (all branches matching `<DATE>/*`)
- Natural audit trail via branch history
- Scales to team use — multiple people can push to their own branches without conflict

#### Concerns

- Branch management overhead — creating, checking out, merging multiple branches daily
- Two scheduled agents adds coordination complexity
- Short-term files are an intermediate format the consolidator re-reads
- Need to handle multi-day gaps (weekends, holidays)
- Stale PRs can block subsequent consolidation runs

---

### Design B: Inbox Pipeline (Recommended)

Uses a simple inbox directory as the short-term buffer. A single daily agent reads all raw sources directly and goes straight to consolidation decisions. No intermediate branches or files for ingestion.

#### Key differences from Design A

| | Design A (Branches) | Design B (Inbox) |
|---|---|---|
| Short-term buffer | Feature branches per addition | `_inbox/` directory on main |
| Processing | Two agents (collector + consolidator) | One agent, single pass |
| Cleanup | Delete short-term files | Stamp as processed, weekly cleanup |
| Prioritization | Agent guesses what matters | Reference counting drives decisions |
| Tuning | Change agent prompt | Edit `consolidation-rules.md` |
| Audit | PR body only | PR body + `consolidation-log.jsonl` |
| Staleness | Manual review | Auto-archive at low reference count |

#### Data flow

```
Throughout day:
  ├── Stop hooks → workflow-log-auto.jsonl (exists today)
  ├── User drops notes → _inbox/notes/
  ├── Skills write captures → _inbox/captures/
  └── Manual references → _inbox/references/

5:00 PM — Memory Agent (single scheduled run):
  ├── Read raw sources:
  │   ├── Today's entries from workflow-log-auto.jsonl
  │   ├── _inbox/ directory (notes, captures, references)
  │   └── Any other manual additions
  │
  ├── Read current state:
  │   ├── ROUTER.md (index of what exists)
  │   ├── _config/consolidation-rules.md (rubric)
  │   └── Reference counts from recent sessions
  │
  ├── For each item, apply rubric:
  │   ├── PROMOTE → new file or append to existing long-term file
  │   ├── MERGE → update existing file with new detail
  │   ├── DISCARD → log reason, skip
  │   └── ARCHIVE → move stale long-term file to _archive/
  │
  ├── Mark inbox items as processed (don't delete yet)
  ├── Update ROUTER.md index if files added/removed
  ├── Update reference counts from today's sessions
  ├── Log all decisions → _config/consolidation-log.jsonl
  │
  ├── Create branch: memory/2026-03-27
  ├── Open PR:
  │     ## Promoted (N items)
  │     ## Merged (N items)
  │     ## Discarded (N items, with reasons)
  │     ## Archived (N items, low reference count)
  │
  └── Auto-merge if:
      ├── All changes are append-only or new files
      └── No modifications to existing long-term content
      (Otherwise: leave for human review)

Morning:
  └── git pull main (or SessionStart hook does this)

Weekly:
  └── Cleanup _inbox/ items with status: processed older than 7 days
```

#### Reference tracking

Every long-term file includes frontmatter for usage tracking:

```markdown
---
title: EKS Troubleshooting Runbook
created: 2026-03-15
last_referenced: 2026-03-27
reference_count: 12
last_updated: 2026-03-22
tags: [runbook, eks, kubernetes]
---
```

The Stop hook logs which context files were read during each session. The memory agent uses this to:
- **Promote aggressively** — inbox items related to frequently-referenced topics
- **Archive** — long-term files not referenced in 30+ days move to `_archive/`
- **Merge** — files always referenced together get combined

#### Consolidation rules

Stored in `_config/consolidation-rules.md` — editable markdown, not hardcoded logic:

```markdown
## Consolidation Rules

### PROMOTE to long-term if:
- A failure mode was encountered and resolved
  → knowledge/runbooks/ or skills/*/known-failures.md
- A tool/API behaved unexpectedly and a workaround was found
  → learned/tool-quirks.md
- A decision was made with rationale
  → knowledge/decisions/
- A new service/endpoint/team-ownership was discovered
  → knowledge/domain/
- User explicitly corrected the AI's approach
  → learned/corrections.md
- A CLI command or API pattern was documented
  → knowledge/reference/

### MERGE with existing if:
- An existing runbook covers the same topic but new info adds detail
- A known-failures file has the service but not this failure mode
- A reference file exists for the tool but is missing this command/pattern

### DISCARD if:
- Routine task completion with no new knowledge
- Session was short with no pain signals
- Information already captured in long-term memory
- Information is ephemeral (specific PR number, temp branch, one-time config)

### ARCHIVE if:
- Long-term file has reference_count < 2 and last_referenced > 30 days ago
- Content has been superseded by a newer entry
```

#### Inbox item lifecycle

Instead of deleting inbox files after consolidation, stamp them:

```markdown
---
status: processed
processed_date: 2026-03-27
consolidated_to: knowledge/runbooks/eks-troubleshooting.md
---
```

Weekly cleanup removes items with `status: processed` older than 7 days. This gives a window to audit consolidation decisions and reprocess if needed.

#### Multi-day gap handling

The memory agent processes all unprocessed inbox items regardless of age. If it runs Monday morning after a weekend, it picks up everything from Friday, Saturday, Sunday in one pass.

---

## Dry Run: A Typical Day

Walkthrough of how Work OS captures data, gets referenced by AI tools, and consolidates — showing both the **write path** (data in) and the **read path** (context out).

### Activities modeled

- Daily standup (MS Teams, Copilot auto-generated notes)
- Development work (Jira, VS Code, terminal, AI agents)
- End user support (MS Teams, Outlook, ServiceNow)
- Cross-team meetings (MS Teams)
- CI/CD admin (CircleCI, GitHub, GitHub Actions, AI agents)

---

### 8:30 AM — Start of Day

```
SessionStart hook fires (any AI tool)
  ├── git pull ~/.ai-context main
  │   └── Yesterday's consolidated memory is now available
  └── AI reads CLAUDE.md → sees external context routing block
      └── Reads ~/.ai-context/ROUTER.md (index loaded into context)
```

**External memory read:** `ROUTER.md` is now in the AI's context for the entire session. It knows what knowledge files exist and when to read them.

### 9:00 AM — Daily Standup (MS Teams)

**Automated capture:**
- Copilot meeting notes saved to Teams/OneDrive (already happens)

**Manual capture — `_inbox/notes/2026-03-27-standup.md`:**
```markdown
---
source: standup
date: 2026-03-27
---

- Jake is blocked on the Helm chart migration for payment-service —
  needs ArgoCD app-of-apps pattern, I've done this before
- Team decided to delay the Kafka upgrade until after Q2 freeze (April 11)
- Sarah mentioned staging env has been flaky since Tuesday —
  suspected memory pressure on node group B
```

**Consolidation would:**
- Promote Q2 freeze date → `knowledge/decisions/2026-03-q2-freeze-kafka.md`
- Hold staging issue in inbox until resolved, then → `knowledge/runbooks/` if it reveals a pattern
- Discard Jake's blocker (ephemeral, his problem)

### 9:30 AM – 12:00 PM — Development Work (Jira, VS Code, Terminal, AI Agents)

**Context: picking up CD-2891 — Helm chart migration to ArgoCD app-of-apps pattern.**

#### External memory READS during this block:

**Read 1 — `/jira-to-branch` skill fires, SKILL.md says to check external context:**
```
AI reads → ~/.ai-context/knowledge/domain/service-catalog.md
  └── Finds payment-service: owner=payments-team, namespace=payments,
      cluster=eks-prod-east, ArgoCD project=payments
  └── Uses this to set correct branch prefix and Jira labels
```

**Read 2 — starting Helm work, AI checks ROUTER.md index:**
```
AI reads → ~/.ai-context/knowledge/patterns/helm-chart-structure.md
  └── Finds org standard: charts/<service>/templates/, values-<env>.yaml
      naming convention, required labels, resource limits pattern
  └── Follows structure instead of guessing
```

**Read 3 — configuring ArgoCD Application resource:**
```
AI reads → ~/.ai-context/knowledge/patterns/argocd-app-of-apps.md
  └── (empty or doesn't exist yet — this is day 1)
  └── AI falls back to generic LLM knowledge
  └── This is where the gotcha happens — 30 min debugging
```

**Read 4 — debugging sync failure, AI checks learned context:**
```
AI reads → ~/.ai-context/learned/tool-quirks.md
  └── No entry for ArgoCD managed-by annotation (not yet captured)
  └── AI reads → ~/.ai-context/skills/argocd-operations/known-issues.md
  └── Also empty for this specific issue
  └── AI eventually figures it out through trial and error
```

**Note:** Reads 3 and 4 show the cold-start problem. After today's consolidation, these files will exist and the NEXT time someone hits this issue, the AI finds the answer immediately instead of spending 30 minutes.

**Automated capture — Stop hook → `workflow-log-auto.jsonl`:**
```json
{
  "session_id": "abc123",
  "repo": "payment-service",
  "branch": "feature/CD-2891-helm-migration",
  "intent": "migrate payment-service helm chart to app-of-apps pattern",
  "tools_used": ["mcp__cd-mcp-server__atlas_get_container_details"],
  "files_modified": ["charts/payment-service/values.yaml"],
  "duration_seconds": 1847,
  "pain_signals": ["file_edit_churn"],
  "skills_invoked": ["jira-to-branch"],
  "context_files_read": [
    "knowledge/domain/service-catalog.md",
    "knowledge/patterns/helm-chart-structure.md",
    "learned/tool-quirks.md"
  ]
}
```

**Manual capture — `_inbox/captures/2026-03-27-helm-gotcha.md`:**
```markdown
---
source: dev-session
date: 2026-03-27
ticket: CD-2891
---

ArgoCD app-of-apps pattern requires the child Application resource
to have the `argocd.argoproj.io/managed-by` annotation pointing to
the parent app name, not the project name. Spent 30 min debugging
sync failures because of this. The error message ("app not found in
project") is misleading — it's actually the annotation value.
```

**Consolidation would:**
- Promote the ArgoCD annotation gotcha → `knowledge/patterns/argocd-app-of-apps.md`
- Also append to → `skills/argocd-operations/known-issues.md`
- Note the pain signal (file_edit_churn on values.yaml) → may suggest skill improvement if recurring

### 12:30 PM — Support: End User Issue (Teams Chat + ServiceNow)

**Context: user reports payment processing timeouts in prod.**

#### External memory READS during investigation:

**Read 1 — AI starts investigating, checks runbooks first:**
```
AI reads → ~/.ai-context/knowledge/runbooks/incident-response.md
  └── Finds standard investigation flow:
      1. Check recent deploys (Octopus)
      2. Check service health (Observe)
      3. Check pod status (kubectl)
      4. Check connection pools and resource utilization
  └── AI follows this sequence instead of ad-hoc investigation
```

**Read 2 — AI needs to query Observe, checks reference:**
```
AI reads → ~/.ai-context/knowledge/domain/service-catalog.md
  └── Finds payment-service Observe dashboard URL, ServiceNow CI name
  └── Uses correct identifiers when querying MCP tools
```

**Read 3 — AI finds connection pool exhaustion, checks learned:**
```
AI reads → ~/.ai-context/learned/discoveries.md
  └── (No prior entry for connection pool issues — this is new)
  └── AI diagnoses from scratch using Observe metrics
```

**Read 4 — preparing the fix, checks deploy checklist:**
```
AI reads → ~/.ai-context/knowledge/runbooks/deploy-checklist.md
  └── Finds: "validate in staging before prod push"
  └── AI suggests staging deploy first instead of going straight to prod
```

**Automated capture — Stop hook:**
```json
{
  "intent": "investigate payment-service timeout in prod",
  "tools_used": ["mcp__observe__generate-service-map",
                 "mcp__cd-mcp-server__servicenow_get_incident"],
  "external_systems": ["observe", "servicenow"],
  "duration_seconds": 2340,
  "pain_signals": [],
  "context_files_read": [
    "knowledge/runbooks/incident-response.md",
    "knowledge/domain/service-catalog.md",
    "learned/discoveries.md",
    "knowledge/runbooks/deploy-checklist.md"
  ]
}
```

**Manual capture — `_inbox/captures/2026-03-27-payment-timeout.md`:**
```markdown
---
source: incident
date: 2026-03-27
ticket: INC0045231
service: payment-service
severity: P2
---

## Symptoms
- Payment API returning 504s after 30s
- Started ~11:45 AM, correlated with deploy of v2.14.3

## Root cause
Connection pool exhaustion. The new Kafka consumer in v2.14.3
holds connections longer during batch processing. Default pool
size (10) insufficient under load.

## Fix
Increased HikariCP maximumPoolSize from 10 → 25 in
payment-service/src/main/resources/application.yml.
Validated in staging before prod push.

## Prevention
- Add connection pool metrics to Observe dashboard
  (pool.active, pool.idle, pool.waiting)
- Add alert threshold at 80% pool utilization
```

**Consolidation would:**
- Promote root cause → `knowledge/runbooks/payment-service-incidents.md`
- Promote connection pool pattern → `learned/discoveries.md`
- Promote prevention items → merge into `knowledge/runbooks/deploy-checklist.md`
- Update `knowledge/domain/service-catalog.md` if payment-service not documented

### 2:00 PM — Cross-Team Meeting (MS Teams)

**Context: architecture review for API gateway migration.**

#### External memory READS during/after meeting:

**Read 1 — prepping for the meeting, AI checks existing architecture context:**
```
AI reads → ~/.ai-context/knowledge/domain/environment-map.md
  └── Finds current API gateway setup: Kong, ingress annotations,
      which services route through it
  └── You go into the meeting with accurate current-state context
```

**Read 2 — after meeting, drafting notes, AI checks for prior decisions:**
```
AI reads → ~/.ai-context/knowledge/decisions/
  └── No existing decision record for API gateway
  └── AI helps structure the new decision record using the template
```

**Automated capture:**
- Copilot meeting notes (same as standup)

**Manual capture — `_inbox/notes/2026-03-27-api-gateway-review.md`:**
```markdown
---
source: architecture-meeting
date: 2026-03-27
teams: [platform, payments, identity]
---

## Decisions
- API gateway migrating from Kong to Envoy Gateway
- Target: Q3 2026 (July start)
- Platform team owns the gateway, service teams own their route configs
- All services must migrate from Kong Ingress annotations to
  Gateway API HTTPRoute resources by Sept 30

## Impact on my work
- payment-service and identity-service both need route migration
- Need to understand Gateway API HTTPRoute spec
- Existing Kong rate-limiting plugins → need Envoy equivalent

## Action items
- [ ] Spike on HTTPRoute for payment-service (next sprint)
- [ ] Ask platform team for Envoy Gateway dev cluster access
```

**Consolidation would:**
- Promote the migration decision → `knowledge/decisions/2026-03-kong-to-envoy.md`
- Promote deadline → update `knowledge/domain/service-catalog.md` with migration timeline
- Create project → `projects/kong-to-envoy-migration/notes.md` with impact details
- Discard action items (ephemeral, belongs in Jira) — but keep the *context* about why

### 3:30 PM — CI/CD Admin (CircleCI, GitHub, GitHub Actions)

**Context: debugging a failing GitHub Actions workflow, reviewing PRs.**

#### External memory READS during this block:

**Read 1 — debugging GHA failure, AI checks patterns:**
```
AI reads → ~/.ai-context/knowledge/patterns/docker-artifactory-mirror.md
  └── (doesn't exist yet — this is day 1)
  └── AI investigates from scratch, discovers Docker Hub rate limit issue
```

**Read 2 — reviewing a PR for a new repo, AI checks onboarding patterns:**
```
AI reads → ~/.ai-context/skills/repo-onboarding/
  └── (if populated) Finds: common mistakes in new repos,
      required CI config, Dockerfile image sourcing rules
  └── AI catches that the PR uses `FROM node:18` instead of
      Artifactory mirror — flags it in review
```

**Read 3 — working with Octopus Deploy, AI checks reference:**
```
AI reads → ~/.ai-context/knowledge/reference/octopus-api.md
  └── Finds API patterns for querying deployment status,
      release creation, environment promotion
  └── AI uses correct API calls instead of guessing endpoints
```

**Automated capture:**
- Stop hook for each Claude Code session → `workflow-log-auto.jsonl`

**Manual capture — `_inbox/captures/2026-03-27-gha-runner-issue.md`:**
```markdown
---
source: ci-debug
date: 2026-03-27
---

GitHub Actions runners in the org were hitting Docker Hub rate
limits again. The fix is to use the org's Artifactory mirror:
  docker.artifactory.internal/library/<image>
instead of pulling directly from Docker Hub.

This keeps coming up when new repos are onboarded and someone
copies a Dockerfile with `FROM node:18` instead of using the
mirror prefix.
```

**Consolidation would:**
- Promote → `knowledge/patterns/docker-artifactory-mirror.md` ("keeps coming up" = high priority)
- Could also feed into `skills/repo-onboarding/` context so the onboarding skill catches this

---

### 4:30 PM — End of Day: Inbox State

```
~/.ai-context/_inbox/
├── notes/
│   ├── 2026-03-27-standup.md              # Team blockers, Q2 freeze decision
│   └── 2026-03-27-api-gateway-review.md   # Kong → Envoy migration decision
├── captures/
│   ├── 2026-03-27-helm-gotcha.md          # ArgoCD annotation gotcha
│   ├── 2026-03-27-payment-timeout.md      # Incident root cause + prevention
│   └── 2026-03-27-gha-runner-issue.md     # Docker Hub rate limit workaround
└── references/
    └── (empty today)
```

Plus automated: `~/.claude/workflow-log-auto.jsonl` — 4-5 session entries with tools, files, pain signals, context file references.

### Context files referenced today

| File | Reads | Activity | Hit/Miss |
|------|-------|----------|----------|
| `knowledge/domain/service-catalog.md` | 2 | Dev, Incident | Hit |
| `knowledge/patterns/helm-chart-structure.md` | 1 | Dev | Hit |
| `knowledge/runbooks/incident-response.md` | 1 | Incident | Hit |
| `knowledge/runbooks/deploy-checklist.md` | 1 | Incident | Hit |
| `knowledge/domain/environment-map.md` | 1 | Meeting | Hit |
| `knowledge/reference/octopus-api.md` | 1 | CI/CD | Hit |
| `knowledge/patterns/argocd-app-of-apps.md` | 1 | Dev | **Miss** (cold start) |
| `learned/tool-quirks.md` | 1 | Dev | **Miss** (cold start) |
| `learned/discoveries.md` | 1 | Incident | **Miss** (cold start) |
| `knowledge/patterns/docker-artifactory-mirror.md` | 1 | CI/CD | **Miss** (cold start) |

**4 misses today** — all cold-start gaps filled after consolidation.

### 5:00 PM — Memory Agent Consolidation Output

```
╔══════════════════════════════════════════════════════════════╗
║  Memory Consolidation — 2026-03-27                         ║
╠══════════════════════════════════════════════════════════════╣
║                                                            ║
║  PROMOTED (5 items):                                       ║
║  ├── ArgoCD annotation gotcha                              ║
║  │   → NEW knowledge/patterns/argocd-app-of-apps.md        ║
║  ├── Connection pool exhaustion incident                   ║
║  │   → NEW knowledge/runbooks/payment-service-incidents.md  ║
║  ├── Kong → Envoy Gateway migration decision               ║
║  │   → NEW knowledge/decisions/2026-03-kong-to-envoy.md    ║
║  ├── Docker Hub rate limit workaround                      ║
║  │   → NEW knowledge/patterns/docker-artifactory-mirror.md ║
║  └── Kong → Envoy project context                          ║
║      → NEW projects/kong-to-envoy-migration/notes.md       ║
║                                                            ║
║  MERGED (3 items):                                         ║
║  ├── Connection pool discovery                             ║
║  │   → APPEND learned/discoveries.md                       ║
║  ├── ArgoCD managed-by quirk                               ║
║  │   → APPEND skills/argocd-operations/known-issues.md     ║
║  └── Staging flakiness note from standup                   ║
║      → APPEND skills/eks-troubleshooting/known-failures.md ║
║                                                            ║
║  DISCARDED (3 items):                                      ║
║  ├── Jake's blocker — ephemeral, his problem               ║
║  ├── Gateway migration action items — belongs in Jira      ║
║  └── 2 routine dev sessions — no new knowledge             ║
║                                                            ║
║  ARCHIVED (0 items):                                       ║
║                                                            ║
║  REFERENCE COUNTS UPDATED:                                 ║
║  ├── knowledge/domain/service-catalog.md         (9 → 11)  ║
║  ├── knowledge/patterns/helm-chart-structure.md  (11 → 12) ║
║  ├── knowledge/runbooks/incident-response.md     (5 → 6)   ║
║  ├── knowledge/runbooks/deploy-checklist.md      (7 → 8)   ║
║  ├── knowledge/domain/environment-map.md         (3 → 4)   ║
║  └── knowledge/reference/octopus-api.md          (4 → 5)   ║
║                                                            ║
║  ROUTER.md updated: 5 new entries added to index           ║
╚══════════════════════════════════════════════════════════════╝

→ Branch: memory/2026-03-27
→ PR opened — auto-merged (all append-only/new files)
→ _inbox/ items stamped as processed
```

### Next Morning — The Payoff

```
SessionStart hook fires
  └── git pull ~/.ai-context main
      └── 5 new knowledge files + 3 merged entries available

Scenario: teammate hits the same ArgoCD annotation issue
  └── AI reads ROUTER.md → sees knowledge/patterns/argocd-app-of-apps.md
  └── Reads it → finds: "managed-by annotation must point to parent
      app name, not project name"
  └── Issue resolved in 2 minutes instead of 30

Scenario: another service has connection pool issues
  └── AI reads learned/discoveries.md
  └── Finds: "HikariCP default pool size (10) insufficient when
      Kafka consumers hold connections during batch processing"
  └── AI suggests checking pool size immediately instead of
      spending 20 min diagnosing from scratch
```

**This is the compounding effect.** Day 1 has cold-start misses. Day 2 starts with answers. Day 30, the AI rarely needs to figure things out from scratch.

---

### Capture Value by Activity

| Activity | Automated capture | Manual note adds | Effort |
|----------|------------------|-----------------|--------|
| Standup | Copilot summary (who said what) | Decisions with dates, things that affect your work | 2 min |
| Dev work | Session logs, pain signals, files changed | The "why" behind gotchas, workarounds worth remembering | 1-2 min per gotcha |
| Incidents | Tools used, duration, external systems | Root cause, fix, prevention — actual runbook content | 5 min (highest value) |
| Architecture meetings | Copilot summary | Decisions, deadlines, impact on your services | 3 min |
| CI/CD work | Session logs | Recurring patterns ("this keeps happening") | 1 min |

**Rule of thumb:** If you'd tell a teammate about it, drop it in the inbox. If it's routine, let the automated capture handle it.

---

## Recommendations from Dry Run

### 1. The inbox needs a faster capture path

Dropping a markdown file with frontmatter into `_inbox/` is friction. You're context-switching from Teams/terminal/browser to create a structured file. Capture must be as fast as sending a message.

**Options:**
- **`/remember` skill** — you're already in Claude Code: `/remember ArgoCD app-of-apps requires managed-by annotation pointing to parent app name, not project name`. The skill writes the inbox file with auto-generated frontmatter.
- **Hotkey/Alfred workflow** — pops a text box, dumps to inbox with timestamp. No terminal needed.
- **Slack/Teams bot** — DM yourself a note, webhook writes to inbox. Best for meeting notes since you're already in Teams.

Without a fast path, manual captures won't happen consistently.

### 2. Meeting notes are the biggest automated capture gap

Dev work has hooks logging every session. Meetings have Copilot summaries that live in Teams and never reach the inbox. This is a problem because meetings are where decisions, deadlines, and context live.

**Options:**
- **Copilot meeting recap → inbox pipeline** — A Power Automate flow (or scheduled script hitting the Graph API) pulls today's meeting recaps and drops them into `_inbox/references/`. The memory agent has raw material to work with.
- **Manual-but-fast fallback** — The `/remember` skill with a `source: meeting` tag. Spend 2 minutes after each meeting dumping bullet points.

Without this, external memory will skew heavily toward dev work and underrepresent the decisions that actually drive priorities.

### 3. Incident captures should be semi-structured

The payment-timeout example was the highest-value inbox item but required the most effort to write. Incidents follow a repeatable pattern — use a template:

```markdown
---
source: incident
date: {{DATE}}
ticket: {{SNOW_ID}}
service: {{SERVICE}}
---
## Symptoms
## Root cause
## Fix
## Prevention
```

This could be a `/capture-incident` skill or a template the `/remember` skill uses when you say "remember incident for payment-service." The structure makes consolidation more reliable — the agent knows exactly where to route each section. Obsidian's template plugin can also insert this via hotkey.

### 4. Reference counting needs Copilot coverage too

The dry run showed 4-5 Claude Code sessions logging context file reads. But Copilot in VS Code was also used for hours — those reads aren't tracked. If Copilot references `knowledge/patterns/helm-chart-structure.md` via `#file`, that doesn't show up in reference counts.

The existing `copilot-autolog.sh` hook should be extended to extract which `~/.ai-context/` files were referenced in Copilot sessions, making reference counts accurate across both tools.

### 5. The references inbox subfolder needs a defined use case

In the dry run, `_inbox/references/` was empty because no workflow naturally puts things there. Define what goes here and wire a capture path:
- Links to wiki pages looked up during the day
- Architecture diagrams shared in Teams
- Confluence pages relevant to current work
- Docs found via search that were useful

Capture paths: browser extension, `/remember link <url> <why>`, or the Teams meeting recap pipeline dropping shared links. Without a path, this folder stays empty.

### 6. Add a weekly summary layer

Daily consolidation promotes individual items. After 5 days, you have 15-20 new entries scattered across `knowledge/`, `learned/`, `skills/`. A **weekly rollup** (Friday EOD or Monday morning) that produces a summary would:

- Give a single file to review over coffee Monday morning
- Surface patterns the daily agent misses ("you hit connection pool issues in 3 different services this week")
- Feed into standup prep — know exactly what you worked on
- Auto-archive to `knowledge/decisions/weekly/` as a lightweight work journal

This is a second scheduled agent, lightweight — reads the week's consolidation logs and produces a summary.

---

## Migration from Obsidian Vault

Content worth migrating from `obsidian-vaults/work/` to seed the Work OS:

| Old vault file | Migrate to | Why |
|---|---|---|
| `backcountry/kubernetes/argocd.md` | `knowledge/patterns/argocd-*.md` | Universal ArgoCD knowledge |
| `prog-leasing/ci-cd/argo-cd/*.md` | Merge with above | Combine both employers' ArgoCD knowledge |
| `backcountry/cloud/gcloud.md` | `knowledge/reference/gcloud.md` | CLI reference, still useful |
| `backcountry/kubernetes/kubectl.md` | `knowledge/reference/kubectl.md` | CLI reference |
| `prog-leasing/fastpass/architecture.md` | `projects/fastpass-ai/architecture.md` | Active project context |
| `prog-leasing/platform/kubernetes/*.md` | `knowledge/patterns/` or `knowledge/runbooks/` | EKS patterns are evergreen |
| `prog-leasing/observability/Dynatrace.md` | `knowledge/reference/dynatrace.md` | Tool reference |
| `prog-leasing/incidents/` | `knowledge/runbooks/` | Extract patterns from past incidents |
| `backcountry/observability/*.md` | `knowledge/reference/` | Monitoring tool references |
| `prog-leasing/ci-cd/circle-ci/*.md` | `knowledge/reference/circleci.md` | CI tool reference |

**Don't migrate:** temp-notes, story-specific working notes, employer-specific configs no longer relevant, binary files.

---

## Implementation Phases

### Phase 1: MVP (2 days)
- Create `~/.ai-context/` git repo with directory structure
- Configure Obsidian vault (attachments, templates)
- Write ROUTER.md with initial index
- Write identity files (role, preferences, tools)
- Seed 8-10 knowledge files from Obsidian vault
- Create `_config/templates/` (incident, meeting, decision, capture)
- Add routing block to CLAUDE.md / AGENTS.md in key repos
- Update 2-3 skills to reference Work OS
- Build `/remember` skill for fast inbox captures

### Phase 2: Two-way reads + writes
- Extend Stop hooks to log which context files were referenced (reference tracking)
- Add staleness detection via frontmatter `last_verified` / `last_referenced` dates
- Update more skills to read from and write back to Work OS
- Iterate on ROUTER.md based on 2-3 weeks of real usage

### Phase 3: Automated consolidation
- Build the memory agent (scheduled daily run)
- Wire inbox ingestion from hooks, skills, and manual additions
- Write `_config/consolidation-rules.md`
- Set up auto-merge for append-only PRs, human review for modifications
- Add weekly inbox cleanup
- Build weekly summary agent

### Phase 4: Org readiness
- Create team context repo with its own ROUTER.md
- Add as git submodule to personal `~/.ai-context/team/`
- Define CODEOWNERS per directory (same pattern as fastpass-ai)
- Per-person `_inbox/` subdirs to avoid write conflicts
- Build sync workflow for org-level context distribution
- Evaluate MCP server for semantic search over org knowledge
