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
done

echo "=== Bootstrap complete ==="
