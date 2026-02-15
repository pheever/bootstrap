#!/usr/bin/env bash
set -euo pipefail

if command -v gcloud &>/dev/null; then
    echo "gcloud already installed: $(gcloud version 2>/dev/null | head -1)"
    exit 0
fi

echo "Installing Google Cloud SDK..."

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

# Add Google Cloud GPG key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

# Install
sudo apt-get update
sudo apt-get install -y google-cloud-cli

echo "gcloud installed: $(gcloud version 2>/dev/null | head -1)"
echo "Run 'gcloud init' to authenticate."
