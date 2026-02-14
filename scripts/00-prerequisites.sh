#!/usr/bin/env bash
set -euo pipefail

# Add wslu PPA for WSL utilities (wslview opens browser from WSL)
if ! grep -q "wslutilities/wslu" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "Adding wslu PPA..."
    sudo add-apt-repository -y ppa:wslutilities/wslu
fi

# Install essential apt packages if missing
PACKAGES=(build-essential curl git gnupg wget python3-pip python3-venv dnsutils stow wslu)

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
