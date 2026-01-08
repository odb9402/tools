#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Installing AWS CLI v2 for macOS..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    echo "AWS CLI v2 installed on macOS."
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Installing AWS CLI v2 for Linux..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    echo "AWS CLI v2 installed on Linux."
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo
aws --version || echo "AWS CLI installation check failed."
 