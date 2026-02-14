# WSL Bootstrap

Restore a full WSL dev environment from scratch after a distro reset.

Uses [GNU Stow](https://www.gnu.org/software/stow/) for dotfile management, [Bitwarden CLI](https://bitwarden.com/help/cli/) for SSH/GPG key retrieval, and [GitHub CLI](https://cli.github.com/) for authentication.

## Fresh Machine Bootstrap

On a brand new Ubuntu WSL distro:

```bash
sudo apt-get update && sudo apt-get install -y curl git
git clone https://github.com/pheever/bootstrap.git ~/source/github.com/pheever/bootstrap
cd ~/source/github.com/pheever/bootstrap && bash bootstrap.sh
```

> **Note:** After the distro is first installed in Windows, restart it before running the bootstrap (close the terminal and reopen it).

The bootstrap runs in three phases:

1. **Automated** — apt packages, sudoers, Homebrew install + Brewfile (needs sudo password once)
2. **Interactive** (~60s) — Bitwarden master password + GitHub device code auth
3. **Unattended** — SSH keys, GPG key, stow, rust, fish shell (walk away)

## What It Does

`bootstrap.sh` runs these scripts in order:

| Script | Purpose |
|---|---|
| `00-prerequisites.sh` | Install essential apt packages (build-essential, stow, etc.) |
| `01-sudoers.sh` | Passwordless sudo for `apt-get update/upgrade/autoremove/autoclean` |
| `02-homebrew.sh` | Install Homebrew (if missing) + packages from `Brewfile` |
| `03-bitwarden-ssh.sh` | Retrieve SSH keys from Bitwarden vault |
| `04-gh-auth.sh` | Upload SSH key to GitHub, configure SSH protocol |
| `05-stow.sh` | Symlink dotfiles into `$HOME` |
| `06-gpg.sh` | Import GPG key from Bitwarden, render `.gitconfig`, upload key to GitHub |
| `07-rust.sh` | Install rustup + stable toolchain |
| `08-shell.sh` | Add fish to `/etc/shells`, set as default shell |
| `09-post-install.sh` | Create directories, install CLI tools |

All scripts are **idempotent** — safe to re-run individually or as a group.

## Repo Structure

```
bootstrap/
├── bootstrap.sh              # Main entry point
├── config.sh                 # User-specific values (derived from gh)
├── Brewfile                  # Homebrew packages
├── Makefile                  # Day-to-day maintenance targets
├── scripts/                  # Bootstrap phases (00-09)
├── fish/.config/fish/        # Fish shell config (Stow package)
├── git/                      # .gitconfig.tmpl + .config/git/ignore
├── starship/.config/         # Starship prompt config
├── claude/.claude/           # Claude Code settings
└── misc/                     # .hushlogin
```

## Bitwarden SSH Key Setup (One-Time)

Before running bootstrap on a new machine, generate and store your SSH keys in Bitwarden:

```bash
ssh-keygen -t ed25519 -a 100 -C "<username>@github" -f ~/.ssh/github_ed25519
```

1. Create a **Secure Note** in Bitwarden named **"WSL SSH Key"**
2. Paste the **private key** contents into the **Notes** field
3. Add a **custom text field** named `public_key` with the **public key** contents
4. Add a **custom text field** named `passphrase_item_id` linking to a Login item with the passphrase
5. Save the item

The key should be **passphrase-protected** (`-a 100` increases KDF rounds). Keychain will prompt for the passphrase once per boot.

## Maintenance

```bash
cd ~/source/github.com/<username>/bootstrap

make status      # Show changed files
make restow      # Re-run stow for all packages
make sync-brew   # Dump current brew list to Brewfile
make stage       # Stage all changes (commit manually — GPG passphrase needed)
make pull        # Pull latest + restow
make bootstrap   # Run full bootstrap
```

## What's NOT Tracked

- `.aws`, `.azure` — managed by their own CLIs
- `.kube/config` — cluster-specific
- `gcloud` credentials — re-auth manually
- `.docker/` — recreated by Docker Desktop
- VS Code extensions — synced by Settings Sync
- `gh/hosts.yml` — auth tokens (re-auth with `gh auth login -h github.com -p ssh -w`)
- `.bashrc`, `.profile` — left as Ubuntu defaults
