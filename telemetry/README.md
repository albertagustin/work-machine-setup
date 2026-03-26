# AI Tool Telemetry Stack

Local evaluation setup for capturing OTEL telemetry from AI coding tools (Claude Code, Copilot CLI, VS Code Copilot) and visualizing it in Grafana.

## Important: GitOps Convention

**All changes to the telemetry stack must be made to the files in this directory, then applied to the cluster.** Do not make changes directly to the cluster unless absolutely necessary (e.g., debugging). Direct cluster changes will be lost on teardown/redeploy and won't be reproducible on a new machine.

The flow is:
1. Edit files in `telemetry/` (Helm values, kustomize resources, dashboard JSON)
2. Apply to cluster: `kubectl apply -k telemetry/base` and/or `./telemetry/deploy.sh`
3. Commit changes to git

## Architecture

```
Claude Code  ──┐
Copilot CLI  ──┼──► OTEL Collector ──► Prometheus (metrics)
VS Code      ──┘    (otel.local)   ──► Loki (logs)
                                    ──► Tempo (traces)
                                          │
                                     Grafana (dashboards)
                                    (grafana.local)
```

## Components

| Component | Purpose | Chart | Mode |
|-----------|---------|-------|------|
| OTEL Collector | Receives OTLP, routes to backends | `open-telemetry/opentelemetry-collector` | Deployment |
| Prometheus | Metrics storage | `prometheus-community/prometheus` | Server only |
| Loki | Log storage | `grafana/loki` | Single-binary |
| Tempo | Trace storage | `grafana/tempo` | Single-binary |
| Grafana | Dashboards & visualization | `grafana/grafana` | With sidecar |

## File Structure

```
telemetry/
├── deploy.sh                           # Deploy full stack (kustomize + helm)
├── teardown.sh                         # Tear down full stack
├── README.md
├── base/
│   ├── kustomization.yaml              # Kustomize config (namespace, ingress, dashboard ConfigMaps)
│   ├── namespace.yaml                  # observability namespace
│   ├── ingress.yaml                    # Traefik ingress for grafana.local and otel.local
│   └── ai-tools-overview.json          # Grafana dashboard (loaded via ConfigMap + sidecar)
└── helm-values/
    ├── grafana.yaml                    # Grafana Helm values (datasources, sidecar)
    ├── prometheus.yaml                 # Prometheus Helm values
    ├── loki.yaml                       # Loki Helm values (single-binary)
    ├── tempo.yaml                      # Tempo Helm values (single-binary)
    └── otel-collector.yaml             # OTEL Collector Helm values (receiver + exporter config)
```

## Deploy

```bash
# Full deploy (namespace, ConfigMaps, Helm charts)
./telemetry/deploy.sh

# Update dashboards and kustomize resources only (no Helm changes)
kubectl apply -k telemetry/base

# Tear down everything
./telemetry/teardown.sh
```

## Access

- **Grafana**: http://grafana.local
  - Dashboard: http://grafana.local/d/ai-tools-overview
  - Get admin password: `kubectl get secret grafana -n observability -o jsonpath='{.data.admin-password}' | base64 -d`
- **OTEL Collector**: http://otel.local (receives OTLP HTTP)

Requires `/etc/hosts` entry: `127.0.0.1  grafana.local otel.local`

## Making Changes

### Dashboards
1. Edit `base/ai-tools-overview.json` (or add new JSON files)
2. Update `base/kustomization.yaml` if adding new dashboards
3. Run `kubectl apply -k telemetry/base`
4. Grafana sidecar auto-reloads within ~60s

### Helm values (backends, collector config)
1. Edit the appropriate file in `helm-values/`
2. Run `./telemetry/deploy.sh` (or targeted `helm upgrade`)
3. Commit changes

### Adding a new ingress
1. Add the host/path to `base/ingress.yaml`
2. Add the hostname to `/etc/hosts`
3. Run `kubectl apply -k telemetry/base`

## AI Tool Configuration

Add these to `.envrc` to enable telemetry export:

```bash
# Claude Code
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://otel.local
export OTEL_LOG_USER_PROMPTS=1
export OTEL_LOG_TOOL_DETAILS=1
export OTEL_RESOURCE_ATTRIBUTES=department=platform,team.id=shared-services

# Copilot CLI
export COPILOT_OTEL_ENABLED=true
export COPILOT_OTEL_EXPORTER_TYPE=otlp-http
export OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true

# VS Code Copilot (env vars — also configured in configs/vscode/settings.json)
export COPILOT_OTEL_ENDPOINT=http://otel.local
export COPILOT_OTEL_CAPTURE_CONTENT=true
```

## Signal Coverage

| Signal | Claude Code | Copilot CLI | VS Code Copilot |
|--------|-------------|-------------|-----------------|
| Traces | — | Yes | Yes |
| Metrics | Yes | Yes | Yes |
| Logs/Events | Yes | — | Events only |

## Dashboard Sections

The "AI Tools — Telemetry Overview" dashboard is organized into:

1. **Global Overview** — cost, tokens, sessions, active time, lines of code, commits across all tools
2. **Claude Code** — token breakdown, cost, tool decisions, lines added/removed, API and tool events
3. **GitHub Copilot (VS Code + CLI)** — combined token usage, tool calls, operation duration, traces
4. **GitHub Copilot — VS Code** — sessions, tool calls, time to first token, agent duration/turns
5. **GitHub Copilot — CLI** — tool calls, operation duration, time to first chunk, agent turns
