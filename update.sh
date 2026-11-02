#!/bin/bash
#
# Update script for dotfiles-zsh
# Updates core terminal tools, Zim plugins, and configurations
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CORE_PACKAGES=(
    "zoxide"
    "eza"
    "bat"
    "fd"
    "ripgrep"
    "fzf"
    "lazygit"
    "yazi"
    "tmux"
    "mise"
    "fastfetch"
)

backup_config() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        print_warning "Backed up $file to $backup"
    fi
}

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Dotfiles-zsh Update                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Pull latest dotfiles first
print_step "Pulling latest dotfiles..."
cd "$SCRIPT_DIR"
git pull origin main 2>/dev/null || print_warning "Could not pull latest changes (working tree may have local modifications)"
print_success "Dotfiles repository checked"

# Update core Homebrew packages only (avoid upgrading unrelated heavy toolchains)
if command -v brew &> /dev/null; then
    print_step "Updating core Homebrew terminal packages..."
    brew upgrade "${CORE_PACKAGES[@]}" 2>/dev/null || true
    print_success "Core Homebrew packages updated"
fi

# Update fzf-git.sh in both repo and ~/.config
print_step "Updating fzf-git.sh..."
mkdir -p "${HOME}/.config"
if curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o "${SCRIPT_DIR}/config/fzf-git.sh"; then
    cp "${SCRIPT_DIR}/config/fzf-git.sh" "${HOME}/.config/fzf-git.sh"
    print_success "fzf-git.sh updated"
else
    print_warning "Could not download latest fzf-git.sh"
fi

# Offer to sync config files before running zimfw
echo ""
read -p "Sync config files (.zshrc, .zimrc, .tmux.conf) from repo to ~? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    backup_config "${HOME}/.zshrc"
    backup_config "${HOME}/.zimrc"
    backup_config "${HOME}/.tmux.conf"
    cp "$SCRIPT_DIR/config/.zshrc" ~/.zshrc
    cp "$SCRIPT_DIR/config/.zimrc" ~/.zimrc
    cp "$SCRIPT_DIR/config/.tmux.conf" ~/.tmux.conf
    cp "$SCRIPT_DIR/config/fzf-git.sh" ~/.config/fzf-git.sh
    print_success "Config files synced"
fi

# Install/update Zim modules and regenerate caches
print_step "Updating Zim modules..."
zsh -c '
    ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
    source "${ZIM_HOME}/zimfw.zsh" init -q
    source "${ZIM_HOME}/zimfw.zsh" install
    source "${ZIM_HOME}/zimfw.zsh" update
    source "${ZIM_HOME}/zimfw.zsh" compile
' 2>/dev/null || true
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
print_success "Zim modules updated & init caches refreshed"

echo ""
echo -e "${GREEN}Update complete!${NC}"
echo "Run 'source ~/.zshrc' or restart your terminal."
echo ""
