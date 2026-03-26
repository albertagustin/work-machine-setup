# Org-level AI Telemetry — Gap Analysis

Comparison of what we currently capture vs what we want to capture at the org level.

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Captured today |
| ⚠️ | Partially captured |
| ❌ | Not captured |

---

## Task Initiation

| Metric | Status | Current Source | Gap | Recommendation |
|--------|--------|---------------|-----|----------------|
| **Task ID** (Jira / PR / spec) | ❌ | — | No linkage between AI sessions and work items | Emit `task_id` as a span attribute at session start. Best captured in workflow-autolog.sh by parsing the first user prompt for Jira keys (e.g., `PROJ-123`) or PR URLs, or by prompting the user. Could also be injected via a SessionStart hook that reads from branch name conventions. |
| **Timestamp — start** | ✅ | Tempo traces, JSONL `timestamp` | — | Already captured. |
| **Task type** (feature, bug fix, refactor, etc.) | ❌ | — | No classification of work type | Add a `task_type` label. Can be inferred by LLM classification of the first user prompt in workflow-autolog.sh, or derived from Jira issue type if task_id is linked. |
| **Requesting team / repo / service** | ⚠️ | JSONL `repo`, `branch`; OTEL has no repo label | Repo is captured locally in hooks but not emitted as an OTEL attribute | Extend workflow-autolog.sh to emit `repo` and `branch` as OTEL resource attributes. Team can be derived from repo ownership (e.g., via a repo-to-team mapping config). |
| **Agent identity** | ✅ | OTEL `service.name` (claude-code, github-copilot, copilot-chat) | — | Already captured. |
| **Input context size** (tokens in) | ✅ | Prometheus `claude_code_token_usage_tokens_total{type="input"}`, `gen_ai_client_token_usage_tokens{gen_ai_token_type="input"}` | — | Already captured. |
| **Human who initiated** | ❌ | — | No user identity in OTEL data | Emit `user.email` as an OTEL resource attribute. Can be sourced from `git config user.email` at session start. For org-level, could also come from SSO/SAML identity. |

## During Execution

| Metric | Status | Current Source | Gap | Recommendation |
|--------|--------|---------------|-----|----------------|
| **API calls** (count, model, tokens in/out) | ✅ | Prometheus metrics (token counters by model and type), Loki logs (api_request events), Tempo traces | — | Already captured. |
| **Tool invocations** (file edits, bash, MCP) | ✅ | Prometheus `claude_code_code_edit_tool_decision_total`, Loki `tool_result` events, JSONL `tool_counts` | — | Already captured. Copilot tool invocations are partially captured via Loki but lack granular tool-name labels. |
| **Intermediate failures / retries** | ⚠️ | JSONL `pain_signals` (high_tool_errors), Loki logs contain error events | Not aggregated as a metric; only available as local pain signals | Create an OTEL counter `ai_task_failures_total` with labels `{type="tool_error\|api_error\|retry"}`. Can be emitted from workflow-autolog.sh by counting error patterns in session transcript. Alternatively, parse Loki logs for error patterns via a recording rule. |
| **Wall-clock duration** | ⚠️ | Prometheus `claude_code_active_time_seconds_total`, JSONL `session_duration_seconds` | `active_time` is Claude Code only. No Copilot equivalent. JSONL duration is local-only. | Emit `session_duration_seconds` as an OTEL histogram from both workflow-autolog.sh and copilot-autolog.sh. |
| **Active compute duration** (excluding human wait) | ❌ | — | No separation of compute time vs idle/review time | Requires a timer that pauses when the agent is waiting for human input. Could be approximated by summing trace span durations (Tempo) for API calls within a session. True implementation needs agent-side instrumentation to track `compute_active_seconds` separately. |

## Task Completion

