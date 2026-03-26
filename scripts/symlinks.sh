#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# symlink helper: creates a symlink, backing up the target if it already exists
# and is not already the correct symlink.
#   link <source_in_repo> <target_path>
link() {
  local src="$REPO_DIR/$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "  SKIP $1 (source does not exist)"
    return
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$dest")"

  # Already correctly linked
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  OK   $dest -> $src"
    return
  fi

  # Back up existing file/directory
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    echo "  BACK $dest -> $backup"
    mv "$dest" "$backup"
  fi

  ln -s "$src" "$dest"
  echo "  LINK $dest -> $src"
}

echo "Symlinking config files..."

# ZSH
link "configs/zsh/.zshrc"       "$HOME/.zshrc"
link "configs/zsh/.zprofile"    "$HOME/.zprofile"

# Starship
link "configs/starship/starship.toml" "$HOME/.config/starship.toml"

# VSCode
link "configs/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
link "configs/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

# Claude Code
link "configs/claude/settings.json" "$HOME/.claude/settings.json"

# MCP servers (shared across Claude Code, Copilot VS Code, Copilot CLI)
link "configs/mcp/.mcp.json" "$REPO_DIR/.mcp.json"

# Git
link "configs/git/.gitconfig"          "$HOME/.gitconfig"
link "configs/git/.gitconfig-personal" "$HOME/.gitconfig-personal"
link "configs/git/.gitconfig-work"     "$HOME/.gitconfig-work"

# SSH
link "configs/ssh/config" "$HOME/.ssh/config"

# Warp
link "configs/warp" "$HOME/.warp"
