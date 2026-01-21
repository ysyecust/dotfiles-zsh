#!/bin/bash
#
# Update script for dotfiles-zsh
# Updates all installed tools and configurations
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

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Dotfiles-zsh Update                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Update Homebrew and packages
print_step "Updating Homebrew packages..."
brew update && brew upgrade
print_success "Homebrew packages updated"

# Update Zim modules
print_step "Updating Zim modules..."
zsh -c 'source ~/.zshrc && zimfw update' 2>/dev/null || true
print_success "Zim modules updated"

# Update fzf-git.sh
print_step "Updating fzf-git.sh..."
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o ~/.config/fzf-git.sh
print_success "fzf-git.sh updated"

# Pull latest dotfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_step "Pulling latest dotfiles..."
cd "$SCRIPT_DIR"
git pull origin main 2>/dev/null || print_warning "Could not pull latest changes"
print_success "Dotfiles updated"

# Offer to update config files
echo ""
read -p "Update config files from repo? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$SCRIPT_DIR/config/.zshrc" ~/.zshrc
    cp "$SCRIPT_DIR/config/.zimrc" ~/.zimrc
    cp "$SCRIPT_DIR/config/.tmux.conf" ~/.tmux.conf
    cp "$SCRIPT_DIR/config/fzf-git.sh" ~/.config/fzf-git.sh
    print_success "Config files updated"
fi

echo ""
echo -e "${GREEN}Update complete!${NC}"
echo "Run 'source ~/.zshrc' or restart your terminal."
echo ""
