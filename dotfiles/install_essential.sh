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

echo "======================================"
echo "Installing Essential CLI Tools"
echo "======================================"
echo

# Run command with sudo if needed (handles k8s pods where sudo is not available)
run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "Error: This script requires root privileges. Please run as root or install sudo."
        exit 1
    fi
}

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "Detected Linux"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install function with skip check
install_tool() {
    local tool_name=$1
    local install_cmd=$2

    if command_exists "$tool_name"; then
        echo "✓ $tool_name is already installed, skipping..."
    else
        echo "→ Installing $tool_name..."
        eval "$install_cmd"
        if command_exists "$tool_name"; then
            echo "✓ $tool_name installed successfully"
        else
            echo "✗ Failed to install $tool_name"
        fi
    fi
    echo
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
    echo "Note: Claude CLI installation may require npm or manual setup."
    echo "Visit: https://docs.anthropic.com/claude/docs/claude-cli for instructions"
    echo

# Linux installations
elif [ "$OS" = "linux" ]; then
    echo "Updating package lists..."
    run_privileged apt update
    echo

    install_tool "tmux" "run_privileged apt install -y tmux"
    install_tool "fish" "run_privileged apt install -y fish"
    install_tool "htop" "run_privileged apt install -y htop"
    install_tool "nvtop" "run_privileged apt install -y nvtop"
    install_tool "jq" "run_privileged apt install -y jq"

    # gh (GitHub CLI)
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

    # lazygit
    if command_exists lazygit; then
        echo "✓ lazygit is already installed, skipping..."
    else
        echo "→ Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        run_privileged install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
        echo "✓ lazygit installed successfully"
    fi
    echo

    # yq
    if command_exists yq; then
        echo "✓ yq is already installed, skipping..."
    else
        echo "→ Installing yq..."
        run_privileged wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        run_privileged chmod +x /usr/local/bin/yq
        echo "✓ yq installed successfully"
    fi
    echo

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
    echo "Note: Claude CLI installation may require npm or manual setup."
    echo "Visit: https://docs.anthropic.com/claude/docs/claude-cli for instructions"
    echo
fi

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
echo
echo "Next steps:"
echo "  1. Set fish as your default shell: chsh -s \$(which fish)"
echo "  2. Authenticate with GitHub: gh auth login"
echo "  3. Configure claude: Follow instructions at https://docs.anthropic.com/claude/docs/claude-cli"
echo
