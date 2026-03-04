#!/usr/bin/env bash
set -euo pipefail

# Source shared helpers
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Installing AWS CLI v2 for macOS..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    run_privileged installer -pkg AWSCLIV2.pkg -target /
    rm -f AWSCLIV2.pkg
    echo "AWS CLI v2 installed on macOS."
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Installing AWS CLI v2 for Linux..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_ALT}.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    if [ "$CAN_SUDO" = true ]; then
        run_privileged ./aws/install
    else
        ensure_local_bin
        ./aws/install --install-dir "$HOME/.local/aws-cli" --bin-dir "$HOME/.local/bin"
    fi
    rm -rf awscliv2.zip aws
    echo "AWS CLI v2 installed on Linux."
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo
aws --version || echo "AWS CLI installation check failed."
