# Manual Setup Steps

Steps that can't be fully automated and need to be done manually when provisioning a new machine. Run `./setup.sh` first, then follow these steps.

## 1. Homebrew

Install Homebrew before running anything else:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. ZSH — Set Homebrew ZSH as default shell

```bash
sudo sh -c 'echo /opt/homebrew/bin/zsh >> /etc/shells'
chsh -s /opt/homebrew/bin/zsh
```

Restart terminal after this.

## 3. 1Password SSH Agent

1. Open **1Password > Settings > Developer**
2. Enable **SSH Agent**
3. Enable **Developer mode**
4. Create two SSH keys:
   - **Github Personal SSH Key** in the `Personal` vault
   - **Github Work SSH Key** in the `Work` vault
5. For each key, add a **website field** (not custom field) with the SSH bookmark URL:
   - Personal key: `ssh://github.com-personal`
   - Work key: `ssh://github.com`
6. Enable **"Generate SSH config files from 1Password SSH bookmarks"** in Settings > Developer
7. Restart 1Password to generate `~/.ssh/1Password/config`

## 4. GitHub SSH Keys

For each GitHub account, add the public key as **both** Authentication and Signing key:

**Personal account (albertagustin):**
1. Go to https://github.com/settings/keys
2. Add the personal SSH public key as Authentication key
3. Add the same key as Signing key

**Work account (albert-agustin_progtech):**
1. Log into the work GitHub account
2. Go to https://github.com/settings/keys
3. Add the work SSH public key as Authentication key
4. Add the same key as Signing key

Verify with:
```bash
ssh -T git@github.com           # Should show work account
ssh -T git@github.com-personal  # Should show personal account
```

## 5. GitHub CLI Authentication

```bash
gh auth login
```

Choose GitHub.com, SSH, and your personal key.

## 6. Alfred — Replace Spotlight

1. Open **System Settings > Keyboard > Keyboard Shortcuts > Spotlight**
2. Uncheck "Show Spotlight search" (Cmd+Space)
3. Open **Alfred Preferences > General**
4. Set Alfred hotkey to Cmd+Space

### Custom web searches

Add these in Alfred Preferences > Features > Web Search > Add Custom Search:

| Keyword | URL |
|---------|-----|
| `ghl` | `https://github.com/orgs/Prog-Leasing-LLC-Legacy/repositories?q={query}` |
| `gh` | `https://github.com/orgs/Prog-Leasing-LLC/repositories?q={query}` |

## 7. Warp Terminal

After first launch, set the font to **FiraCode Nerd Font Mono** in Warp Settings > Appearance > Font.

Set the shell to default (should pick up `/opt/homebrew/bin/zsh` from `chsh`).

## 8. Mac App Store Apps

These require `sudo` which can't be run through Claude Code:

```bash
mas install 937984704   # Amphetamine
```

Or install directly from the App Store app.

## 9. Logi Options+

Requires `sudo` for installation:

```bash
brew install --cask logi-options+
```

Reboot after installation.

## 10. Rancher Desktop

After first launch:
- Rancher Desktop may add a PATH entry to `.zshrc` — this is already managed in our `.zshrc` under PATH additions, so delete the auto-generated block if it appears
- The k8s cluster starts automatically

## 11. /etc/hosts — Local DNS

Add entries for the telemetry stack Traefik ingress:

```bash
sudo sh -c 'echo "127.0.0.1  grafana.local otel.local" >> /etc/hosts'
```

## 12. direnv — Allow .envrc

After creating `.envrc` from `.envrc.example`:

```bash
cd ~/Dev/git/albertagustin/work-machine-assistant
direnv allow
```

## 13. Claude Code Plugins

Plugins can't be installed declaratively — they must be installed via the CLI. The `enabledPlugins` setting in `configs/claude/settings.json` controls which are active, but installation is manual.

```bash
# In any Claude Code session:
/plugin install skill-creator@claude-plugins-official
```

## 14. Obsidian

1. Clone the vault repo: `git clone git@github.com-personal:albertagustin/obsidian-vaults.git ~/Dev/git/albertagustin/obsidian-vaults`
2. Open Obsidian > "Open folder as vault" > point to `~/Dev/git/albertagustin/obsidian-vaults`
