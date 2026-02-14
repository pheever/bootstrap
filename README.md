# WSL Bootstrap

Restore a full WSL dev environment from scratch after a distro reset.

Uses [GNU Stow](https://www.gnu.org/software/stow/) for dotfile management, [Bitwarden CLI](https://bitwarden.com/help/cli/) for SSH key retrieval, and fresh GPG key generation on each bootstrap.

## Fresh Machine Bootstrap

On a brand new Ubuntu WSL distro:

```bash
sudo apt-get update && sudo apt-get install -y curl git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gh
gh auth login
git clone https://github.com/pheever/bootstrap.git ~/source/github.com/pheever/bootstrap
cd ~/source/github.com/pheever/bootstrap
bash bootstrap.sh
```

> **Note:** After the distro is first installed in Windows, restart it before running the bootstrap (close the terminal and reopen it).

## What It Does

`bootstrap.sh` runs these scripts in order:

| Script | Purpose |
|---|---|
| `00-prerequisites.sh` | Install essential apt packages (build-essential, stow, etc.) |
| `01-sudoers.sh` | Passwordless sudo for `apt-get update/upgrade/autoremove/autoclean` |
| `02-homebrew.sh` | Install Homebrew packages from `Brewfile` |
| `03-bitwarden-ssh.sh` | Retrieve SSH keys from Bitwarden vault |
| `04-stow.sh` | Symlink dotfiles into `$HOME` |
| `05-gpg.sh` | Generate GPG key, render `.gitconfig`, upload key to GitHub |
| `06-rust.sh` | Install rustup + stable toolchain |
| `07-shell.sh` | Add fish to `/etc/shells`, set as default shell |
| `08-post-install.sh` | Create directories, misc fixups |

All scripts are **idempotent** — safe to re-run individually or as a group.

## Repo Structure

```
bootstrap/
├── bootstrap.sh              # Main entry point
├── Brewfile                   # Homebrew packages
├── apt-packages.txt           # Manually-installed apt packages
├── scripts/                   # Bootstrap phases (00-08)
├── fish/.config/fish/         # Fish shell config (Stow package)
├── git/                       # .gitconfig.tmpl + .config/git/ignore
├── starship/.config/          # Starship prompt config
├── gh/.config/gh/             # GitHub CLI config
├── claude/.claude/            # Claude Code settings
└── misc/                      # .hushlogin
```

## Bitwarden SSH Key Setup (One-Time)

Before running bootstrap on a new machine, store your SSH keys in Bitwarden:

1. Create a **Secure Note** in Bitwarden named **"WSL SSH Key"**
2. Paste the **private key** contents into the **Notes** field
3. Add a **custom text field** named `public_key` with the **public key** contents
4. Save the item

The bootstrap script will retrieve these keys and write them to `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`.

## Maintenance

After changing dotfiles on a running machine:

```bash
cd ~/source/github.com/pheever/bootstrap
# Copy changed files into the appropriate Stow package directory
# Then commit and push
git add -A && git commit -m "update dotfiles" && git push
```

After adding a new Homebrew package:

```bash
# Add the package to Brewfile, then:
brew bundle --file=Brewfile
git add Brewfile && git commit -m "add <package> to Brewfile" && git push
```

## What's NOT Tracked

- `.aws`, `.azure` — managed by their own CLIs
- `.kube/config` — cluster-specific
- `gcloud` credentials — re-auth manually
- `.docker/` — recreated by Docker Desktop
- VS Code extensions — synced by Settings Sync
- `gh/hosts.yml` — auth tokens (re-auth with `gh auth login`)
- `.bashrc`, `.profile` — left as Ubuntu defaults
