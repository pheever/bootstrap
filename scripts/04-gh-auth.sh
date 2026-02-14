#!/usr/bin/env bash
set -euo pipefail

# Refresh scopes needed for SSH key upload
echo "Refreshing OAuth scopes (admin:public_key)..."
gh auth refresh -h github.com -s admin:public_key

# Upload SSH public key to GitHub
SSH_KEY="$HOME/.ssh/github_ed25519.pub"
if [ -f "$SSH_KEY" ]; then
    if ! gh ssh-key list | grep -qf "$SSH_KEY"; then
        echo "Uploading SSH key to GitHub..."
        gh ssh-key add "$SSH_KEY" -t "WSL $(hostname)"
    else
        echo "SSH key already on GitHub."
    fi
else
    echo "ERROR: SSH public key not found at $SSH_KEY"
    exit 1
fi

# Switch to SSH protocol
echo "Switching to SSH authentication..."
gh auth login -h github.com -p ssh
gh config set git_protocol ssh -h github.com

# Refresh scopes needed for GPG key upload (after SSH login)
echo "Refreshing OAuth scopes (write:gpg_key)..."
gh auth refresh -h github.com -s write:gpg_key

echo "GitHub CLI authenticated via SSH."
