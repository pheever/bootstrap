#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$REPO_DIR/git/.gitconfig.tmpl"
TARGET="$HOME/.gitconfig"

EMAIL="25864640+pheever@users.noreply.github.com"

# Check if a GPG key for our email already exists
EXISTING_KEY=$(gpg --list-secret-keys --keyid-format long "$EMAIL" 2>/dev/null \
    | grep -oP '(?<=sec\s{3}ed25519/)[A-F0-9]+' || true)

if [ -n "$EXISTING_KEY" ]; then
    echo "GPG key already exists: $EXISTING_KEY"
    KEY_ID="$EXISTING_KEY"
else
    echo "Retrieving GPG key from Bitwarden..."

    # Ensure Bitwarden is unlocked
    if ! bw login --check &>/dev/null; then
        echo "Please log in to Bitwarden:"
        export BW_SESSION=$(bw login --raw)
    else
        if ! bw unlock --check &>/dev/null; then
            echo "Please unlock your Bitwarden vault:"
            export BW_SESSION=$(bw unlock --raw)
        fi
    fi

    ITEM=$(bw get item "WSL GPG Key")

    PRIVATE_KEY=$(echo "$ITEM" | jq -r '.notes')
    KEY_ID=$(echo "$ITEM" | jq -r '.fields[] | select(.name == "key_id") | .value')

    if [ -z "$PRIVATE_KEY" ] || [ -z "$KEY_ID" ]; then
        echo "ERROR: Could not retrieve GPG key from Bitwarden."
        echo "Make sure a Secure Note named 'WSL GPG Key' exists with:"
        echo "  - Private key (armored) in the Notes field"
        echo "  - Custom text field 'key_id' with the key ID"
        exit 1
    fi

    # Import the private key (passphrase required for protected keys)
    PASS_ITEM_ID=$(echo "$ITEM" | jq -r '.fields[] | select(.name == "passphrase_item_id") | .value')
    if [ -n "$PASS_ITEM_ID" ] && [ "$PASS_ITEM_ID" != "null" ]; then
        PASSPHRASE=$(bw get item "$PASS_ITEM_ID" | jq -r '.login.password')
        echo "$PRIVATE_KEY" | gpg --batch --passphrase "$PASSPHRASE" --import
        unset PASSPHRASE
    else
        echo "$PRIVATE_KEY" | gpg --batch --import
    fi

    echo "GPG key imported: $KEY_ID"

    # Upload public key to GitHub
    if command -v gh &>/dev/null; then
        echo "Uploading GPG key to GitHub..."
        gpg --armor --export "$KEY_ID" | gh gpg-key add -
        echo "GPG key uploaded to GitHub."
    else
        echo "WARNING: gh CLI not found, skipping GitHub upload."
        echo "Run manually: gpg --armor --export $KEY_ID | gh gpg-key add -"
    fi

    bw lock
fi

# Render .gitconfig from template
echo "Rendering .gitconfig with key $KEY_ID..."
sed "s/__GPG_KEY_ID__/$KEY_ID/g" "$TEMPLATE" > "$TARGET"
echo ".gitconfig written to $TARGET"
