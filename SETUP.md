# Fresh Mac Setup Checklist

> **Important:** Before running the bootstrap, update the placeholder emails and names in these files with your own:
> - `git/.gitconfig` — your personal name and email
> - `git/.gitconfig-personal` — your personal name, email, and signing key path
> - `git/.gitconfig-work` — your work name, email, and signing key path

## Prerequisites

- [ ] Sign in to Apple ID
- [ ] Install Xcode Command Line Tools: `xcode-select --install`
  - _Skip if on a work Mac with no sudo access_

## Clone & Bootstrap

```bash
# If git is available (Xcode CLT installed):
git clone git@github.com:allenbercero/mac-dotfiles.git ~/Development/mac-dotfiles

# If git is NOT available yet (no Xcode CLT), download the zip from GitHub
```

```bash
cd ~/Development/mac-dotfiles

# Personal Mac (full setup):
bash bootstrap.sh

# Work Mac (with brew/sudo):
bash bootstrap.sh --work

# Work Mac (no sudo):
bash bootstrap.sh --work --no-sudo
```

The script is idempotent — safe to run multiple times. Existing dotfiles are backed up to `~/.dotfiles-backup/`.

## SSH Key Setup

### Personal machine

```bash
ssh-keygen -t ed25519 -C "name@example.com" -f ~/.ssh/personal-key
ssh-add ~/.ssh/personal-key
```

- [ ] Add public key to [GitHub SSH keys](https://github.com/settings/keys) as **Authentication Key**
- [ ] Add the same public key to [GitHub SSH keys](https://github.com/settings/keys) as **Signing Key**
- [ ] Add public key to [GitLab](https://gitlab.com/-/user_settings/ssh_keys)
- [ ] Test authentication: `ssh -T git@github.com`
- [ ] Test signing: `echo "test" | ssh-keygen -Y sign -f ~/.ssh/personal-key.pub -n git` (should produce a signature)

> **Note:** The `.gitconfig` already has `gpgsign = true` and `gpg.format = ssh`, so all commits will be signed automatically using `~/.ssh/personal-key.pub`.

### Work machine

```bash
ssh-keygen -t ed25519 -C "your-work-email@company.com" -f ~/.ssh/work-key
ssh-add ~/.ssh/work-key
```

- [ ] Add public key to your company's GitHub/GitLab as **Authentication Key**
- [ ] Add the same public key as **Signing Key**
- [ ] Edit `~/.gitconfig-work` with your actual work email and signing key path (if you didn't set it during bootstrap)
- [ ] Create `~/Work/` directory for work repos (triggers the gitconfig conditional include)
- [ ] Test authentication: `ssh -T git@github.com`

> **Note:** Signed commits are required for work repos. The `.gitconfig-work` configures `~/.ssh/work-key.pub` as the signing key with `gpgsign = true`. This aligns with [NIST SSDF](https://csrc.nist.gov/Projects/ssdf) (PS.1 — signing commits to protect code integrity), [SLSA](https://slsa.dev/) (Level 3 Source — verified commit history), and SOC 2 audit trail requirements (CC6.1, CC7.4).

## No-Sudo Manual Installs

If you ran `bootstrap.sh --work --no-sudo`, the tools below need to be installed manually. All of these can be installed to `~/.local/bin` without root access.

Make sure `~/.local/bin` is in your PATH (the `local-bin` stow package handles this).

### Easy — prebuilt binaries or installer scripts

```bash
# fzf — fuzzy finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# nvm — Node version manager (installs to ~/.nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# pyenv — Python version manager (installs to ~/.pyenv)
curl https://pyenv.run | bash

# ruff — Python linter/formatter
curl -LsSf https://astral.sh/ruff/install.sh | sh

# go — download tarball and extract to ~/.local
curl -LO https://go.dev/dl/go1.24.1.darwin-arm64.tar.gz
tar -C ~/.local -xzf go1.24.1.darwin-arm64.tar.gz
# Add to PATH: export PATH=$PATH:$HOME/.local/go/bin

# biome — formatter/linter (download binary from GitHub releases)
curl -Lo ~/.local/bin/biome https://github.com/biomejs/biome/releases/latest/download/biome-darwin-arm64
chmod +x ~/.local/bin/biome

# fd — fast file finder
curl -LO https://github.com/sharkdp/fd/releases/latest/download/fd-v10.2.0-aarch64-apple-darwin.tar.gz
tar xzf fd-v10.2.0-aarch64-apple-darwin.tar.gz
cp fd-v10.2.0-aarch64-apple-darwin/fd ~/.local/bin/

# fastfetch — system info display
curl -LO https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-macos-universal.tar.gz
tar xzf fastfetch-macos-universal.tar.gz
cp fastfetch-macos-universal/usr/bin/fastfetch ~/.local/bin/

# colima — container runtime
curl -Lo ~/.local/bin/colima https://github.com/abiosoft/colima/releases/latest/download/colima-Darwin-arm64
chmod +x ~/.local/bin/colima
```

### Moderate — depends on other tools being installed first

```bash
# pyright — Python type checker (requires Node via nvm)
npm install -g pyright

# docker CLI (requires Go)
# Download from https://download.docker.com/mac/static/stable/aarch64/
# Extract and copy `docker` binary to ~/.local/bin/
```

### Harder — may need to build from source

```bash
# tmux — terminal multiplexer
# Option 1: Download prebuilt from https://github.com/tmux/tmux-builds/releases
# Option 2: Build from source (requires libevent + ncurses):
#   git clone https://github.com/tmux/tmux.git
#   cd tmux && sh autogen.sh
#   ./configure --prefix=$HOME/.local && make && make install

# tree — directory listing
# Build from source:
#   curl -LO https://github.com/Old-Man-Programmer/tree/archive/refs/tags/2.2.1.tar.gz
#   tar xzf 2.2.1.tar.gz && cd tree-2.2.1
#   make && cp tree ~/.local/bin/

# stow — GNU Stow (Perl-based, macOS ships with Perl)
# Build from source:
#   curl -LO https://ftp.gnu.org/gnu/stow/stow-2.4.1.tar.gz
#   tar xzf stow-2.4.1.tar.gz && cd stow-2.4.1
#   ./configure --prefix=$HOME/.local && make && make install
```

> **Note:** Version numbers in URLs above will go stale. Check each tool's GitHub releases page for the latest version before downloading.

## Post-Bootstrap

- [ ] Open tmux and press `prefix + I` to install TPM plugins
- [ ] Run `p10k configure` if the prompt needs reconfiguring
- [ ] Install Zed extensions (open Zed → Extensions panel):
  - [ ] Catppuccin Icons (icon theme)
  - [ ] One Dark Pro Max (includes One Dark Pro Glass theme)
  - [ ] Dockerfile (Dockerfile language support)
  - [ ] Git Firefly (git syntax highlighting)
  - [ ] HTML (HTML language support)
- [ ] Install Xcode from the App Store (cannot be automated via brew)
- [ ] Install Python: `pyenv install 3.12 && pyenv global 3.12`
- [ ] Install Node: `nvm install --lts`
- [ ] Install Java: `sdk install java` (if needed)

## macOS System Preferences

These are optional but recommended:

- [ ] **Keyboard**: Key repeat rate → fastest, delay → shortest
- [ ] **Trackpad**: Enable tap to click
- [ ] **Dock**: Auto-hide, reduce size
- [ ] **Finder**: Show file extensions, show path bar, show status bar
- [ ] **Security**: Enable FileVault disk encryption
