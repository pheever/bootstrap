#!/usr/bin/env bash
set -euo pipefail

# Expects BW_SESSION and BW_SSH_ITEM set by bootstrap.sh

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/github_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "SSH key already exists at $SSH_KEY, skipping."
    exit 0
fi

if [ -z "${BW_SESSION:-}" ]; then
    echo "ERROR: BW_SESSION not set. Run this script via bootstrap.sh."
    exit 1
fi

echo "Retrieving SSH keys from Bitwarden..."
ITEM=$(bw get item "${BW_SSH_ITEM:-WSL SSH Key}")

PRIVATE_KEY=$(echo "$ITEM" | jq -r '.notes')
PUBLIC_KEY=$(echo "$ITEM" | jq -r '.fields[] | select(.name == "public_key") | .value')

if [ -z "$PRIVATE_KEY" ] || [ -z "$PUBLIC_KEY" ]; then
    echo "ERROR: Could not retrieve SSH keys from Bitwarden."
    echo "Make sure a Secure Note named '${BW_SSH_ITEM:-WSL SSH Key}' exists with:"
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
if [ -n "$PASS_ITEM_ID" ] && [ "$PASS_ITEM_ID" != "null" ]; then
    PASSPHRASE=$(bw get item "$PASS_ITEM_ID" | jq -r '.login.password')
    if [ -n "$PASSPHRASE" ]; then
        eval "$(keychain --eval --quiet)"
        ASKPASS=$(mktemp /dev/shm/.ssh-askpass.XXXXXX)
        trap 'rm -f "$ASKPASS" 2>/dev/null' EXIT
        printf '#!/bin/sh\necho "%s"\n' "$PASSPHRASE" > "$ASKPASS"
        chmod 700 "$ASKPASS"
        SSH_ASKPASS="$ASKPASS" SSH_ASKPASS_REQUIRE=force ssh-add "$SSH_KEY" </dev/null
        rm -f "$ASKPASS"
        unset PASSPHRASE
        echo "SSH key added to keychain."
    fi
fi
