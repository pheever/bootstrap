#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "SSH key already exists at $SSH_KEY, skipping."
    exit 0
fi

# Ensure bw CLI is available
if ! command -v bw &>/dev/null; then
    echo "Installing Bitwarden CLI..."
    brew install bitwarden-cli
fi

# Check login status
if ! bw login --check &>/dev/null; then
    echo "Please log in to Bitwarden:"
    export BW_SESSION=$(bw login --raw)
else
    if ! bw unlock --check &>/dev/null; then
        echo "Please unlock your Bitwarden vault:"
        export BW_SESSION=$(bw unlock --raw)
    fi
fi

echo "Retrieving SSH keys from Bitwarden..."
ITEM=$(bw get item "WSL SSH Key")

PRIVATE_KEY=$(echo "$ITEM" | jq -r '.notes')
PUBLIC_KEY=$(echo "$ITEM" | jq -r '.fields[] | select(.name == "public_key") | .value')

if [ -z "$PRIVATE_KEY" ] || [ -z "$PUBLIC_KEY" ]; then
    echo "ERROR: Could not retrieve SSH keys from Bitwarden."
    echo "Make sure a Secure Note named 'WSL SSH Key' exists with:"
    echo "  - Private key in the Notes field"
    echo "  - Public key as a custom field named 'public_key'"
    exit 1
fi

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo "$PRIVATE_KEY" > "$SSH_KEY"
chmod 600 "$SSH_KEY"

echo "$PUBLIC_KEY" > "${SSH_KEY}.pub"
chmod 644 "${SSH_KEY}.pub"

echo "SSH keys restored successfully."

# Lock the vault
bw lock
