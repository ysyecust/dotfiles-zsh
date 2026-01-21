# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                         Zsh Configuration                                   ║
# ║                    https://github.com/ysyecust/dotfiles-zsh               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# ================================
# Powerlevel10k Instant Prompt
# ================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ================================
# Zim Framework Initialization
# ================================

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Set editor default keymap to vi
bindkey -v

# Prompt for spelling correction of commands.
setopt CORRECT

# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# Set what highlighters will be used.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# Set a custom path for the completion dump file.
zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

# zsh-history-substring-search
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# ================================
# Environment Variables
# ================================

# Homebrew (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Local bin (for Claude CLI, etc.)
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR='nvim'
export VISUAL='nvim'

# History settings
export HISTSIZE=50000
export SAVEHIST=50000

# ================================
# Terminal Enhancements
# ================================

# --- fzf configuration ---
# Use fd for faster file search
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# fzf appearance and preview (Catppuccin Mocha theme)
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border rounded
  --preview-window=right:50%:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)'
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=border:#6c7086
  --prompt='  '
  --pointer='▶'
  --marker='✓'
"

# File preview with bat
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}'
"

# Directory preview with eza
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {} 2>/dev/null'
"

# History search options
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=down:3:wrap
"

# ================================
# Aliases
# ================================

# --- eza (modern ls) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias lta='eza --tree --level=3 --icons -a'

# --- bat (modern cat) ---
alias cat='bat --style=plain'
alias catn='bat'  # with line numbers

# --- Quick navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Git shortcuts ---
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline -20'
alias gla='git log --oneline --all --graph -20'

# --- Utility ---
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias ports='lsof -i -P -n | grep LISTEN'
alias cls='clear'
alias week='date +%V'  # Current week number
alias myip='curl -s ifconfig.me'  # Public IP

# --- Docker shortcuts ---
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'
alias dim='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'

# --- Kubernetes shortcuts ---
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kex='kubectl exec -it'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# ================================
# Functions
# ================================

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Quick file search with fzf and open in editor
fe() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git | fzf --preview 'bat --style=numbers --color=always --line-range :300 {}')
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# Quick directory jump with fzf
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'eza --tree --level=2 --color=always {}')
  [[ -n "$dir" ]] && cd "$dir"
}

# Git branch switch with fzf
fbr() {
  local branch
  branch=$(git branch -a | fzf --preview 'git log --oneline --color=always {}' | sed 's/^[* ]*//' | sed 's/remotes\/origin\///')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# Kill process with fzf
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -9
}

# Extract various archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# SSH connection with fzf
# Parses ~/.ssh/config for hosts
fssh() {
  local host
  host=$(grep -E "^Host\s+" ~/.ssh/config 2>/dev/null | grep -v "\*" | awk '{print $2}' | fzf --prompt="SSH> " --preview 'grep -A 5 "^Host {}" ~/.ssh/config')
  [[ -n "$host" ]] && ssh "$host"
}

# Project bookmarks - quick jump to favorite directories
# Add bookmarks: bm add <name>
# Jump to bookmark: bm <name>
# List bookmarks: bm list
# Remove bookmark: bm rm <name>
BOOKMARKS_FILE="$HOME/.bookmarks"
bm() {
  case "$1" in
    add)
      if [[ -z "$2" ]]; then
        echo "Usage: bm add <name>"
        return 1
      fi
      echo "$2|$PWD" >> "$BOOKMARKS_FILE"
      echo "Bookmark '$2' added for $PWD"
      ;;
    rm)
      if [[ -z "$2" ]]; then
        echo "Usage: bm rm <name>"
        return 1
      fi
      if [[ -f "$BOOKMARKS_FILE" ]]; then
        sed -i '' "/^$2|/d" "$BOOKMARKS_FILE"
        echo "Bookmark '$2' removed"
      fi
      ;;
    list)
      if [[ -f "$BOOKMARKS_FILE" ]]; then
        cat "$BOOKMARKS_FILE" | column -t -s '|'
      else
        echo "No bookmarks found"
      fi
      ;;
    "")
      # Interactive selection with fzf
      if [[ -f "$BOOKMARKS_FILE" ]]; then
        local selected
        selected=$(cat "$BOOKMARKS_FILE" | fzf --prompt="Bookmark> " -d '|' --preview 'eza --tree --level=1 --color=always {2}' | cut -d'|' -f2)
        [[ -n "$selected" ]] && cd "$selected"
      else
        echo "No bookmarks found. Use 'bm add <name>' to add one."
      fi
      ;;
    *)
      # Direct jump by name
      if [[ -f "$BOOKMARKS_FILE" ]]; then
        local dir
        dir=$(grep "^$1|" "$BOOKMARKS_FILE" | cut -d'|' -f2)
        if [[ -n "$dir" ]]; then
          cd "$dir"
        else
          echo "Bookmark '$1' not found"
        fi
      fi
      ;;
  esac
}

