#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REPO_DIR"

for pkg in */; do
    pkg="${pkg%/}"
    [ "$pkg" = "scripts" ] && continue
    echo "Stowing $pkg..."
    stow --restow --target="$HOME" "$pkg"
done

echo "All Stow packages linked."
