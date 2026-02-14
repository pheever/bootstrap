#!/usr/bin/env bash
set -euo pipefail

# Non-interactive: expects gh already authenticated with all scopes via bootstrap.sh

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
gh config set git_protocol ssh -h github.com

echo "GitHub CLI configured for SSH."
