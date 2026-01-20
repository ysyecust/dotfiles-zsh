# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                         Zsh Configuration                                   ║
# ║                    https://github.com/shaoyiyang/dotfiles-zsh               ║
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

# fzf appearance and preview
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border rounded
  --preview-window=right:50%:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)'
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

# ================================
# Lazy Loading (for faster startup)
# ================================

# NVM lazy loading (saves ~300ms startup time)
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
