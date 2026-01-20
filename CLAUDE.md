# CLAUDE.md - AI Assistant Guide

This document provides essential context for AI assistants working with this repository.

## Repository Overview

**Purpose**: A Zsh terminal enhancement configuration for macOS that provides a modern, optimized shell experience with sub-100ms startup time.

**Target Platform**: macOS only (Apple Silicon and Intel supported)

**Primary Language**: Bash/Zsh shell scripts with Chinese documentation

## Directory Structure

```
dotfiles-zsh/
├── CLAUDE.md          # This guide for AI assistants
├── README.md          # User documentation (Chinese)
├── install.sh         # Main installation script
├── .gitignore         # Git ignore rules
└── config/
    ├── .zimrc         # Zim plugin manager configuration
    └── .zshrc         # Main Zsh configuration file
```

## Key Files

### install.sh
- **Purpose**: Automated installation of the complete Zsh environment
- **Features**: Color-coded output, backup system, error handling with `set -e`
- **Flow**: OS check → Homebrew → Packages → Zim → Powerlevel10k → Configs → Compile

### config/.zshrc
- **Purpose**: Main shell configuration loaded at startup
- **Sections**:
  1. Powerlevel10k instant prompt (must be at top)
  2. Zim framework initialization
  3. Environment variables (PATH, EDITOR, HISTSIZE)
  4. fzf fuzzy finder configuration
  5. Aliases (eza, bat, git shortcuts)
  6. Custom functions (mkcd, fe, fcd, fbr, fkill, extract)
  7. Lazy loading (NVM)
  8. Final initializations (zoxide, p10k theme)

### config/.zimrc
- **Purpose**: Zim plugin manager module list
- **Critical**: Module order matters - completions before fzf-tab, syntax-highlighting before history-substring-search

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
```

## Coding Conventions

### Shell Scripts
- Use `#!/bin/bash` shebang for install.sh
- Use `set -e` to fail fast on errors
- Define functions for modular code organization
- Use color codes for user feedback (BLUE=steps, GREEN=success, YELLOW=warnings, RED=errors)
- Add clear section headers with comments

### Zsh Configuration
- Group related settings with ASCII box headers
- Add inline comments for non-obvious settings
- Keep execution order in mind (some modules depend on others)
- Use lazy loading for slow initializations (e.g., NVM)

### Documentation
- README.md is in Chinese (target audience)
- Use tables for command references
- Provide code examples for usage

## Dependencies

### Required Tools (installed by script)
| Tool | Purpose |
|------|---------|
| Homebrew | macOS package manager |
| zoxide | Smart directory jumping |
| eza | Modern ls replacement with icons |
| bat | Syntax-highlighted cat |
| fd | Fast file finder |
| ripgrep | Ultra-fast grep |
| fzf | Fuzzy finder |

### Frameworks
| Framework | Purpose |
|-----------|---------|
| Zim | Lightweight Zsh plugin manager |
| Powerlevel10k | High-performance prompt theme |

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

## When Making Changes

### Adding New Aliases
Add to the "Aliases" section in `config/.zshrc` (around line 137-167), grouped with similar commands.

### Adding New Functions
Add to the "Custom Functions" section in `config/.zshrc` (around line 170-225).

### Adding New Zim Modules
1. Add to `config/.zimrc` in the appropriate section
2. Respect module ordering requirements
3. Update README.md component table if user-facing

### Modifying install.sh
1. Test syntax with `bash -n install.sh`
2. Use existing color output functions (print_step, print_success, etc.)
3. Handle existing file backups when overwriting configs
4. Update the summary section if adding new components

## Testing

No automated tests exist. Manual testing approach:
1. Run `bash -n install.sh` to check syntax
2. Test install on fresh macOS environment
3. Verify shell startup time with `time zsh -i -c exit`
4. Confirm all aliases and functions work as expected

## Git Workflow

- Main development branch: `main` (or as specified)
- Commit messages should be descriptive
- Keep commits focused on single changes

## Common Tasks

### Add a new CLI tool to installation
1. Add to PACKAGES array in `install.sh`
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
```

## Notes for AI Assistants

1. **Platform**: This is macOS-only. Do not add Linux-specific code without user request.

2. **Language**: Documentation (README.md) is in Chinese. CLAUDE.md is in English.

3. **Performance**: Shell startup speed is critical. Avoid adding blocking operations to .zshrc.

4. **Zim Module Order**: The order in .zimrc is intentional and affects functionality. Consult comments before reordering.

5. **Homebrew ARM**: The .zshrc includes Apple Silicon support. Maintain this when editing PATH.

6. **No Over-Engineering**: This is a personal dotfiles repo. Keep changes minimal and focused.
