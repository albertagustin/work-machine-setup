# ==============================================================================
# Work Machine .zshrc
# Managed via: https://github.com/albertagustin/work-machine-setup
# ==============================================================================

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — using Starship prompt instead

plugins=(
  git
  kubectl
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# --- Starship prompt ---
eval "$(starship init zsh)"

# --- direnv (loads .envrc files automatically) ---
eval "$(direnv hook zsh)"

# --- Secrets (.envrc in repo root) ---
REPO_DIR="$HOME/Dev/git/albertagustin/work-machine-setup"
if [ -f "$REPO_DIR/.envrc" ]; then
  # direnv handles this automatically when you cd into the repo,
  # but we also source it at shell start for global availability.
  set -a
  source "$REPO_DIR/.envrc"
  set +a
fi

# --- PATH additions ---
# Add custom bin directories here as needed:
# export PATH="$HOME/.local/bin:$PATH"

# --- pyenv (Python version manager) ---
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# --- fnm (Node version manager) ---
eval "$(fnm env --use-on-cd)"

# --- zoxide (smarter cd / z replacement) ---
eval "$(zoxide init zsh)"

# --- Aliases ---
alias k="kubectl"
alias code="code"
alias cat="bat"
alias ls="eza --icons"
alias ll="eza --icons -la"
alias lt="eza --icons --tree --level=2"

# Git
alias gs="git status"
alias gp="git pull"
alias gl="git log"
alias gaa="git add -A :/"
alias gpu="git push"
alias gc="git commit"
alias gcm="git commit -m"
alias gco="git checkout"
alias gb="git branch"
alias gd="git diff"
alias gds="git diff --staged"
