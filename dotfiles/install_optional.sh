#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "Installing Optional CLI Tools"
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
echo "This script will install modern CLI tools:"
echo "  - delta (beautiful git diffs)"
echo "  - fd (better find)"
echo "  - ripgrep/rg (better grep)"
echo "  - fzf (fuzzy finder)"
echo "  - zoxide (smart cd)"
echo

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
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
        echo "Error: Homebrew not found. Please install Homebrew first."
        echo "Visit: https://brew.sh"
        exit 1
    fi

    install_tool "delta" "brew install git-delta"
    install_tool "fd" "brew install fd"
    install_tool "rg" "brew install ripgrep"
    install_tool "fzf" "brew install fzf && \$(brew --prefix)/opt/fzf/install --all"
    install_tool "zoxide" "brew install zoxide"

# Linux installations
elif [ "$OS" = "linux" ]; then
    echo "Updating package lists..."
    sudo apt update
    echo

    # delta
    if command_exists delta; then
        echo "✓ delta is already installed, skipping..."
    else
        echo "→ Installing delta..."
        DELTA_VERSION="0.17.0"
        wget -q "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
        sudo dpkg -i "git-delta_${DELTA_VERSION}_amd64.deb"
        rm "git-delta_${DELTA_VERSION}_amd64.deb"
        echo "✓ delta installed successfully"
    fi
    echo

    install_tool "fd" "sudo apt install -y fd-find && sudo ln -sf \$(which fdfind) /usr/local/bin/fd 2>/dev/null || true"
    install_tool "rg" "sudo apt install -y ripgrep"

    # fzf
    if command_exists fzf; then
        echo "✓ fzf is already installed, skipping..."
    else
        echo "→ Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
        echo "✓ fzf installed successfully"
    fi
    echo

    # zoxide
    if command_exists zoxide; then
        echo "✓ zoxide is already installed, skipping..."
    else
        echo "→ Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        echo "✓ zoxide installed successfully"
    fi
    echo
fi

echo
echo "======================================"
echo "Configuring Git to use delta..."
echo "======================================"
echo

if command_exists delta; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global merge.conflictstyle diff3
    git config --global diff.colorMoved default
    echo "✓ Git configured to use delta"
else
    echo "⚠ delta not found, skipping git configuration"
fi

echo
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo
echo "Installed tools:"
command_exists delta && echo "  ✓ delta: $(delta --version)"
command_exists fd && echo "  ✓ fd: $(fd --version)"
command_exists rg && echo "  ✓ ripgrep: $(rg --version | head -1)"
command_exists fzf && echo "  ✓ fzf: $(fzf --version)"
command_exists zoxide && echo "  ✓ zoxide: $(zoxide --version)"
echo
echo "Shell configuration needed:"
echo
echo "For fish shell, add to ~/.config/fish/config.fish:"
echo "  # zoxide"
echo "  zoxide init fish | source"
echo
echo "  # fzf key bindings (already set up if you ran fzf install)"
echo
echo "For bash, add to ~/.bashrc:"
echo "  # zoxide"
echo "  eval \"\$(zoxide init bash)\""
echo
echo "  # fzf (already set up if you ran fzf install)"
echo
echo "Usage examples:"
echo "  fd pattern          # find files"
echo "  rg pattern          # search in files"
echo "  z dirname           # jump to directory"
echo "  vim \$(fzf)          # open file with fuzzy search"
echo "  git diff            # now uses delta"
echo
