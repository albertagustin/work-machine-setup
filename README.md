# Work Machine Assistant

Dotfiles, setup scripts, and daily work tools for a macOS work machine. Run one script to install everything, symlink all configs, and be ready to go.

## Prerequisites

- macOS (Apple Silicon)
- [Homebrew](https://brew.sh) installed
- [1Password](https://1password.com) with SSH agent enabled

## Quick Start

```bash
git clone git@github.com-personal:albertagustin/work-machine-assistant.git ~/Dev/git/albertagustin/work-machine-assistant
cd ~/Dev/git/albertagustin/work-machine-assistant
cp .envrc.example .envrc  # Add your secrets
./setup.sh
```

Then restart your terminal.

## What Gets Installed

### CLI Tools

| Tool | Description |
|------|-------------|
| zsh | Homebrew-managed shell |
| Oh My Zsh | ZSH framework + plugins (autosuggestions, syntax-highlighting) |
| starship | Terminal prompt with git, k8s, and language info |
| git / gh | Version control + GitHub CLI |
| kubectl | Kubernetes CLI |
| awscli | AWS CLI |
| pyenv | Python version manager |
| fnm | Fast Node version manager |
| direnv | Per-directory env vars (.envrc) |
| jq / yq | JSON/YAML processors |
| bat | Syntax-highlighted `cat` |
| ripgrep | Fast `grep` replacement (`rg`) |
| fd | Fast `find` replacement |
| eza | Modern `ls` with icons |
| zoxide | Smarter `cd` / `z` |
| htop / wget / curl / tree | Utilities |

### Applications

| App | Description |
|-----|-------------|
| Warp | Terminal |
| Visual Studio Code | IDE |
| Arc | Browser |
| 1Password | Password manager |
| Claude | AI assistant (desktop) |
| Rancher Desktop | Container runtime + local Kubernetes |
| Alfred | Spotlight replacement |
| Rectangle | Window management |
| Ice | Menu bar icon management |
| Dropbox | Cloud storage |

### Fonts

- FiraCode Nerd Font — used in terminal and editor for icons/ligatures

## How It Works

1. **`setup.sh`** runs each script in `scripts/` in order
2. **`scripts/brew.sh`** installs everything from `Brewfile`
3. **`scripts/zsh.sh`** installs Oh My Zsh and third-party plugins
4. **`scripts/symlinks.sh`** symlinks all config files from this repo to their expected locations (`~/.zshrc`, `~/.gitconfig`, `~/.config/starship.toml`, etc.)

Config files in this repo are the **source of truth** — edit them here, and the symlinks keep everything in sync.

## Git Multi-Account Setup

Git identity switches automatically based on which directory you're in:

| Directory | Email | Account |
|-----------|-------|---------|
| `~/Dev/git/albertagustin/` | albertagustin@gmail.com | Personal |
| `~/Dev/git/community/` | albertagustin@gmail.com | Personal |
| `~/Dev/git/prog-leasing-llc/` | albert.agustin@progleasing.com | Work |
| `~/Dev/git/prog-leasing-llc-legacy/` | albert.agustin@progleasing.com | Work |

SSH keys are stored in 1Password and mapped via SSH bookmarks:
- **`github.com`** — work account (default)
- **`github.com-personal`** — personal account

## Adding a New Tool

1. Add the brew/cask entry to `Brewfile`
2. Add config files under `configs/<tool>/`
3. Add symlink entries in `scripts/symlinks.sh`
4. If it needs custom install logic, add a script in `scripts/` and reference it in `setup.sh`

## Shell Aliases

### General
| Alias | Command |
|-------|---------|
| `cat` | `bat` |
| `ls` | `eza --icons` |
| `ll` | `eza --icons -la` |
| `lt` | `eza --icons --tree --level=2` |
| `k` | `kubectl` |

### Git
| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `gp` | `git pull` |
| `gpu` | `git push` |
| `gl` | `git log` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gaa` | `git add -A :/` |
| `gc` | `git commit` |
| `gcm` | `git commit -m` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
