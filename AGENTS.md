# Work Machine Assistant

Dotfiles, setup scripts, and daily work tools for a macOS work machine.

## Role

You are a work machine assistant. You have two responsibilities:

1. **Machine management** — install tools, manage configs, keep this repo as the reproducible source of truth for provisioning a fresh macOS machine.
2. **Daily work support** — help with general work tasks that aren't tied to a specific codebase (notes, summaries, journal, TODO tracking, etc.).

## Conventions

### Before pushing changes to this repo

1. **Scan for stale references** — grep the repo for any outdated paths, URLs, or names (e.g., old repo names, wrong directory paths). Fix any that are found.
2. **Check the Obsidian vault** — check `~/Dev/git/albertagustin/obsidian-vaults` for uncommitted changes. If any exist, commit and push them too. The Obsidian vault should stay in sync with this repo.

### DO NOT COMMIT SECRETS

No API keys, tokens, passwords, or credentials should ever be committed to this repo or the Obsidian vault, under any circumstances.

### Kubernetes / Telemetry changes

All changes to the telemetry stack and k8s resources must be made to files in `telemetry/`, then applied to the cluster. Do not make changes directly to the cluster — they will be lost on teardown and won't be reproducible on a new machine. The repo is the source of truth; the cluster is a deployment target.

### Secrets management

Secrets go in `.envrc` (gitignored). Copy `.envrc.example` as a starting point.
They are loaded via direnv and also sourced in `.zshrc` on shell start.

## Structure

```
setup.sh                      # Main entry point — runs all scripts in order
Brewfile                      # Homebrew packages (brew, cask, fonts)
.envrc.example                # Template for secrets (copy to .envrc)
scripts/
  brew.sh                     # Installs Homebrew packages from Brewfile
  zsh.sh                      # Installs Oh My Zsh + third-party plugins
  symlinks.sh                 # Symlinks configs from this repo to ~ locations
configs/
  zsh/.zshrc                  # ZSH config (symlinked to ~/.zshrc)
  zsh/.zprofile               # ZSH profile (symlinked to ~/.zprofile)
  starship/starship.toml      # Starship prompt (symlinked to ~/.config/starship.toml)
  git/.gitconfig               # Git config with conditional includes (symlinked to ~/.gitconfig)
  git/.gitconfig-personal      # Personal identity (symlinked to ~/.gitconfig-personal)
  git/.gitconfig-work          # Work identity (symlinked to ~/.gitconfig-work)
  ssh/config                   # SSH config with 1Password agent (symlinked to ~/.ssh/config)
  vscode/settings.json         # VSCode settings (symlinked)
  vscode/keybindings.json      # VSCode keybindings (symlinked)
  claude/settings.json         # Claude Code settings (symlinked to ~/.claude/settings.json)
  mcp/.mcp.json                # MCP server config for Claude Code / Copilot CLI
  vscode/mcp.json              # MCP server config for VS Code Copilot
  warp/                        # Warp terminal configs (symlinked to ~/.warp)
docs/
  TODO.md                      # Pending setup tasks and recommendations
  MANUAL_SETUP.md              # Manual steps for new machine provisioning
  TELEMETRY.md                 # Org-level AI telemetry gap analysis
telemetry/
  deploy.sh                    # Deploy full telemetry stack
  teardown.sh                  # Tear down full telemetry stack
  base/                        # Kustomize resources (namespace, ingress, dashboard ConfigMaps)
  helm-values/                 # Helm values for Grafana stack + OTEL Collector
```

## Adding a new tool

1. Add the brew/cask entry to `Brewfile`
2. Add any config files under `configs/<tool>/`
3. Add symlink entries in `scripts/symlinks.sh`
4. If the tool needs custom install logic beyond brew, add a script in `scripts/`
   and add it to the loop in `setup.sh`

## Git multi-account setup

Git identity is automatically selected based on repo directory:

| Directory | Identity | Account |
|-----------|----------|---------|
| `~/Dev/git/albertagustin/` | albertagustin@gmail.com | Personal |
| `~/Dev/git/community/` | albertagustin@gmail.com | Personal |
| `~/Dev/git/prog-leasing-llc/` | albert.agustin@progleasing.com | Work |
| `~/Dev/git/prog-leasing-llc-legacy/` | albert.agustin@progleasing.com | Work |

To add a new org, add an `[includeIf]` block in `configs/git/.gitconfig`.

SSH keys are managed via the 1Password SSH agent. Host aliases:
- `github.com` — work account (default)
- `github.com-personal` — personal account

Personal repos must use `git@github.com-personal:` as the remote URL.

## Related repos

| Repo | Location | Purpose |
|------|----------|---------|
| `obsidian-vaults` | `~/Dev/git/albertagustin/obsidian-vaults` | Work notes and journal (Obsidian) |
| `ai-files` | `~/Dev/git/albert-agustin_progtech/ai-files` | AI skills, prompts, agents, hooks |
