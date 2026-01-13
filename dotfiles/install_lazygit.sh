#!/usr/bin/env bash
set -euo pipefail

echo "Installing lazygit..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Installing lazygit via Homebrew..."
    brew install lazygit
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo
lazygit --version || echo "lazygit installation check failed."
