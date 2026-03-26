#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="observability"
VALUES_DIR="$SCRIPT_DIR/helm-values"

echo "==> Deploying AI telemetry stack to namespace: $NAMESPACE"

# Apply kustomize base (namespace and any raw k8s resources)
echo "==> Applying kustomize base..."
kubectl apply -k "$SCRIPT_DIR/base"

# Add Helm repos
echo "==> Adding Helm repos..."
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts 2>/dev/null || true
helm repo update

# Install/upgrade Helm releases
echo "==> Deploying Prometheus..."
helm upgrade --install prometheus prometheus-community/prometheus \
  -n "$NAMESPACE" -f "$VALUES_DIR/prometheus.yaml" --wait

echo "==> Deploying Loki..."
helm upgrade --install loki grafana/loki \
  -n "$NAMESPACE" -f "$VALUES_DIR/loki.yaml" --wait

echo "==> Deploying Tempo..."
helm upgrade --install tempo grafana/tempo \
  -n "$NAMESPACE" -f "$VALUES_DIR/tempo.yaml" --wait

echo "==> Deploying OTEL Collector..."
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  -n "$NAMESPACE" -f "$VALUES_DIR/otel-collector.yaml" --wait

echo "==> Deploying Grafana..."
helm upgrade --install grafana grafana/grafana \
  -n "$NAMESPACE" -f "$VALUES_DIR/grafana.yaml" --wait

echo ""
echo "==> Telemetry stack deployed!"
echo ""
echo "Access Grafana: http://localhost:30080"
echo "Get admin password: kubectl get secret grafana -n $NAMESPACE -o jsonpath='{.data.admin-password}' | base64 -d"
echo ""
echo "OTEL Collector endpoint (within cluster): http://otel-collector-opentelemetry-collector.$NAMESPACE.svc:4318"
