#!/usr/bin/env bash
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/apt_updates"
CURRENT_USER="$(whoami)"

if [ -f "$SUDOERS_FILE" ]; then
    echo "Sudoers override already exists at $SUDOERS_FILE, skipping."
else
    echo "Creating sudoers override for passwordless apt-get update/upgrade/autoremove/autoclean..."
    sudo tee "$SUDOERS_FILE" > /dev/null <<EOF
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/apt-get update, /usr/bin/apt-get upgrade *, /usr/bin/apt-get autoremove *, /usr/bin/apt-get autoclean
EOF
    sudo chmod 0440 "$SUDOERS_FILE"
    echo "Done."
fi
