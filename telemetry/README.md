# AI Tool Telemetry Stack

Local evaluation setup for capturing OTEL telemetry from AI coding tools (Claude Code, Copilot CLI, VS Code Copilot) and visualizing it in Grafana.

## Architecture

```
Claude Code  ──┐
Copilot CLI  ──┼──► OTEL Collector ──► Prometheus (metrics)
VS Code      ──┘     (port 4318)   ──► Loki (logs)
                                    ──► Tempo (traces)
                                          │
                                     Grafana (dashboards)
                                    (localhost:30080)
```

## Components

| Component | Purpose | Chart |
|-----------|---------|-------|
| OTEL Collector | Receives OTLP, routes to backends | `open-telemetry/opentelemetry-collector` |
| Prometheus | Metrics storage | `prometheus-community/prometheus` |
| Loki | Log storage | `grafana/loki` (single-binary) |
| Tempo | Trace storage | `grafana/tempo` (single-binary) |
| Grafana | Dashboards & visualization | `grafana/grafana` |

## Deploy

```bash
# Deploy the full stack
./telemetry/deploy.sh

# Tear down
./telemetry/teardown.sh
```

Kustomize manages the namespace and any raw k8s resources. Helm manages the application charts.

## Access

- **Grafana**: http://localhost:30080
  - Default credentials: admin / (get from secret: `kubectl get secret grafana -n observability -o jsonpath='{.data.admin-password}' | base64 -d`)
- **OTEL Collector**: receives on port 4318 (HTTP) within the cluster

## AI Tool Configuration

Add these to `.envrc` to enable telemetry export:

```bash
# Claude Code
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_LOG_USER_PROMPTS=1
export OTEL_LOG_TOOL_DETAILS=1
export OTEL_RESOURCE_ATTRIBUTES=department=platform,team.id=shared-services

# Copilot CLI
export COPILOT_OTEL_ENABLED=true
export OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
```

VS Code Copilot is configured via settings (see `configs/vscode/settings.json`).

## Signal coverage

| Signal | Claude Code | Copilot CLI | VS Code Copilot |
|--------|-------------|-------------|-----------------|
| Traces | — | Yes | Yes |
| Metrics | Yes | Yes | Yes |
| Logs/Events | Yes | — | Events only |
