#!/usr/bin/env bash
# Shared helper library for installer scripts.
# Source this file at the top of each installer:
#   source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

# --- Architecture detection ---
detect_arch() {
    local machine
    machine="$(uname -m)"
    case "$machine" in
        x86_64)
            ARCH="amd64"
            ARCH_ALT="x86_64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ARCH_ALT="aarch64"
            ;;
        *)
            echo "Unsupported architecture: $machine"
            exit 1
            ;;
    esac
}

# --- Privilege detection ---
detect_privileges() {
    if [ "$(id -u)" -eq 0 ]; then
        CAN_SUDO=true
        LOCAL_BIN="/usr/local/bin"
    elif command -v sudo >/dev/null 2>&1; then
        CAN_SUDO=true
        LOCAL_BIN="/usr/local/bin"
    else
        CAN_SUDO=false
        LOCAL_BIN="$HOME/.local/bin"
    fi
}

# Run a command with sudo if needed. Returns 1 (instead of exit) when no sudo.
run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "Warning: No root privileges available. Skipping: $*"
        return 1
    fi
}

# Ensure ~/.local/bin exists and is on PATH.
ensure_local_bin() {
    mkdir -p "$HOME/.local/bin"

    # Add to current session PATH if not already present
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac

    # Persist to shell config files
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    for rc in "$HOME/.bashrc" "$HOME/.profile"; do
        if [ -f "$rc" ] && ! grep -qF '.local/bin' "$rc"; then
            echo "" >> "$rc"
            echo "# Added by tools installer" >> "$rc"
            echo "$path_line" >> "$rc"
        fi
    done
}

# Install a binary file to LOCAL_BIN using sudo or directly.
# Usage: install_binary <source_file> <binary_name>
install_binary() {
    local src="$1"
    local name="$2"
    if [ "$CAN_SUDO" = true ] && [ "$LOCAL_BIN" = "/usr/local/bin" ]; then
        run_privileged install "$src" "$LOCAL_BIN/$name"
    else
        ensure_local_bin
        install "$src" "$LOCAL_BIN/$name"
    fi
}

# Check if a command exists.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install a tool if not already present.
# Usage: install_tool <command_name> <install_command_string>
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

# --- Auto-detect on source ---
detect_arch
detect_privileges
