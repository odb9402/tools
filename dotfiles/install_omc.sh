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
echo "Installing oh-my-claudecode"
echo "======================================"
echo
echo "oh-my-claudecode is a multi-agent orchestration framework"
echo "that enhances Claude Code with specialized agents."
echo
echo "Prerequisites: Node.js >= 20, Claude Code CLI"
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

# Ensure Node.js is available
if ! command_exists node; then
    echo "→ Node.js not found. Installing..."
    NODE_LTS_VERSION="22.16.0"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        NODE_ARCH="darwin-arm64"
        [[ "$(uname -m)" == "x86_64" ]] && NODE_ARCH="darwin-x64"
        echo "→ Downloading Node.js v${NODE_LTS_VERSION} (${NODE_ARCH})..."
        curl -fsSL "https://nodejs.org/dist/v${NODE_LTS_VERSION}/node-v${NODE_LTS_VERSION}-${NODE_ARCH}.tar.gz" -o /tmp/node.tar.gz
        mkdir -p "$HOME/.local"
        tar xzf /tmp/node.tar.gz -C "$HOME/.local/"
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.local/node-v${NODE_LTS_VERSION}-${NODE_ARCH}/bin/node" "$HOME/.local/bin/node"
        ln -sf "$HOME/.local/node-v${NODE_LTS_VERSION}-${NODE_ARCH}/bin/npm" "$HOME/.local/bin/npm"
        ln -sf "$HOME/.local/node-v${NODE_LTS_VERSION}-${NODE_ARCH}/bin/npx" "$HOME/.local/bin/npx"
        export PATH="$HOME/.local/bin:$PATH"
        rm -f /tmp/node.tar.gz
        echo "✓ Node.js installed to ~/.local"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        NODE_ARCH="linux-x64"
        [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] && NODE_ARCH="linux-arm64"
        echo "→ Downloading Node.js v${NODE_LTS_VERSION} (${NODE_ARCH})..."
        curl -fsSL "https://nodejs.org/dist/v${NODE_LTS_VERSION}/node-v${NODE_LTS_VERSION}-${NODE_ARCH}.tar.gz" -o /tmp/node.tar.gz
        mkdir -p "$HOME/.local"
        tar xzf /tmp/node.tar.gz -C "$HOME/.local/"
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.local/node-v${NODE_LTS_VERSION}-${NODE_ARCH}/bin/node" "$HOME/.local/bin/node"
        ln -sf "$HOME/.local/node-v${NODE_LTS_VERSION}-${NODE_ARCH}/bin/npm" "$HOME/.local/bin/npm"
        ln -sf "$HOME/.local/node-v${NODE_LTS_VERSION}-${NODE_ARCH}/bin/npx" "$HOME/.local/bin/npx"
        export PATH="$HOME/.local/bin:$PATH"
        rm -f /tmp/node.tar.gz
        echo "✓ Node.js installed to ~/.local"
    fi
fi

# Ensure ~/.local/bin is in PATH for npm global installs
export PATH="$HOME/.local/bin:$PATH"
# Also add node's own bin dir to PATH (for npm global bin)
NODE_DIR=$(dirname "$(readlink -f "$(which node)" 2>/dev/null || which node)")
export PATH="$NODE_DIR:$PATH"

NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "✗ Node.js >= 20 required (found v${NODE_VERSION}). Please upgrade."
    exit 1
fi
echo "✓ Node.js $(node --version) available"
echo

# Ensure Claude Code CLI is available
if ! command_exists claude; then
    echo "⚠ Claude Code CLI not found. Install it first via install_essential.sh"
    echo "  Continuing anyway — you can install Claude CLI later."
fi

# Install oh-my-claudecode via npm
if command_exists omc; then
    echo "✓ oh-my-claudecode is already installed, skipping..."
else
    echo "→ Installing oh-my-claudecode via npm..."
    npm install -g oh-my-claude-sisyphus@latest
    echo "✓ oh-my-claudecode installed successfully"
fi
echo

# Verify installation
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo
if command_exists omc; then
    echo "  ✓ oh-my-claudecode: $(omc --version 2>/dev/null || echo 'installed')"
else
    echo "  ✓ oh-my-claude-sisyphus npm package installed"
fi
echo
echo "Next steps:"
echo "  1. Open Claude Code and run: /setup"
echo "     (or /omc-setup to initialize oh-my-claudecode)"
echo "  2. Restart Claude Code to activate the HUD"
echo "  3. Try it out: autopilot: <your task>"
echo
