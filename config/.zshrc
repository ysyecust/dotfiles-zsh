# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                         Zsh Configuration                                   ║
# ║                    https://github.com/ysyecust/dotfiles-zsh               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Deduplicate PATH and fpath entries automatically
typeset -U path fpath

# ================================
# Early PATH & Homebrew Setup
# ================================
# Fast static setup for Apple Silicon Homebrew (avoids ~30ms `brew shellenv` fork)
# Placed before Instant Prompt & Zim so Homebrew completions and tools are in fpath/PATH
if [[ -d "/opt/homebrew" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  path=("/opt/homebrew/bin" "/opt/homebrew/sbin" $path)
  fpath=("/opt/homebrew/share/zsh/site-functions" $fpath)
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

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

# Register optional tool completion directories before Zim initializes compinit.
[[ -d "$HOME/.grok/completions/zsh" ]] && fpath=("$HOME/.grok/completions/zsh" $fpath)
[[ -d "$HOME/.bun" ]] && fpath=("$HOME/.bun" $fpath)

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
# Environment Variables & PATH
# ================================

# GNU coreutils (prefer GNU tools when installed via Homebrew)
[[ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]] && path=("/opt/homebrew/opt/coreutils/libexec/gnubin" $path)

# LLVM / Clang tooling
if [[ -d "/opt/homebrew/opt/llvm" ]]; then
  export LLVM_HOME="/opt/homebrew/opt/llvm"
  [[ -d "$LLVM_HOME/bin" ]] && path=("$LLVM_HOME/bin" $path)
  [[ -f "$LLVM_HOME/lib/libclang.dylib" ]] && export LIBCLANG_PATH="$LLVM_HOME/lib/libclang.dylib"
fi

# Bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  path=("$BUN_INSTALL/bin" $path)
fi

# pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  path=("$PNPM_HOME" "$PNPM_HOME/bin" $path)
fi

# Juliaup
[[ -d "$HOME/.juliaup/bin" ]] && path=("$HOME/.juliaup/bin" $path)
[[ -f "$HOME/.julia/juliaup/completions/zsh.zsh" ]] && source "$HOME/.julia/juliaup/completions/zsh.zsh"

# CLI & AI Agent Bins (OpenCode, Grok, Antigravity IDE, DeepSeek Harness, ~/.local/bin)
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)
[[ -d "$HOME/.grok/bin" ]] && path=("$HOME/.grok/bin" $path)
[[ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ]] && path=("$HOME/.antigravity-ide/antigravity-ide/bin" $path)
[[ -d "/Applications/DeepSeek Harness.app/Contents/Resources/runtime/cli/bin" ]] && \
  path=("/Applications/DeepSeek Harness.app/Contents/Resources/runtime/cli/bin" $path)
path=("$HOME/.local/bin" $path)
export PATH

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

# Docker container shell (renamed from dsh to dksh to avoid shadowing DeepSeek Harness CLI)
unfunction dsh 2>/dev/null
dksh() {
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

# Cache directory for generated tool init scripts (saves ~150ms startup time)
_ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_ZSH_CACHE_DIR" ]] || mkdir -p "$_ZSH_CACHE_DIR"

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
if (( $+commands[mise] )); then
  [[ -d "$HOME/.local/share/mise/shims" ]] && path=("$HOME/.local/share/mise/shims" $path)
  _mise_cache="$_ZSH_CACHE_DIR/mise-activate.zsh"
  if [[ ! -f "$_mise_cache" || "${commands[mise]}" -nt "$_mise_cache" ]]; then
    mise activate zsh | sed -e '/^export PATH=/d' -e '/^_mise_hook --force$/d' >| "$_mise_cache"
  fi
  source "$_mise_cache"
  unset _mise_cache
fi

# --- tldr (simplified man pages) ---
alias help='tldr'

# ================================
# Lazy Loading (for faster startup)
# ================================

# NVM lazy loading (saves ~300ms startup time)
# Note: If using mise, you can remove nvm entirely
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  _load_nvm() {
    (( $_nvm_loaded )) && return
    _nvm_loaded=1
    unset -f nvm node npm npx 2>/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  }
  nvm()  { _load_nvm; nvm "$@"; }
  node() { _load_nvm; node "$@"; }
  npm()  { _load_nvm; npm "$@"; }
  npx()  { _load_nvm; npx "$@"; }
  # Expose default global npm bin (lark-cli, etc.) in PATH immediately using pure zsh glob
  if [[ -r "$NVM_DIR/alias/default" ]]; then
    _nvm_default_ver="$(<"$NVM_DIR/alias/default")"
    _nvm_default_bins=("$NVM_DIR"/versions/node/v${_nvm_default_ver}*/bin(NOn))
    (( ${#_nvm_default_bins} )) && path=("${_nvm_default_bins[1]}" $path)
    unset _nvm_default_ver _nvm_default_bins
  fi
fi

# ================================
# Final Initializations
# ================================

# zoxide (must be at the end)
if (( $+commands[zoxide] )); then
  _zoxide_cache="$_ZSH_CACHE_DIR/zoxide-init.zsh"
  if [[ ! -f "$_zoxide_cache" || "${commands[zoxide]}" -nt "$_zoxide_cache" ]]; then
    zoxide init zsh >| "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi
unset _ZSH_CACHE_DIR

# Powerlevel10k configuration
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Otty shell integration (inert unless launched by Otty)
if [[ -n "$ZSH_VERSION" && -n "$OTTY_SHELL_INTEGRATION" && -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi

# ================================
# Local Configuration (optional)
# ================================
# Source local config if exists (for machine-specific settings and secrets)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ================================
# Terminal Startup Display
# ================================

# Tips array for daily tips
TIPS=(
  "💡 Ctrl+T 搜索文件 │ Ctrl+R 搜索历史 │ Alt+C 跳转目录"
  "💡 z <dir> 智能跳转 │ zi 交互选择 │ zoxide 会学习你的习惯"
  "💡 lg 打开 lazygit │ y 打开 yazi 文件管理器"
  "💡 ll 详细列表 │ lt 树形显示 │ la 显示隐藏文件"
  "💡 Ctrl+G Ctrl+B 搜索分支 │ Ctrl+G Ctrl+H 搜索提交历史"
  "💡 bm add <名称> 添加书签 │ bm 选择书签 │ bm list 列出"
  "💡 fssh 选择 SSH 连接 │ dksh 进入容器 │ ksh 进入 Pod"
  "💡 notify <命令> 完成后通知 │ serve 8080 快速 HTTP 服务"
  "💡 fe 搜索编辑 │ fcd 搜索进入目录 │ fbr 切换分支 │ fkill 杀进程"
  "💡 d/dc Docker │ k Kubectl │ dps/kgp 查看状态"
  "💡 cat 语法高亮 │ ../... 返回上级 │ mkcd 创建并进入"
  "💡 tmux: Ctrl+B | 垂直分割 │ Ctrl+B - 水平 │ Ctrl+B g lazygit"
  "💡 ↑/↓ 历史子串搜索 │ → 接受自动建议 │ Ctrl+/ 切换预览"
)

# Show tips command - display full cheatsheet
tips() {
  # Disable pager for direct output
  PAGER=cat cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════════════════╗
║                           🚀 Terminal Cheatsheet                              ║
╚═══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 🔍 FZF 模糊搜索                                                                 │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ Ctrl+T           │ 搜索文件并插入路径                                           │
│ Ctrl+R           │ 搜索命令历史                                                 │
│ Alt+C            │ 搜索目录并跳转                                               │
│ Tab              │ fzf-tab 补全菜单                                             │
│ Ctrl+/           │ 切换预览窗口                                                 │
│ Ctrl+Y           │ 复制选中项到剪贴板                                           │
├──────────────────┼──────────────────────────────────────────────────────────────┤
│ fe               │ 搜索文件并用编辑器打开                                       │
│ fcd              │ 搜索目录并进入                                               │
│ fbr              │ 搜索并切换 Git 分支                                          │
│ fkill            │ 搜索并杀死进程                                               │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 🌿 FZF-GIT 快捷键 (需在 Git 仓库中)                                             │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ Ctrl+G Ctrl+F    │ 搜索 Git 文件                                                │
│ Ctrl+G Ctrl+B    │ 搜索分支                                                     │
│ Ctrl+G Ctrl+T    │ 搜索标签                                                     │
│ Ctrl+G Ctrl+H    │ 搜索提交历史 (Hashes)                                        │
│ Ctrl+G Ctrl+R    │ 搜索远程仓库                                                 │
│ Ctrl+G Ctrl+S    │ 搜索 Stash                                                   │
│ Ctrl+G Ctrl+E    │ 搜索所有引用                                                 │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 📁 文件操作 (eza/bat/yazi)                                                      │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ ls               │ 基本列表 (带图标)                                            │
│ ll               │ 详细列表 (权限/大小/Git状态)                                 │
│ la               │ 详细列表 (含隐藏文件)                                        │
│ lt               │ 树形显示 (2层)                                               │
│ lta              │ 树形显示 (3层, 含隐藏)                                       │
│ cat / catn       │ 语法高亮查看 / 带行号                                        │
│ y                │ yazi 文件管理器 (退出时 cd 到所在目录)                       │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 📍 目录导航 (zoxide/bookmarks)                                                  │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ z <dir>          │ 智能跳转到匹配目录                                           │
│ z foo bar        │ 跳转到同时包含 foo 和 bar 的目录                             │
│ zi               │ 交互式选择历史目录                                           │
│ ..               │ cd ..                                                        │
│ ...              │ cd ../..                                                     │
│ ....             │ cd ../../..                                                  │
│ mkcd <dir>       │ 创建目录并进入                                               │
├──────────────────┼──────────────────────────────────────────────────────────────┤
│ bm add <name>    │ 将当前目录添加为书签                                         │
│ bm <name>        │ 跳转到指定书签                                               │
│ bm               │ fzf 选择书签跳转                                             │
│ bm list          │ 列出所有书签                                                 │
│ bm rm <name>     │ 删除书签                                                     │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 🌿 Git 操作 (lazygit/aliases)                                                   │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ lg               │ 打开 lazygit 终端 UI                                         │
│ gs               │ git status -sb (简洁状态)                                    │
│ gd               │ git diff (未暂存更改)                                        │
│ gds              │ git diff --staged (已暂存更改)                               │
│ gl               │ git log --oneline -20                                        │
│ gla              │ git log --all --graph -20                                    │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 🐳 Docker                                                                       │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ d                │ docker                                                       │
│ dc               │ docker compose                                               │
│ dps              │ 格式化显示运行中的容器                                       │
│ dpsa             │ 显示所有容器 (含停止的)                                      │
│ dim              │ docker images                                                │
│ dex <name>       │ docker exec -it <name>                                       │
│ dlogs <name>     │ docker logs -f <name>                                        │
│ dksh             │ fzf 选择容器并进入 shell                                     │
│ dprune           │ 清理所有未使用的资源                                         │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ ☸️  Kubernetes                                                                   │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ k                │ kubectl                                                      │
│ kgp              │ kubectl get pods                                             │
│ kgs              │ kubectl get svc                                              │
│ kgd              │ kubectl get deployments                                      │
│ kga              │ kubectl get all                                              │
│ kd <resource>    │ kubectl describe                                             │
│ kl <pod>         │ kubectl logs -f                                              │
│ kex <pod>        │ kubectl exec -it                                             │
│ ksh              │ fzf 选择 pod 并进入 shell                                    │
│ kctx             │ 切换 context                                                 │
│ kns              │ 切换 namespace                                               │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ ⌨️  Tmux 快捷键 (前缀: Ctrl+B)                                                   │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ |                │ 垂直分割窗口                                                 │
│ -                │ 水平分割窗口                                                 │
│ h / j / k / l    │ 在窗格间导航 (左/下/上/右)                                   │
│ H / J / K / L    │ 调整窗格大小                                                 │
│ c                │ 新建窗口                                                     │
│ x                │ 关闭当前窗格                                                 │
│ X                │ 关闭当前窗口                                                 │
│ z                │ 最大化/还原窗格                                              │
│ d                │ 脱离会话 (后台运行)                                          │
│ g                │ 打开 lazygit 弹窗                                            │
│ y                │ 打开 yazi 弹窗                                               │
│ t                │ 打开 htop 弹窗                                               │
│ r                │ 重新加载配置                                                 │
│ [                │ 进入复制模式 (vi 键位)                                       │
│ ]                │ 粘贴                                                         │
├──────────────────┼──────────────────────────────────────────────────────────────┤
│ tmux             │ 启动新会话                                                   │
│ tmux a           │ 重新连接会话                                                 │
│ tmux ls          │ 列出所有会话                                                 │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 🛠  实用工具                                                                     │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ fssh             │ fzf 选择 SSH 连接 (从 ~/.ssh/config)                         │
│ serve [port]     │ 快速启动 HTTP 服务器 (默认 8000)                             │
│ notify <cmd>     │ 执行命令, 完成后发送系统通知                                 │
│ notify-done      │ 发送完成通知 (配合 &&)                                       │
│ extract <file>   │ 自动解压各种格式                                             │
│ myip             │ 显示公网 IP                                                  │
│ ports            │ 显示监听端口                                                 │
│ path             │ 显示 PATH (每行一个)                                         │
│ week             │ 显示当前周数                                                 │
│ help <cmd>       │ tldr 简化版 man                                              │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 🔧 版本管理 (mise)                                                              │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ mise use node@20 │ 安装并使用 Node.js 20                                        │
│ mise use python  │ 安装并使用最新 Python                                        │
│ mise use go@1.22 │ 安装并使用 Go 1.22                                           │
│ mise list        │ 列出已安装版本                                               │
│ mise use --pin   │ 固定版本到 .mise.toml                                        │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ ⚡ Zsh 行编辑                                                                    │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ ↑ / ↓            │ 历史子串搜索 (输入部分命令后)                                │
│ →                │ 接受自动建议                                                 │
│ Ctrl+E           │ 接受建议到行尾                                               │
│ Ctrl+W           │ 删除前一个单词                                               │
│ Ctrl+U           │ 删除到行首                                                   │
│ Ctrl+A / Ctrl+E  │ 跳到行首 / 行尾                                              │
│ Esc              │ 进入 vi normal 模式                                          │
└──────────────────┴──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│ 💾 配置管理                                                                     │
├──────────────────┬──────────────────────────────────────────────────────────────┤
│ reload           │ 重新加载 ~/.zshrc                                            │
│ tips             │ 显示此帮助                                                   │
│ p10k configure   │ 重新配置 Powerlevel10k 主题                                  │
│ zimfw update     │ 更新 Zim 模块                                                │
├──────────────────┼──────────────────────────────────────────────────────────────┤
│ ~/dotfiles-zsh/install.sh    │ 一键安装                                         │
│ ~/dotfiles-zsh/update.sh     │ 更新工具和配置                                   │
│ ~/dotfiles-zsh/uninstall.sh  │ 卸载                                             │
└──────────────────┴──────────────────────────────────────────────────────────────┘

EOF
}

# Show system info and daily tip only in direct interactive terminal sessions
# (Skipped for `zsh -i -c ...` subshells, non-TTY pipes, and AI coding agents)
if [[ -o interactive && -t 1 && -z $ZSH_EXECUTION_STRING && -z $CODEX_THREAD_ID && -z $ANTIGRAVITY_CLI_ALIAS ]]; then
  if (( $+commands[fastfetch] )); then
    fastfetch --logo small
  fi
  echo ""
  echo "${TIPS[$RANDOM % ${#TIPS[@]} + 1]}"
  echo "    输入 tips 查看完整快捷键列表"
  echo ""
fi
