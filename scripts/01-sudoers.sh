#!/usr/bin/env bash
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/apt_updates"
CURRENT_USER="$(whoami)"

if [ -f "$SUDOERS_FILE" ]; then
    echo "Sudoers override already exists at $SUDOERS_FILE, skipping."
else
    echo "Creating sudoers override for passwordless apt-get update/upgrade/autoremove/autoclean..."
    TMPFILE=$(mktemp)
    cat > "$TMPFILE" <<EOF
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/apt-get update, /usr/bin/apt-get upgrade -y, /usr/bin/apt-get autoremove -y, /usr/bin/apt-get autoclean
EOF
    # Validate syntax before installing
    if sudo visudo -cf "$TMPFILE"; then
        sudo cp "$TMPFILE" "$SUDOERS_FILE"
        sudo chmod 0440 "$SUDOERS_FILE"
        echo "Done."
    else
        echo "ERROR: sudoers syntax validation failed."
        rm -f "$TMPFILE"
        exit 1
    fi
    rm -f "$TMPFILE"
fi
