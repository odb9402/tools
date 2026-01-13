#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "CLI Tools Installer"
echo "======================================"
echo

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
echo "This installer will set up your development environment with:"
echo
echo "Essential Tools:"
echo "  - tmux, fish, htop, nvtop"
echo "  - uv, gh, lazygit, jq, yq, claude"
echo
echo "Optional Modern Tools (recommended):"
echo "  - delta, fd, ripgrep, fzf, zoxide"
echo

# Ask what to install
echo "What would you like to install?"
echo "  1) Essential tools only"
echo "  2) Essential + Optional tools (recommended)"
echo "  3) Optional tools only"
echo

read -p "Enter choice [1-3]: " -n 1 -r choice
echo
echo

# Clone or use existing directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d "$SCRIPT_DIR/dotfiles" ]; then
    echo "Using existing dotfiles directory"
    cd "$SCRIPT_DIR"
else
    echo "Cloning tools repository..."
    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/odb9402/tools.git "$TEMP_DIR"
    cd "$TEMP_DIR"
fi

# Make scripts executable
chmod +x dotfiles/*.sh

# Install based on choice
case $choice in
    1)
        echo "Installing essential tools..."
        ./dotfiles/install_essential.sh
        ;;
    2)
        echo "Installing all tools..."
        ./dotfiles/install_essential.sh
        echo
        echo "======================================"
        echo "Now installing optional tools..."
        echo "======================================"
        echo
        ./dotfiles/install_optional.sh
        ;;
    3)
        echo "Installing optional tools..."
        ./dotfiles/install_optional.sh
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo
echo "======================================"
echo "All Done! 🎉"
echo "======================================"
echo
echo "Your development environment is ready!"
echo
echo "Recommended next steps:"
echo "  1. Restart your shell or run: exec \$SHELL"
echo "  2. Set fish as default shell: chsh -s \$(which fish)"
echo "  3. Configure your tools (gh auth login, etc.)"
echo
