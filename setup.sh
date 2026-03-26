#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Work machine setup starting..."
echo "    Repo: $REPO_DIR"
echo ""

# Run each setup script in order
for script in \
  "$REPO_DIR/scripts/brew.sh" \
  "$REPO_DIR/scripts/zsh.sh" \
  "$REPO_DIR/scripts/symlinks.sh"; do
  echo "==> Running $(basename "$script")..."
  bash "$script"
  echo ""
done

echo "==> Setup complete!"
echo "    Restart your terminal (or run 'source ~/.zshrc') to pick up changes."
