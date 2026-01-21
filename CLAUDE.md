# CLAUDE.md - AI Assistant Guide

This document provides essential context for AI assistants working with this repository.

## Repository Overview

**Purpose**: A Zsh terminal enhancement configuration that provides a modern, optimized shell experience with sub-100ms startup time.

**Target Platforms**: macOS (Apple Silicon and Intel) and Linux (Debian/Ubuntu, Fedora/RHEL, Arch)

**Primary Language**: Bash/Zsh shell scripts with Chinese documentation

## Directory Structure

```
dotfiles-zsh/
├── CLAUDE.md           # This guide for AI assistants
├── README.md           # User documentation (Chinese)
├── install.sh          # Main installation script
├── uninstall.sh        # Cleanup and removal script
├── update.sh           # Update tools and configs
├── .gitignore          # Git ignore rules
└── config/
    ├── .zimrc          # Zim plugin manager configuration
    ├── .zshrc          # Main Zsh configuration file
    ├── .tmux.conf      # Tmux terminal multiplexer config
    └── fzf-git.sh      # Enhanced git operations with fzf
```

## Key Files

### install.sh
- **Purpose**: Automated installation of the complete environment
- **Features**: Cross-platform (macOS/Linux), color-coded output, backup system, error handling with `set -e`
- **Flow**: OS detect → Package manager → Packages → Zim → Powerlevel10k → Configs → Compile
- **Linux support**: apt (Debian/Ubuntu), dnf (Fedora/RHEL), pacman (Arch)

### config/.zshrc (535 lines)
- **Purpose**: Main shell configuration loaded at startup
- **Sections**:
  1. Powerlevel10k instant prompt (must be at top)
  2. Zim framework initialization
  3. Environment variables (PATH, EDITOR, HISTSIZE)
  4. fzf configuration with Catppuccin Mocha theme
  5. Aliases (eza, bat, git, Docker, Kubernetes)
  6. Custom functions (mkcd, fe, fcd, fbr, fkill, extract, fssh, bm, notify, serve, dsh, ksh)
  7. Tool integrations (lazygit, yazi, fzf-git, mise)
  8. Claude CLI integration (ask, askf, gen, explain, fix, gcm, review)
  9. Lazy loading (NVM)
  10. Final initializations (zoxide, p10k, fastfetch)

### config/.zimrc
- **Purpose**: Zim plugin manager module list
- **Critical**: Module order matters - completions before fzf-tab, syntax-highlighting before history-substring-search

### config/.tmux.conf
- **Purpose**: Tmux terminal multiplexer configuration
- **Features**: Vi-style copy mode, mouse support, vim-like pane navigation, popup integrations (lazygit, yazi, htop)
- **Prefix**: Default Ctrl+B (Ctrl+A commented out)

### config/fzf-git.sh
- **Purpose**: Enhanced git operations with fzf
- **Keybindings**: Ctrl+G + Ctrl+F/B/T/R/H/S/L/W/E for git operations

### uninstall.sh
- **Purpose**: Clean removal of configurations
- **Features**: Restores backups, optional Zim removal, optional tool uninstall

### update.sh
- **Purpose**: Keep everything up to date
- **Updates**: Homebrew packages, Zim modules, fzf-git.sh, config files

## Development Commands

```bash
# Reload shell configuration
source ~/.zshrc

# Reinstall Zim modules
zimfw install

# Update Zim modules
zimfw update

# Reconfigure Powerlevel10k theme
p10k configure

# Test installation script syntax
bash -n install.sh

# Update everything
./update.sh
```

## Coding Conventions

### Shell Scripts
- Use `#!/bin/bash` shebang for scripts
- Use `set -e` to fail fast on errors
- Define functions for modular code organization
- Use color codes for user feedback (BLUE=steps, GREEN=success, YELLOW=warnings, RED=errors)
- Add clear section headers with ASCII box comments

### Zsh Configuration
- Group related settings with ASCII box headers
- Add inline comments for non-obvious settings
- Keep execution order in mind (some modules depend on others)
- Use lazy loading for slow initializations (e.g., NVM)

### Documentation
- README.md is in Chinese (target audience)
- CLAUDE.md is in English
- Use tables for command references
- Provide code examples for usage

## Dependencies

### Required Tools (installed by script)

| Tool | Purpose |
|------|---------|
| Homebrew/apt/dnf/pacman | Package manager |
| zoxide | Smart directory jumping |
| eza | Modern ls replacement with icons |
| bat | Syntax-highlighted cat |
| fd | Fast file finder |
| ripgrep | Ultra-fast grep |
| fzf | Fuzzy finder |
| lazygit | Terminal Git UI |
| yazi | Terminal file manager |
| tmux | Terminal multiplexer |
| mise | Multi-language version manager |
| fastfetch | System info display |

