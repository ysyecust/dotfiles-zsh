#!/bin/bash
#
# Uninstall script for dotfiles-zsh
# Removes configurations and optionally tools
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

echo ""
echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║           Dotfiles-zsh Uninstall                           ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Confirm
read -p "Are you sure you want to uninstall? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Restore backups if exist
print_step "Checking for backup files..."

restore_backup() {
    local file=$1
    local backup=$(ls -t "${file}.backup."* 2>/dev/null | head -1)
    if [[ -n "$backup" ]]; then
        mv "$backup" "$file"
        print_success "Restored $file from backup"
    else
        rm -f "$file"
        print_warning "Removed $file (no backup found)"
    fi
}

restore_backup ~/.zshrc
restore_backup ~/.zimrc
restore_backup ~/.tmux.conf

# Remove config files
print_step "Removing config files..."
rm -f ~/.config/fzf-git.sh
rm -f ~/.bookmarks
rm -f ~/.p10k.zsh
print_success "Config files removed"

# Ask about Zim
echo ""
read -p "Remove Zim framework (~/.zim)? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.zim
    print_success "Zim removed"
fi

# Ask about tools
echo ""
read -p "Uninstall CLI tools (eza, bat, fd, etc.)? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Uninstalling tools..."
    brew uninstall --ignore-dependencies zoxide eza bat fd ripgrep fzf lazygit yazi tmux mise fastfetch 2>/dev/null || true
    print_success "Tools uninstalled"
fi

echo ""
echo -e "${GREEN}Uninstall complete!${NC}"
echo "You may need to install a default .zshrc or restart your terminal."
echo ""
