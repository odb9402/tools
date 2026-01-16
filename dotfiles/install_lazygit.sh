#!/usr/bin/env bash
set -euo pipefail

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

echo "Installing lazygit..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Installing lazygit via Homebrew..."
    brew install lazygit
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    run_privileged install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo
lazygit --version || echo "lazygit installation check failed."
