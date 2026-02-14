#!/usr/bin/env bash
set -euo pipefail

# Install essential apt packages if missing
PACKAGES=(build-essential curl git gnupg wget python3-pip python3-venv dnsutils stow)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Installing missing packages: ${MISSING[*]}"
    sudo apt-get update
    sudo apt-get install -y "${MISSING[@]}"
else
    echo "All prerequisite packages already installed."
fi
