#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    else
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Add brew shellenv to .bashrc if not already present
SHELLENV_LINE='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"'
if ! grep -qF "$SHELLENV_LINE" "$HOME/.bashrc" 2>/dev/null; then
    echo "Adding Homebrew to .bashrc..."
    echo >> "$HOME/.bashrc"
    echo "$SHELLENV_LINE" >> "$HOME/.bashrc"
fi

echo "Running brew bundle..."
brew bundle --file="$REPO_DIR/Brewfile"
echo "Homebrew packages up to date."
