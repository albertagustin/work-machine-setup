#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This helper is intended for macOS." >&2
  exit 1
fi

SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"

echo "==> Configuring persistent launcher environment for VS Code Copilot OTEL"

# Use localhost:4318 (LoadBalancer) instead of otel.local (Traefik) because
# VS Code's Node.js runtime may not send the Host header correctly for
# custom hostnames, causing Traefik to return 404.
launchctl setenv OTEL_EXPORTER_OTLP_PROTOCOL http/protobuf
launchctl setenv COPILOT_OTEL_ENABLED true
launchctl setenv COPILOT_OTEL_CAPTURE_CONTENT true
launchctl setenv OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT true

echo "==> Launcher environment configured"

if [[ -f "$SETTINGS_FILE" ]]; then
  echo "==> Inspecting VS Code user settings"
  if rg -n 'github\.copilot\.chat\.otel\.(enabled|exporterType|otlpEndpoint|captureContent)' "$SETTINGS_FILE" >/dev/null; then
    echo "VS Code Copilot OTEL settings were found in user settings."
  else
    cat <<'EOF'
VS Code Copilot OTEL settings were not found in the user settings file.
Add this block to your VS Code settings:

  "github.copilot.chat.otel.enabled": true,
  "github.copilot.chat.otel.exporterType": "otlp-http",
  "github.copilot.chat.otel.otlpEndpoint": "http://localhost:4318",
  "github.copilot.chat.otel.captureContent": true
EOF
  fi
else
  echo "VS Code user settings file was not found at: $SETTINGS_FILE"
fi

cat <<'EOF'

Next steps:
1. Fully quit VS Code.
2. Launch VS Code again so it inherits the launcher environment.
3. Run a short Copilot Chat prompt or agent flow.
4. Query Tempo to confirm new traces are present.
EOF
