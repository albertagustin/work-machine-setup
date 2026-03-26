#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="observability"

echo "==> Tearing down AI telemetry stack from namespace: $NAMESPACE"

helm uninstall grafana -n "$NAMESPACE" 2>/dev/null || true
helm uninstall otel-collector -n "$NAMESPACE" 2>/dev/null || true
helm uninstall tempo -n "$NAMESPACE" 2>/dev/null || true
helm uninstall loki -n "$NAMESPACE" 2>/dev/null || true
helm uninstall prometheus -n "$NAMESPACE" 2>/dev/null || true

kubectl delete namespace "$NAMESPACE" 2>/dev/null || true

echo "==> Teardown complete."
