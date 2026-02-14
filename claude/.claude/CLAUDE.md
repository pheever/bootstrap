# Bootstrap Repo Instructions

## Dotfile Workflow

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for dotfile management. Each top-level directory (fish, git, starship, claude, misc) is a stow package that mirrors the home directory structure.

**Adding or editing dotfiles (e.g. fish functions, configs):**

1. Make changes directly in the repo directory, e.g.:
   - `bootstrap/fish/.config/fish/functions/my_function.fish`
   - `bootstrap/fish/.config/fish/conf.d/my_config.fish`
2. Run `stow --restow <package>` from the repo root (or run `bash scripts/05-stow.sh`) to create/update symlinks
3. Commit and push

**Do NOT** create files in `~/.config/` directly — they won't be tracked. Always create in the repo first, then stow.

## Stow Packages

| Directory | What it manages |
|---|---|
| `fish/` | Fish shell config, functions, conf.d |
| `git/` | .gitconfig.tmpl, .config/git/ignore |
| `starship/` | Starship prompt config |
| `claude/` | Claude Code settings |
| `misc/` | .hushlogin |
