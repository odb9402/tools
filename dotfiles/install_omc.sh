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
    echo "→ Node.js not found. Installing via Homebrew (macOS) or nvm..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists brew; then
            brew install node
        else
            echo "✗ Homebrew not found. Please install Node.js >= 20 manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "→ Installing Node.js via nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
    fi
fi

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
