#!/usr/bin/env bash
# Centralizes user-specific values. Most are derived from gh after auth.
# Source this file after gh auth is complete.

set -euo pipefail

# Derived from GitHub API
GH_USER=$(gh api user -q '.login')
GH_ID=$(gh api user -q '.id')
GIT_EMAIL="${GH_ID}+${GH_USER}@users.noreply.github.com"
GIT_NAME="$GH_USER"

# Bitwarden item names (overridable via env)
BW_SSH_ITEM="${BW_SSH_ITEM:-WSL SSH Key}"
BW_GPG_ITEM="${BW_GPG_ITEM:-WSL GPG Key}"

export GH_USER GH_ID GIT_EMAIL GIT_NAME BW_SSH_ITEM BW_GPG_ITEM
