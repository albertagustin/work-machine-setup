# TODO

## High Priority

- [ ] Setup AWS CLI — configure profiles, SSO login, and connect to all work EKS clusters
- [ ] Setup unified MCP server config — single location for defining MCP servers shared across Copilot (VSCode + CLI) and Claude Code (VSCode + CLI)
- [ ] Install GitHub Copilot CLI
- [ ] Clone work repos:
  - [ ] fastpass
  - [ ] cd-mcp-server
  - [ ] configs repos
  - [ ] hubeks
  - [ ] blueprints
  - [ ] sharedeks
  - [ ] ai-files

## Recommendations

- [ ] Add a `scripts/clone.sh` — automate cloning all work repos to the correct directories with the right remote URLs, so a fresh machine can be fully set up in one pass
- [ ] Install `k9s` — terminal-based k8s dashboard, great for quick cluster exploration without a browser
- [ ] Install `fzf` — fuzzy finder for shell history, file search, and interactive filtering; integrates with zoxide (`zi`) and git branch switching
- [ ] Install `tldr` — simplified man pages with practical examples (e.g., `tldr kubectl` gives you the most common commands)
- [ ] Add VSCode extensions to Brewfile — `brew bundle` supports `vscode "extension.id"` entries, so extensions can be version-controlled and auto-installed
- [ ] Add a `scripts/macos.sh` — automate macOS system preferences (trackpad speed, key repeat rate, Finder settings, etc.) so they don't need to be manually configured each time
- [ ] Setup Warp config — Warp stores its settings in `~/.warp/`, which is already symlinked; add your theme and workflow configs there
