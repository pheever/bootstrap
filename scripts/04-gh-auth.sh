#!/usr/bin/env bash
set -euo pipefail

# Check if already authenticated
if gh auth status &>/dev/null; then
    echo "Already authenticated to GitHub."
else
    echo "Authenticating to GitHub CLI (device code flow, SSH protocol)..."
    gh auth login -h github.com -p ssh -w
    echo "GitHub CLI authenticated."
fi

# Ensure git protocol is set to SSH
gh config set git_protocol ssh -h github.com
