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
    if [ "$CAN_SUDO" = false ]; then
        echo "  (no sudo available - will install to ~/.local/bin where possible)"
    fi
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

if [ "$NONINTERACTIVE" = false ]; then
    read -p "Continue? (y/N) " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

echo

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
    if [ "$CAN_SUDO" = true ]; then
        echo "Updating package lists..."
        run_privileged apt update
        echo

        # delta via .deb
        if command_exists delta; then
            echo "✓ delta is already installed, skipping..."
        else
            echo "→ Installing delta..."
            DELTA_VERSION="0.17.0"
            wget -q "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb"
            run_privileged dpkg -i "git-delta_${DELTA_VERSION}_${ARCH}.deb"
            rm "git-delta_${DELTA_VERSION}_${ARCH}.deb"
            echo "✓ delta installed successfully"
        fi
        echo

        install_tool "fd" "run_privileged apt install -y fd-find && run_privileged ln -sf \$(which fdfind) /usr/local/bin/fd 2>/dev/null || true"
        install_tool "rg" "run_privileged apt install -y ripgrep"
    else
        # No sudo: install from binary tarballs
        ensure_local_bin

        # delta binary tarball
        if command_exists delta; then
            echo "✓ delta is already installed, skipping..."
        else
            echo "→ Installing delta (binary)..."
            DELTA_VERSION="0.17.0"
            curl -Lo delta.tar.gz "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${ARCH_ALT}-unknown-linux-gnu.tar.gz"
            tar xf delta.tar.gz
            install "delta-${DELTA_VERSION}-${ARCH_ALT}-unknown-linux-gnu/delta" "$LOCAL_BIN/delta"
            rm -rf delta.tar.gz "delta-${DELTA_VERSION}-${ARCH_ALT}-unknown-linux-gnu"
            if command_exists delta; then
                echo "✓ delta installed successfully"
            else
                echo "✗ Failed to install delta"
            fi
        fi
        echo

        # fd binary tarball
        if command_exists fd; then
            echo "✓ fd is already installed, skipping..."
        else
            echo "→ Installing fd (binary)..."
            FD_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo fd.tar.gz "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-${ARCH_ALT}-unknown-linux-gnu.tar.gz"
            tar xf fd.tar.gz
            install "fd-v${FD_VERSION}-${ARCH_ALT}-unknown-linux-gnu/fd" "$LOCAL_BIN/fd"
            rm -rf fd.tar.gz "fd-v${FD_VERSION}-${ARCH_ALT}-unknown-linux-gnu"
            if command_exists fd; then
                echo "✓ fd installed successfully"
            else
                echo "✗ Failed to install fd"
            fi
        fi
        echo

        # ripgrep binary tarball
        if command_exists rg; then
            echo "✓ rg is already installed, skipping..."
        else
            echo "→ Installing ripgrep (binary)..."
            RG_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
            curl -Lo rg.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-${ARCH_ALT}-unknown-linux-musl.tar.gz"
            tar xf rg.tar.gz
            install "ripgrep-${RG_VERSION}-${ARCH_ALT}-unknown-linux-musl/rg" "$LOCAL_BIN/rg"
            rm -rf rg.tar.gz "ripgrep-${RG_VERSION}-${ARCH_ALT}-unknown-linux-musl"
            if command_exists rg; then
                echo "✓ rg installed successfully"
            else
                echo "✗ Failed to install rg"
            fi
        fi
        echo
    fi

    # fzf (already user-local via git clone)
    if command_exists fzf; then
        echo "✓ fzf is already installed, skipping..."
    else
        echo "→ Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
        echo "✓ fzf installed successfully"
    fi
    echo

    # zoxide (already user-local via install script)
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
