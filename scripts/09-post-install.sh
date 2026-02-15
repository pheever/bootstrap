#!/usr/bin/env bash
set -euo pipefail

# Create common directories
DIRS=(
    "$HOME/source"
    "$HOME/.ssh"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Creating $dir..."
        mkdir -p "$dir"
    fi
done

# Ensure SSH directory permissions
chmod 700 "$HOME/.ssh" 2>/dev/null || true

# Install Node.js via fnm
if ! command -v fnm &>/dev/null; then
    echo "ERROR: fnm not found. Run 02-homebrew.sh first."
    exit 1
fi

eval "$(fnm env)"
if ! fnm list 2>/dev/null | grep -q "lts-latest"; then
    echo "Installing Node.js LTS via fnm..."
    fnm install --lts
    fnm default lts-latest
fi

# Install Claude Code CLI
if ! command -v claude &>/dev/null; then
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
else
    echo "Claude Code already installed."
fi

echo "Post-install fixups complete."
