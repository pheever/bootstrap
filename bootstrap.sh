#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== WSL Bootstrap ==="
echo ""

for script in "$SCRIPT_DIR"/scripts/0[0-9]-*.sh; do
    name="$(basename "$script")"
    echo ">>> Running $name ..."
    bash "$script"
    echo ">>> $name done."
    echo ""

    # After Homebrew script, add brew to PATH for subsequent scripts
    if [[ "$name" == 02-homebrew.sh ]] && ! command -v brew &>/dev/null; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
done

echo "=== Bootstrap complete ==="

# Replace current shell with fish
exec "$(/home/linuxbrew/.linuxbrew/bin/brew --prefix)/bin/fish" -l
