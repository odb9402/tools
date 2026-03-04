#!/usr/bin/env bash
set -euo pipefail

# Source shared helpers
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

echo "Installing lazygit..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Installing lazygit via Homebrew..."
    brew install lazygit
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    LAZYGIT_ARCH="${ARCH_ALT}"; [ "$ARCH" = "arm64" ] && LAZYGIT_ARCH="arm64"
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_linux_${LAZYGIT_ARCH}.tar.gz"
    tar xf lazygit.tar.gz lazygit
    install_binary lazygit lazygit
    rm -f lazygit lazygit.tar.gz
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo
lazygit --version || echo "lazygit installation check failed."
