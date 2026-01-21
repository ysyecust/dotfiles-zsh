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

# Detect OS
OS="$(uname)"
LINUX_DISTRO=""
if [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/os-release ]]; then
        LINUX_DISTRO=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    fi
fi

# Install package manager and packages based on OS
install_packages() {
    print_step "Installing packages..."

    local packages=(
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

    if [[ "$OS" == "Darwin" ]]; then
        # macOS - use Homebrew
        if ! command -v brew &> /dev/null; then
            print_step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        fi
        for pkg in "${packages[@]}"; do
            if ! brew list "$pkg" &>/dev/null; then
                print_step "Installing $pkg..."
                brew install "$pkg"
            fi
            print_success "$pkg installed"
        done

    elif [[ "$OS" == "Linux" ]]; then
        # Linux - detect package manager
        if command -v apt &> /dev/null; then
            # Debian/Ubuntu
            print_step "Using apt package manager..."
            sudo apt update
            sudo apt install -y zsh tmux fzf ripgrep bat fd-find
            # Some packages need special installation
            # zoxide
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
            # eza
            sudo apt install -y gpg
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo apt update && sudo apt install -y eza
            # lazygit
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit && sudo install lazygit /usr/local/bin && rm lazygit lazygit.tar.gz
            # yazi
            curl -sSfL https://raw.githubusercontent.com/sxyazi/yazi/main/scripts/install.sh | sh
            # mise
            curl https://mise.run | sh
            # fastfetch
            sudo apt install -y fastfetch 2>/dev/null || print_warning "fastfetch not available, skipping"
            # Create symlinks for different names
            [[ ! -f /usr/bin/fd ]] && sudo ln -sf /usr/bin/fdfind /usr/bin/fd 2>/dev/null || true
            [[ ! -f /usr/bin/bat ]] && sudo ln -sf /usr/bin/batcat /usr/bin/bat 2>/dev/null || true

        elif command -v dnf &> /dev/null; then
            # Fedora/RHEL
            print_step "Using dnf package manager..."
            sudo dnf install -y zsh tmux fzf ripgrep bat fd-find eza
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
            # lazygit
            sudo dnf copr enable atim/lazygit -y && sudo dnf install -y lazygit
            # mise
            curl https://mise.run | sh

        elif command -v pacman &> /dev/null; then
            # Arch Linux
            print_step "Using pacman package manager..."
            sudo pacman -Syu --noconfirm zsh tmux fzf ripgrep bat fd eza zoxide lazygit yazi mise fastfetch

        else
            print_error "Unsupported Linux distribution. Please install packages manually."
            exit 1
        fi
        print_success "Linux packages installed"
    else
        print_error "Unsupported OS: $OS"
        exit 1
    fi
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

    # Backup and install .tmux.conf
    backup_config "${HOME}/.tmux.conf"
    cp "${SCRIPT_DIR}/config/.tmux.conf" "${HOME}/.tmux.conf"
    print_success "Installed .tmux.conf"

    # Install fzf-git.sh
    mkdir -p "${HOME}/.config"
    cp "${SCRIPT_DIR}/config/fzf-git.sh" "${HOME}/.config/fzf-git.sh"
    print_success "Installed fzf-git.sh"

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
    echo "  • fzf + fzf-tab + fzf-git (fuzzy finder)"
    echo "  • zoxide (smart cd)"
    echo "  • eza (modern ls)"
    echo "  • bat (modern cat)"
    echo "  • fd (modern find)"
    echo "  • ripgrep (modern grep)"
    echo "  • lazygit (terminal Git UI)"
    echo "  • yazi (terminal file manager)"
    echo "  • tmux (terminal multiplexer)"
    echo "  • mise (version manager)"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. If p10k prompt appears, configure your theme"
    echo "  3. Use 'z' command a few times to let zoxide learn your directories"
    echo "  4. Install Claude CLI for AI features: npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "Quick reference:"
    echo "  Ctrl+T      - Fuzzy file search"
    echo "  Ctrl+R      - Fuzzy history search"
    echo "  Alt+C       - Fuzzy directory jump"
    echo "  Ctrl+G      - fzf-git commands (branches, commits, etc.)"
    echo "  z <dir>     - Smart directory jump"
    echo "  lg          - Lazygit"
    echo "  y           - Yazi file manager"
    echo "  tmux        - Terminal multiplexer"
    echo "  ask \"...\"   - Ask Claude (headless mode)"
    echo "  gcm         - Generate git commit message with Claude"
    echo ""
}

# Main installation
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Zsh Terminal Enhancement Setup                        ║${NC}"
    echo -e "${BLUE}║      OS: $OS ${LINUX_DISTRO:+($LINUX_DISTRO)}${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    install_packages
    install_zim
    install_p10k
    install_configs
    compile_zim
    print_summary
}

# Run main function
main "$@"
