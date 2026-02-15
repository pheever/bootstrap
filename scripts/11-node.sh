#!/usr/bin/env bash
set -euo pipefail

echo "=== Node.js via fnm ==="

# fnm should be installed via Homebrew already
if ! command -v fnm &>/dev/null; then
    echo "ERROR: fnm not found. Run 02-homebrew.sh first."
    exit 1
fi

# Install latest LTS Node.js
echo "Installing Node.js LTS..."
fnm install --lts

# Set default to LTS
echo "Setting LTS as default..."
fnm default lts-latest

# Verify installation
echo ""
echo "Node version: $(fnm exec --using=lts-latest node --version)"
echo "npm version: $(fnm exec --using=lts-latest npm --version)"

# Install global packages
echo ""
echo "Installing global npm packages..."
fnm exec --using=lts-latest npm install -g --fund false \
    @anthropic-ai/claude-code \
    npm@latest

echo ""
echo "Global packages installed:"
fnm exec --using=lts-latest npm list -g --depth=0

echo ""
echo "Node.js setup complete."
echo "NOTE: Restart your shell or run 'fnm env --use-on-cd | source' to activate."