### Frameworks

| Framework | Purpose |
|-----------|---------|
| Zim | Lightweight Zsh plugin manager |
| Powerlevel10k | High-performance prompt theme |

### Optional

| Tool | Purpose |
|------|---------|
| Claude CLI | AI assistant integration |
| NVM | Node.js version manager (lazy loaded) |
| tldr | Simplified man pages |

## Important Patterns

### Backup Strategy
Existing configs are backed up with timestamp before overwriting:
```bash
${file}.backup.${YYYYMMDD_HHMMSS}
```

### User Customization
Users extend configuration via `~/.zshrc.local` which:
- Is sourced at the end of .zshrc if it exists
- Is gitignored for machine-specific settings
- Should not be created by this repository

### Performance Targets
- Shell startup time: < 100ms
- Instant prompt must load before any blocking operations
- Lazy load slow tools (NVM saves ~300ms)

### Catppuccin Theme
fzf uses Catppuccin Mocha color scheme for consistent aesthetics.

## When Making Changes

### Adding New Aliases
Add to the appropriate section in `config/.zshrc`:
- Lines 150-179: Basic aliases (eza, bat, navigation, git, utility)
- Lines 181-201: Docker and Kubernetes aliases

### Adding New Functions
Add to the "Functions" section in `config/.zshrc` (lines 203-365).

### Adding New Zim Modules
1. Add to `config/.zimrc` in the appropriate section
2. Respect module ordering requirements
3. Update README.md component table if user-facing

### Modifying install.sh
1. Test syntax with `bash -n install.sh`
2. Use existing color output functions (print_step, print_success, etc.)
3. Handle existing file backups when overwriting configs
4. Support both macOS and Linux package managers
5. Update the summary section if adding new components

### Adding Tmux Bindings
Add to `config/.tmux.conf` in the appropriate section (Key Bindings, Copy Mode, or Integration).

## Testing

No automated tests exist. Manual testing approach:
1. Run `bash -n install.sh` to check syntax
2. Test install on fresh macOS/Linux environment
3. Verify shell startup time with `time zsh -i -c exit`
4. Confirm all aliases and functions work as expected
5. Test tmux popup integrations (Ctrl+B g/y/t)

## Git Workflow

- Main development branch: `main` (or as specified)
- Commit messages should be descriptive
- Keep commits focused on single changes

## Common Tasks

### Add a new CLI tool to installation
1. Add to packages array in `install.sh` (both macOS and Linux sections)
2. Add aliases in `config/.zshrc` if needed
3. Update README.md documentation

### Update Powerlevel10k
```bash
git -C ${ZIM_HOME}/modules/powerlevel10k pull
```

### Debug startup time
```bash
# Profile Zsh startup
zsh -xv 2>&1 | ts -i "%.s" > zsh_startup.log

# Quick timing
time zsh -i -c exit
```

## Claude CLI Integration

The configuration includes helpers for Claude CLI (headless mode):

| Command | Purpose |
|---------|---------|
| `ask "..."` | Ask Claude a question |
| `askf file "..."` | Ask with file context |
| `gen "..."` | Generate code |
| `explain "cmd"` | Explain a command |
| `fix "error"` | Fix an error |
| `ask-pipe` | Pipe output to Claude |
| `gcm` | Generate git commit message |
| `review file` | Code review |

Requires: `npm install -g @anthropic-ai/claude-code`

## Notes for AI Assistants

1. **Platform**: Supports macOS and Linux. Check OS-specific code paths when editing install.sh.

2. **Language**: Documentation (README.md) is in Chinese. CLAUDE.md is in English.

3. **Performance**: Shell startup speed is critical. Avoid adding blocking operations to .zshrc.

4. **Zim Module Order**: The order in .zimrc is intentional and affects functionality. Consult comments before reordering.

5. **Homebrew ARM**: The .zshrc includes Apple Silicon support. Maintain this when editing PATH.

6. **Linux Compatibility**: When adding new tools, ensure they work on both macOS (Homebrew) and Linux (apt/dnf/pacman).

7. **Tmux Prefix**: Default is Ctrl+B. Ctrl+A is commented out but available.

8. **No Over-Engineering**: This is a personal dotfiles repo. Keep changes minimal and focused.

9. **Claude CLI**: The integration assumes Claude CLI is installed. Functions gracefully fail if not available.

10. **fzf-git.sh**: This is an external script from junegunn/fzf-git.sh. Update via update.sh.
