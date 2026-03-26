# Work Machine Setup

Dotfiles and setup scripts for provisioning a macOS work machine.

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
  warp/                        # Warp terminal configs (symlinked to ~/.warp)
docs/
  TODO.md                      # Pending setup tasks and recommendations
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

## Secrets

**DO NOT COMMIT SECRETS — no API keys, tokens, passwords, or credentials should ever be committed to this repo, under any circumstances.**

Secrets go in `.envrc` (gitignored). Copy `.envrc.example` as a starting point.
They are loaded via direnv and also sourced in `.zshrc` on shell start.
