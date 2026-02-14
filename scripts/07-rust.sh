#!/usr/bin/env bash
set -euo pipefail

if command -v rustup &>/dev/null; then
    echo "Rustup already installed, updating..."
    rustup update stable
else
    echo "Installing rustup with stable toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
fi

echo "Rust toolchain ready."
