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

echo "Post-install fixups complete."
