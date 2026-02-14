#!/usr/bin/env bash
set -euo pipefail

FISH_PATH="$(command -v fish 2>/dev/null || echo /home/linuxbrew/.linuxbrew/bin/fish)"

if [ ! -x "$FISH_PATH" ]; then
    echo "ERROR: fish not found. Install it first (brew install fish)."
    exit 1
fi

# Add fish to /etc/shells if not already there
if ! grep -qxF "$FISH_PATH" /etc/shells; then
    echo "Adding $FISH_PATH to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Change default shell to fish
CURRENT_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
    echo "Changing default shell to fish..."
    sudo chsh -s "$FISH_PATH" "$(whoami)"
    echo "Default shell changed to $FISH_PATH"
else
    echo "Default shell is already fish."
fi
