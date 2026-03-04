#!/usr/bin/env bash
set -euo pipefail

# Parse arguments for non-interactive mode
NONINTERACTIVE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            NONINTERACTIVE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Source shared helpers
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo "======================================"
echo "Installing Essential CLI Tools"
echo "======================================"
echo

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "Detected Linux"
    if [ "$CAN_SUDO" = false ]; then
        echo "  (no sudo available - will install to ~/.local/bin where possible)"
    fi
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo
echo "This script will install:"
echo "  - tmux (terminal multiplexer)"
echo "  - fish (friendly shell)"
echo "  - htop (process viewer)"
echo "  - nvtop (GPU monitor)"
echo "  - uv (Python package manager)"
echo "  - gh (GitHub CLI)"
echo "  - lazygit (Git TUI)"
echo "  - jq (JSON processor)"
echo "  - yq (YAML processor)"
echo "  - claude (Claude AI CLI)"
echo "  - staff-ml-engineer skill (Claude Code skill)"
echo

if [ "$NONINTERACTIVE" = false ]; then
    read -p "Continue? (y/N) " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

echo

# Install Claude Code skill from .skill file (ZIP archive)
install_claude_skill() {
    local skill_file=$1
    local skill_name=$2

    if [ ! -f "$skill_file" ]; then
        echo "⚠ Skill file not found: $skill_file, skipping..."
        return
    fi

    if [ -d "$HOME/.claude/skills/$skill_name" ]; then
        echo "✓ Claude skill '$skill_name' is already installed, skipping..."
        return
    fi

    echo "→ Installing Claude skill '$skill_name'..."
    mkdir -p "$HOME/.claude/skills"
    unzip -q "$skill_file" -d "$HOME/.claude/skills/"

    if [ -d "$HOME/.claude/skills/$skill_name" ]; then
        echo "✓ Claude skill '$skill_name' installed to ~/.claude/skills/$skill_name"
    else
        echo "✗ Failed to install Claude skill '$skill_name'"
    fi
}

# macOS installations
if [ "$OS" = "macos" ]; then
    # Check if Homebrew is installed
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    install_tool "tmux" "brew install tmux"
    install_tool "fish" "brew install fish"
    install_tool "htop" "brew install htop"
    install_tool "nvtop" "brew install nvtop"
    install_tool "gh" "brew install gh"
    install_tool "lazygit" "brew install lazygit"
    install_tool "jq" "brew install jq"
    install_tool "yq" "brew install yq"

    # uv
    if command_exists uv; then
        echo "✓ uv is already installed, skipping..."
    else
        echo "→ Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        echo "✓ uv installed successfully"
    fi
    echo

    # claude
    echo "→ Installing claude..."
    curl -fsSL https://claude.ai/install.sh | bash

