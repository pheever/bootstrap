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

# Install Claude Code CLI
if ! command -v claude &>/dev/null; then
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
else
    echo "Claude Code already installed."
fi

echo "Post-install fixups complete."
