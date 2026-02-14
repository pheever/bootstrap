#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

STOW_PACKAGES=(fish git starship gh claude misc)

cd "$REPO_DIR"

for pkg in "${STOW_PACKAGES[@]}"; do
    # For the git package, only stow .config/git (not .gitconfig.tmpl)
    echo "Stowing $pkg..."
    stow --restow --target="$HOME" "$pkg"
done

echo "All Stow packages linked."