# Linux installations
elif [ "$OS" = "linux" ]; then
    if [ "$CAN_SUDO" = true ]; then
        echo "Updating package lists..."
        run_privileged apt update
        echo

        install_tool "tmux" "run_privileged apt install -y tmux"
        install_tool "fish" "run_privileged apt install -y fish"
        install_tool "htop" "run_privileged apt install -y htop"
        install_tool "nvtop" "run_privileged apt install -y nvtop"
        install_tool "jq" "run_privileged apt install -y jq"

        # gh (GitHub CLI) via APT source
        if command_exists gh; then
            echo "✓ gh is already installed, skipping..."
        else
            echo "→ Installing gh (GitHub CLI)..."
            (type -p wget >/dev/null || (run_privileged apt update && run_privileged apt-get install wget -y)) \
            && run_privileged mkdir -p -m 755 /etc/apt/keyrings \
            && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | run_privileged tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && run_privileged chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | run_privileged tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && run_privileged apt update \
            && run_privileged apt install -y gh
            echo "✓ gh installed successfully"
        fi
        echo
    else
        # No sudo: install what we can from binary releases, skip the rest
        ensure_local_bin

        # tmux via AppImage
        if command_exists tmux; then
            echo "✓ tmux is already installed, skipping..."
        else
            echo "→ Installing tmux (AppImage)..."
            curl -Lo "$LOCAL_BIN/tmux" "https://github.com/nelsonenzo/tmux-appimage/releases/latest/download/tmux.appimage"
            chmod +x "$LOCAL_BIN/tmux"
            if command_exists tmux; then
                echo "✓ tmux installed successfully"
            else
                echo "✗ Failed to install tmux"
            fi
        fi
        echo

        echo "⚠ fish: skipping (requires sudo to install)"
        echo "⚠ htop: skipping (requires sudo to install)"
        echo "⚠ nvtop: skipping (requires sudo/GPU libs to install)"
        echo

        # jq static binary
        if command_exists jq; then
            echo "✓ jq is already installed, skipping..."
        else
            echo "→ Installing jq (static binary)..."
            curl -Lo "$LOCAL_BIN/jq" "https://github.com/jqlang/jq/releases/latest/download/jq-linux-${ARCH}"
            chmod +x "$LOCAL_BIN/jq"
            if command_exists jq; then
                echo "✓ jq installed successfully"
            else
                echo "✗ Failed to install jq"
            fi
        fi
        echo

        # gh binary tarball
        if command_exists gh; then
            echo "✓ gh is already installed, skipping..."
        else
            echo "→ Installing gh (GitHub CLI)..."
            GH_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz"
            tar xf gh.tar.gz
            install "gh_${GH_VERSION}_linux_${ARCH}/bin/gh" "$LOCAL_BIN/gh"
            rm -rf gh.tar.gz "gh_${GH_VERSION}_linux_${ARCH}"
            if command_exists gh; then
                echo "✓ gh installed successfully"
            else
                echo "✗ Failed to install gh"
            fi
        fi
        echo
    fi

    # lazygit (binary download - works both paths)
    if command_exists lazygit; then
        echo "✓ lazygit is already installed, skipping..."
    else
        echo "→ Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        LAZYGIT_ARCH="${ARCH_ALT}"; [ "$ARCH" = "arm64" ] && LAZYGIT_ARCH="arm64"
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_linux_${LAZYGIT_ARCH}.tar.gz"
        tar xf lazygit.tar.gz lazygit
        install_binary lazygit lazygit
        rm -f lazygit lazygit.tar.gz
        echo "✓ lazygit installed successfully"
    fi
    echo

    # yq (binary download - works both paths)
    if command_exists yq; then
        echo "✓ yq is already installed, skipping..."
    else
        echo "→ Installing yq..."
        curl -Lo yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
        chmod +x yq
        install_binary yq yq
        rm -f yq
        echo "✓ yq installed successfully"
    fi
    echo

    # uv (already user-local)
    if command_exists uv; then
        echo "✓ uv is already installed, skipping..."
    else
        echo "→ Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        echo "✓ uv installed successfully"
    fi
    echo

    # claude (already user-local)
    echo "→ Installing claude..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Install Claude Code skills (after claude is installed)
echo
echo "======================================"
echo "Installing Claude Code Skills"
echo "======================================"
echo

install_claude_skill "$HOME/Downloads/staff-ml-engineer.skill" "staff-ml-engineer"

echo
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo
echo "Installed tools:"
command_exists tmux && echo "  ✓ tmux: $(tmux -V)"
command_exists fish && echo "  ✓ fish: $(fish --version)"
command_exists htop && echo "  ✓ htop: $(htop --version | head -1)"
command_exists nvtop && echo "  ✓ nvtop: installed"
command_exists uv && echo "  ✓ uv: $(uv --version)"
command_exists gh && echo "  ✓ gh: $(gh --version | head -1)"
command_exists lazygit && echo "  ✓ lazygit: $(lazygit --version)"
command_exists jq && echo "  ✓ jq: $(jq --version)"
command_exists yq && echo "  ✓ yq: $(yq --version)"
[ -d "$HOME/.claude/skills/staff-ml-engineer" ] && echo "  ✓ staff-ml-engineer skill: installed"
echo
echo "Next steps:"
echo "  1. Set fish as your default shell: chsh -s \$(which fish)"
echo "  2. Authenticate with GitHub: gh auth login"
echo "  3. Configure claude: Follow instructions at https://docs.anthropic.com/claude/docs/claude-cli"
echo
