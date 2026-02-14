#!/usr/bin/env bash
set -euo pipefail

# Expects BW_SESSION, BW_GPG_ITEM, GIT_EMAIL, GIT_NAME set by bootstrap.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$REPO_DIR/git/.gitconfig.tmpl"
TARGET="$HOME/.gitconfig"

if [ -z "${GIT_EMAIL:-}" ]; then
    echo "ERROR: GIT_EMAIL not set. Run this script via bootstrap.sh."
    exit 1
fi

# Check if a GPG key for our email already exists
EXISTING_KEY=$(gpg --list-secret-keys --keyid-format long "$GIT_EMAIL" 2>/dev/null \
    | grep -oP '(?<=sec\s{3}ed25519/)[A-F0-9]+' || true)

if [ -n "$EXISTING_KEY" ]; then
    echo "GPG key already exists: $EXISTING_KEY"
    KEY_ID="$EXISTING_KEY"
else
    if [ -z "${BW_SESSION:-}" ]; then
        echo "ERROR: BW_SESSION not set. Run this script via bootstrap.sh."
        exit 1
    fi

    echo "Retrieving GPG key from Bitwarden..."
    ITEM=$(bw get item "${BW_GPG_ITEM:-WSL GPG Key}")

    PRIVATE_KEY=$(echo "$ITEM" | yq -r '.notes')
    KEY_ID=$(echo "$ITEM" | yq -r '.fields[] | select(.name == "key_id") | .value')

    if [ -z "$PRIVATE_KEY" ] || [ -z "$KEY_ID" ]; then
        echo "ERROR: Could not retrieve GPG key from Bitwarden."
        echo "Make sure an item named '${BW_GPG_ITEM:-WSL GPG Key}' exists with custom fields:"
        echo "  - 'private_key' with the armored private key"
        echo "  - 'key_id' with the key ID"
        exit 1
    fi

    # Import the private key (passphrase via fd 3 to avoid process-list leak)
    PASS_ITEM_ID=$(echo "$ITEM" | yq -r '.fields[] | select(.name == "passphrase_item_id") | .value')
    if [ -n "$PASS_ITEM_ID" ] && [ "$PASS_ITEM_ID" != "null" ]; then
        PASSPHRASE=$(bw get item "$PASS_ITEM_ID" | yq -r '.login.password')
        gpg --batch --pinentry-mode loopback \
            --passphrase-fd 3 --import 3<<< "$PASSPHRASE" <<< "$PRIVATE_KEY"
        unset PASSPHRASE
    else
        gpg --batch --import <<< "$PRIVATE_KEY"
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
fi

# Render .gitconfig from template
echo "Rendering .gitconfig with key $KEY_ID..."
sed -e "s/__GPG_KEY_ID__/$KEY_ID/g" \
    -e "s/__GIT_EMAIL__/$GIT_EMAIL/g" \
    -e "s/__GIT_NAME__/$GIT_NAME/g" \
    "$TEMPLATE" > "$TARGET"
echo ".gitconfig written to $TARGET"
