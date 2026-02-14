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
    echo "Generating new GPG key (ed25519)..."
    gpg --batch --gen-key <<EOF
Key-Type: eddsa
Key-Curve: ed25519
Key-Usage: sign
Name-Real: pheever
Name-Email: $EMAIL
Expire-Date: 0
%no-protection
%commit
EOF

    KEY_ID=$(gpg --list-secret-keys --keyid-format long "$EMAIL" 2>/dev/null \
        | grep -oP '(?<=sec\s{3}ed25519/)[A-F0-9]+')

    echo "Generated GPG key: $KEY_ID"

    # Upload to GitHub
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
sed "s/__GPG_KEY_ID__/$KEY_ID/g" "$TEMPLATE" > "$TARGET"
echo ".gitconfig written to $TARGET"
