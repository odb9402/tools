# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a CLI tools collection that provides automated installation scripts for setting up development environments on macOS and Linux. The project includes scripts to install essential and optional command-line tools.

## Commands

```bash
# Run the main installer (interactive menu)
./install.sh

# Non-interactive mode for Docker/CI (-y flag, option 1/2/3)
./install.sh -y 2

# Install specific tool sets
./dotfiles/install_essential.sh      # tmux, fish, htop, nvtop, uv, gh, lazygit, jq, yq, claude
./dotfiles/install_essential.sh -y   # non-interactive
./dotfiles/install_optional.sh       # delta, fd, ripgrep, fzf, zoxide
./dotfiles/install_lazygit.sh        # lazygit only
./dotfiles/install_aws.sh            # AWS CLI v2

# One-liner installation from remote
curl -fsSL https://raw.githubusercontent.com/odb9402/tools/main/install.sh | bash
```

## Architecture

- **install.sh**: Main entry point with OS detection and interactive menu
- **dotfiles/**: Contains modular installer scripts for each tool category
  - Scripts detect OS (macOS/Linux) and use appropriate package managers (Homebrew/apt)
  - Each script is idempotent - checks if tools are already installed before attempting installation
  - Uses `set -euo pipefail` for strict error handling

## Script Patterns

- `command_exists()` function pattern for checking tool availability
- `run_privileged()` function for sudo-less container support (k8s pods, Docker)
- `-y` flag parsing for non-interactive mode (Dockerfile/CI compatibility)
- GitHub API integration for fetching latest versions (e.g., lazygit)
- Post-installation version verification
- Cross-platform logic: macOS uses Homebrew, Linux uses apt or direct binary downloads
