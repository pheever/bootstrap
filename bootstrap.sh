#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== WSL Bootstrap ==="
echo ""

run_script() {
    local script="$1"
    shift
    local name
    name="$(basename "$script")"
    echo ">>> Running $name ..."
    bash "$script" "$@"
    echo ">>> $name done."
    echo ""
}

# ─── Phase 1: Automated (needs sudo — user types password once) ───

run_script "$SCRIPT_DIR/scripts/00-prerequisites.sh"
run_script "$SCRIPT_DIR/scripts/01-sudoers.sh"
run_script "$SCRIPT_DIR/scripts/02-homebrew.sh"

# Ensure brew is on PATH for subsequent scripts
if ! command -v brew &>/dev/null; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ─── Phase 2: Interactive (user present) ───

echo "=== Interactive setup ==="
echo ""

# Bitwarden — master password stays in memory only
NEED_LOGIN=true
if bw login --check &>/dev/null; then
    NEED_LOGIN=false
    echo "Already logged in to Bitwarden."
fi

if [ "$NEED_LOGIN" = true ]; then
    read -rp "Bitwarden email: " BW_EMAIL
fi

for attempt in 1 2 3; do
    read -rsp "Bitwarden master password: " BW_MASTER_PASS
    echo ""

    if [ "$NEED_LOGIN" = true ]; then
        BW_SESSION=$(BW_MASTER_PASS="$BW_MASTER_PASS" bw login "$BW_EMAIL" --passwordenv BW_MASTER_PASS --raw 2>/dev/null) || true
    else
        BW_SESSION=$(BW_MASTER_PASS="$BW_MASTER_PASS" bw unlock --passwordenv BW_MASTER_PASS --raw 2>/dev/null) || true
    fi
    unset BW_MASTER_PASS

    if [ -n "${BW_SESSION:-}" ]; then
        break
    fi

    if [ "$attempt" -lt 3 ]; then
        echo "Invalid master password. Try again ($((3 - attempt)) attempts remaining)."
    else
        echo "ERROR: Failed to authenticate with Bitwarden after 3 attempts."
        exit 1
    fi
done
export BW_SESSION

# Cleanup trap: lock vault and clear session on exit
trap 'bw lock 2>/dev/null; unset BW_SESSION' EXIT

echo "Bitwarden unlocked."
echo ""

# GitHub auth — device code flow (user opens browser)
echo "Authenticating GitHub CLI..."
gh auth login -h github.com -p ssh -w
echo ""

# ─── Derive user config from GitHub API ───

echo "Deriving user config from GitHub..."
# shellcheck source=config.sh
source "$SCRIPT_DIR/config.sh"
echo "  User: $GH_USER"
echo "  Email: $GIT_EMAIL"
echo ""

# ─── Phase 3: Fully unattended (user walks away) ───

echo "=== Unattended setup ==="
echo ""

run_script "$SCRIPT_DIR/scripts/03-bitwarden-ssh.sh"
run_script "$SCRIPT_DIR/scripts/04-gh-auth.sh"
run_script "$SCRIPT_DIR/scripts/05-stow.sh"
run_script "$SCRIPT_DIR/scripts/06-gpg.sh"

# Lock vault now — remaining scripts don't need it
bw lock 2>/dev/null || true
unset BW_SESSION

run_script "$SCRIPT_DIR/scripts/07-rust.sh"
run_script "$SCRIPT_DIR/scripts/08-shell.sh"
run_script "$SCRIPT_DIR/scripts/09-post-install.sh"

echo "=== Bootstrap complete ==="

# Replace current shell with fish
exec "$(/home/linuxbrew/.linuxbrew/bin/brew --prefix)/bin/fish" -l
