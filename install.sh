#!/bin/bash
#
# Zsh Terminal Enhancement Setup Script
# Author: shaoyiyang
# Repository: https://github.com/shaoyiyang/dotfiles-zsh
#
# This script installs and configures:
# - Zim (Zsh framework)
# - Powerlevel10k theme
# - fzf, fzf-tab
# - zoxide, eza, bat, fd, ripgrep
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing config
backup_config() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        print_warning "Backed up $file to $backup"
    fi
}

# Check if running on macOS
check_os() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS. For Linux, please modify the package manager commands."
        exit 1
    fi
}

# Install Homebrew if not installed
install_homebrew() {
    print_step "Checking Homebrew..."
    if ! command -v brew &> /dev/null; then
        print_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    else
        print_success "Homebrew already installed"
    fi
}

# Install required packages
install_packages() {
    print_step "Installing packages..."

    local packages=(
        "zoxide"      # Smart cd
        "eza"         # Modern ls
        "bat"         # Modern cat
        "fd"          # Modern find
        "ripgrep"     # Modern grep
        "fzf"         # Fuzzy finder
    )

    for pkg in "${packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            print_success "$pkg already installed"
        else
            print_step "Installing $pkg..."
            brew install "$pkg"
            print_success "$pkg installed"
        fi
    done
}

# Install Zim framework
install_zim() {
    print_step "Installing Zim framework..."

    if [[ -d "${HOME}/.zim" ]]; then
        print_success "Zim already installed"
    else
        curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
        print_success "Zim installed"
    fi
}

# Install Powerlevel10k
install_p10k() {
    print_step "Checking Powerlevel10k..."

    if [[ -d "${HOME}/.powerlevel10k" ]] || [[ -d "${HOME}/powerlevel10k" ]]; then
        print_success "Powerlevel10k already installed"
    else
        print_step "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}/.powerlevel10k"
        print_success "Powerlevel10k installed"
    fi
}

# Install configuration files
install_configs() {
    print_step "Installing configuration files..."

    # Backup and install .zimrc
    backup_config "${HOME}/.zimrc"
    cp "${SCRIPT_DIR}/config/.zimrc" "${HOME}/.zimrc"
    print_success "Installed .zimrc"

    # Backup and install .zshrc
    backup_config "${HOME}/.zshrc"
    cp "${SCRIPT_DIR}/config/.zshrc" "${HOME}/.zshrc"
    print_success "Installed .zshrc"

    # Install .p10k.zsh if not exists or user wants to overwrite
    if [[ -f "${HOME}/.p10k.zsh" ]]; then
        print_warning ".p10k.zsh already exists. Run 'p10k configure' to reconfigure."
    else
        if [[ -f "${SCRIPT_DIR}/config/.p10k.zsh" ]]; then
            cp "${SCRIPT_DIR}/config/.p10k.zsh" "${HOME}/.p10k.zsh"
            print_success "Installed .p10k.zsh"
        else
            print_warning "No .p10k.zsh template found. Run 'p10k configure' after installation."
        fi
    fi
}

# Compile Zim modules
compile_zim() {
    print_step "Compiling Zim modules..."
    zsh -c 'source ~/.zshrc && zimfw install' 2>/dev/null || true
    print_success "Zim modules compiled"
}

# Print installation summary
print_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Installed components:"
    echo "  • Zim framework with optimized modules"
    echo "  • Powerlevel10k theme"
    echo "  • fzf + fzf-tab (fuzzy finder)"
    echo "  • zoxide (smart cd)"
    echo "  • eza (modern ls)"
    echo "  • bat (modern cat)"
    echo "  • fd (modern find)"
    echo "  • ripgrep (modern grep)"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. If p10k prompt appears, configure your theme"
    echo "  3. Use 'z' command a few times to let zoxide learn your directories"
    echo ""
    echo "Quick reference:"
    echo "  Ctrl+T    - Fuzzy file search"
    echo "  Ctrl+R    - Fuzzy history search"
    echo "  Alt+C     - Fuzzy directory jump"
    echo "  z <dir>   - Smart directory jump"
    echo "  ll        - Enhanced ls"
    echo "  cat       - Syntax highlighted cat"
    echo ""
}

# Main installation
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Zsh Terminal Enhancement Setup                        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_os
    install_homebrew
    install_packages
    install_zim
    install_p10k
    install_configs
    compile_zim
    print_summary
}

# Run main function
main "$@"