# Long command notification (for commands > 10 seconds)
# Usage: notify <command>
# Or: <command> && notify-done
notify() {
  local start_time=$(date +%s)
  eval "$@"
  local exit_code=$?
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))
  if [[ $duration -gt 10 ]]; then
    osascript -e "display notification \"Command finished in ${duration}s\" with title \"Terminal\" sound name \"Glass\""
  fi
  return $exit_code
}

notify-done() {
  osascript -e "display notification \"Command completed\" with title \"Terminal\" sound name \"Glass\""
}

# Quick HTTP server in current directory
serve() {
  local port="${1:-8000}"
  echo "Serving on http://localhost:$port"
  python3 -m http.server "$port"
}

# Docker container shell
dsh() {
  local container
  container=$(docker ps --format "{{.Names}}" | fzf --prompt="Container> ")
  [[ -n "$container" ]] && docker exec -it "$container" sh -c "bash || sh"
}

# Kubernetes pod shell
ksh() {
  local pod
  pod=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Pod> ")
  [[ -n "$pod" ]] && kubectl exec -it "$pod" -- sh -c "bash || sh"
}

# ================================
# Tool Integrations
# ================================

# --- lazygit ---
alias lg='lazygit'

# --- yazi (file manager) ---
# Use 'y' to open yazi and cd to the directory when exiting
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# --- fzf-git.sh (enhanced git operations) ---
# Keybindings:
#   Ctrl+G Ctrl+F - Files
#   Ctrl+G Ctrl+B - Branches
#   Ctrl+G Ctrl+T - Tags
#   Ctrl+G Ctrl+R - Remotes
#   Ctrl+G Ctrl+H - Hashes (commits)
#   Ctrl+G Ctrl+S - Stashes
#   Ctrl+G Ctrl+L - Reflogs
#   Ctrl+G Ctrl+W - Worktrees
#   Ctrl+G Ctrl+E - Each ref
[[ -f ~/.config/fzf-git.sh ]] && source ~/.config/fzf-git.sh

# --- mise (version manager for Node, Python, Go, etc.) ---
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# --- tldr (simplified man pages) ---
alias help='tldr'

# ================================
# Claude CLI Integration
# ================================

# Claude Code headless mode helpers
# Usage: ask "your question here"
ask() {
  if [[ -z "$1" ]]; then
    echo "Usage: ask \"your question\""
    return 1
  fi
  claude -p "$*"
}

# Ask Claude with file context
# Usage: askf file.py "explain this code"
askf() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: askf <file> \"your question\""
    return 1
  fi
  local file="$1"
  shift
  cat "$file" | claude -p "$*"
}

# Ask Claude to generate code
# Usage: gen "create a python script that..."
gen() {
  if [[ -z "$1" ]]; then
    echo "Usage: gen \"description of what to generate\""
    return 1
  fi
  claude -p "Generate code: $*"
}

# Ask Claude to explain a command
# Usage: explain "ls -la"
explain() {
  if [[ -z "$1" ]]; then
    echo "Usage: explain \"command\""
    return 1
  fi
  claude -p "Explain this shell command in detail: $*"
}

# Ask Claude to fix an error
# Usage: fix "error message"
fix() {
  if [[ -z "$1" ]]; then
    echo "Usage: fix \"error message\""
    return 1
  fi
  claude -p "How do I fix this error: $*"
}

# Pipe command output to Claude for analysis
# Usage: some_command | ask-pipe "analyze this output"
ask-pipe() {
  local prompt="${1:-Analyze this output}"
  claude -p "$prompt"
}

# Git commit message generator
# Usage: gcm (generates commit message based on staged changes)
gcm() {
  local diff=$(git diff --cached)
  if [[ -z "$diff" ]]; then
    echo "No staged changes found. Use 'git add' first."
    return 1
  fi
  echo "$diff" | claude -p "Generate a concise git commit message for these changes. Output only the commit message, nothing else."
}

# Code review helper
# Usage: review file.py
review() {
  if [[ -z "$1" ]]; then
    echo "Usage: review <file>"
    return 1
  fi
  cat "$1" | claude -p "Review this code. Point out potential bugs, security issues, and suggest improvements."
}

# ================================
# Lazy Loading (for faster startup)
# ================================

# NVM lazy loading (saves ~300ms startup time)
# Note: If using mise, you can remove nvm entirely
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
  }
  node() { nvm use default &>/dev/null; unset -f node; node "$@"; }
  npm() { nvm use default &>/dev/null; unset -f npm; npm "$@"; }
  npx() { nvm use default &>/dev/null; unset -f npx; npx "$@"; }
fi

# ================================
# Final Initializations
# ================================

# zoxide (must be at the end)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Powerlevel10k configuration
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ================================
# Local Configuration (optional)
# ================================
# Source local config if exists (for machine-specific settings)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ================================
# Terminal Startup Display
# ================================
# Show system info on terminal startup (only for interactive shells)
if [[ $- == *i* ]] && command -v fastfetch &> /dev/null; then
  fastfetch --logo small
fi