| Metric | Status | Current Source | Gap | Recommendation |
|--------|--------|---------------|-----|----------------|
| **Timestamp — end** | ✅ | Tempo trace end, JSONL `timestamp` | — | Already captured. |
| **Output size** (lines changed, files touched) | ✅ | Prometheus `claude_code_lines_of_code_count_total`, JSONL `files_modified` | Files-touched count is local-only (JSONL), not in OTEL | Emit `files_modified_count` as an OTEL gauge from workflow-autolog.sh. |
| **Complexity signals** (files, services, tests) | ⚠️ | JSONL `files_modified` (count), JSONL `external_systems` | No test count, no multi-service tracking, not in OTEL | Extend workflow-autolog.sh to count test files created/modified (`*_test.*`, `*.spec.*`). Track unique repos/services from `external_systems`. Emit as OTEL metrics. |
| **Human review time** (PR open → approved) | ❌ | — | No PR lifecycle tracking | Requires GitHub integration. Options: (1) GitHub Actions workflow triggered on `pull_request_review` that emits a metric, (2) Cron job using `gh pr list --json createdAt,mergedAt,reviews` that computes and emits the delta, (3) GitHub webhook to a small receiver service. |
| **Human edits post-AI** (lines changed in review) | ❌ | — | No diff comparison between AI commit and merge commit | Requires a post-merge analysis step. Options: (1) GitHub Actions post-merge job that runs `git diff <ai-commit>..<merge-commit> --stat` and emits line counts, (2) A PR label convention (e.g., `ai-generated`) that triggers the comparison. |
| **Outcome** (merged / rejected / reworked) | ❌ | — | No PR disposition tracking | Requires: (1) Track PRs opened by AI agents (via `Co-Authored-By` trailer or branch naming convention), (2) Monitor their final state via GitHub API. Define thresholds: `merged` = merged with <10 human-edited lines, `reworked` = merged with >10 lines changed, `rejected` = closed without merge. |

---

## Summary: What's missing and where to capture it

### Quick wins (local hook changes only)

These can be implemented by extending `workflow-autolog.sh` and `copilot-autolog.sh` to emit OTEL metrics/attributes:

1. **Repo/branch as OTEL attributes** — already in JSONL, just needs to be emitted via OTEL
2. **User identity** — read from `git config user.email`, emit as resource attribute
3. **Task ID extraction** — parse first prompt for Jira keys or PR URLs
4. **Task type classification** — LLM-classify the first user prompt (or map from Jira issue type)
5. **Session duration as OTEL metric** — already computed, just needs OTEL export
6. **Files-modified count as OTEL metric** — already computed, just needs OTEL export
7. **Failure/retry counter** — count error patterns in session, emit as counter

### Medium effort (new tooling required)

8. **Complexity signals** — extend hooks to detect test files, count unique services
9. **Active compute duration** — approximate from Tempo span aggregation (sum of API call durations within a trace)

### Significant effort (GitHub integration required)

10. **Human review time** — needs GitHub Actions workflow or webhook integration
11. **Human edits post-AI** — needs post-merge diff analysis (GitHub Actions)
12. **Outcome tracking** — needs PR lifecycle monitoring (GitHub Actions + labeling convention)

### Architectural recommendation

For items 10-12, the most scalable approach is:

1. **Label AI-generated PRs** — use a consistent marker (e.g., `Co-Authored-By:` trailer, `ai-generated` label, or branch prefix like `ai/`)
2. **GitHub Actions workflow** — trigger on `pull_request` events (opened, closed, merged) and `pull_request_review` (approved, changes_requested)
3. **Emit to OTEL** — use `curl` to POST metrics to the OTEL Collector HTTP endpoint (`otel-collector.observability.svc:4318`)
4. **Store in Prometheus** — metrics flow through the existing pipeline

This keeps the existing architecture (OTEL Collector → Prometheus/Loki/Tempo → Grafana) and adds GitHub as a new data source without introducing additional infrastructure.

---

## Current data flow

```
Claude Code / Copilot VS Code / Copilot CLI
    │
    ├── OTEL SDK ──► OTEL Collector ──► Prometheus (metrics)
    │                                ──► Loki (logs)
    │                                ──► Tempo (traces)
    │
    └── Stop hooks ──► workflow-autolog.sh ──► ~/.claude/workflow-log-auto.jsonl (local)
                   ──► copilot-autolog.sh  ──► ~/.claude/workflow-log-auto.jsonl (local)

Grafana reads from Prometheus, Loki, Tempo
```

### Proposed additions

```
Claude Code / Copilot VS Code / Copilot CLI
    │
    ├── OTEL SDK ──► OTEL Collector ──► Prometheus / Loki / Tempo
    │
    ├── Stop hooks ──► workflow-autolog.sh ──► JSONL (local)
    │                                     ──► OTEL Collector (new: emit metrics via HTTP)
    │
    └── GitHub Actions (new) ──► OTEL Collector (PR lifecycle metrics)

Grafana reads from Prometheus, Loki, Tempo (unchanged)
```
