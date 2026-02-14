#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/github_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "SSH key already exists at $SSH_KEY, skipping."
    exit 0
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

# Retrieve passphrase via linked item and add key to keychain
PASS_ITEM_ID=$(echo "$ITEM" | jq -r '.fields[] | select(.name == "passphrase_item_id") | .value')
if [ -n "$PASS_ITEM_ID" ]; then
    PASSPHRASE=$(bw get item "$PASS_ITEM_ID" | jq -r '.login.password')
    if [ -n "$PASSPHRASE" ]; then
        eval "$(keychain --eval --quiet)"
        ASKPASS=$(mktemp /dev/shm/.ssh-askpass.XXXXXX)
        printf '#!/bin/sh\necho "%s"\n' "$PASSPHRASE" > "$ASKPASS"
        chmod 700 "$ASKPASS"
        SSH_ASKPASS="$ASKPASS" SSH_ASKPASS_REQUIRE=force ssh-add "$SSH_KEY" </dev/null
        rm -f "$ASKPASS"
        unset PASSPHRASE
        echo "SSH key added to keychain."
    fi
fi

# Lock the vault
bw lock
