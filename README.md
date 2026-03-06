# mac-dotfiles

macOS development environment managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

There are three setup scenarios depending on your machine:

### Personal Mac (full access)

```bash
git clone git@github.com:allenbercero/mac-dotfiles.git ~/Development/mac-dotfiles
cd ~/Development/mac-dotfiles
bash bootstrap.sh
```

Installs everything: all Homebrew formulae, all casks (Zed, Ghostty, Obsidian, etc.), and symlinks all dotfiles.

### Work Mac (with sudo/brew access)

```bash
bash bootstrap.sh --work
```

Installs CLI tools and approved casks only (claude-code). Skips Zed, Ghostty, Obsidian, MacTeX, and font casks. Prompts for work git identity.

### Work Mac (no sudo access)

```bash
bash bootstrap.sh --work --no-sudo
```

Skips Homebrew entirely. Symlinks dotfiles using `ln -sf` and prints a list of CLI tools to install manually through your company's software portal.

> After running the bootstrap script, follow the [SETUP.md](SETUP.md) checklist for SSH keys, commit signing, language runtimes, and macOS preferences.

## What's Included

| Package    | Contents                          |
|------------|-----------------------------------|
| zsh        | .zshrc, .zprofile, .p10k.zsh      |
| bash       | .bash_profile                     |
| git        | .gitconfig, identity includes     |
| vim        | .vimrc                            |
| ideavim    | .ideavimrc                        |
| tmux       | .tmux.conf                        |
| ssh        | .ssh/config                       |
| ghostty    | .config/ghostty/config            |
| zed        | .config/zed/settings, keymap      |
| local-bin  | .local/bin/env                    |

## Multi-Machine Identity

Git identity is handled via [conditional includes](https://git-scm.com/docs/git-config#_conditional_includes) in `.gitconfig`:

- **Default**: personal identity (set in `.gitconfig`)
- **Repos under `~/Work/`**: work identity (configured during `--work` setup)

SSH keys use a naming convention (`personal-key` / `work-key`) and are never committed to this repo.

## Adding/Removing Packages

To symlink a single package: `stow -t $HOME <package>`

To unlink: `stow -D -t $HOME <package>`

See [SETUP.md](SETUP.md) for the full fresh-Mac checklist.
