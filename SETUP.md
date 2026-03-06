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

If you ran `bootstrap.sh --work --no-sudo`, the following CLI tools need to be installed manually through your company's software portal or IT:

- **biome** — formatter/linter
- **colima** — container runtime
- **docker** — container CLI
- **fastfetch** — system info display
- **fd** — fast file finder
- **fzf** — fuzzy finder
- **go** — Go programming language
- **nvm** — Node version manager
- **pyenv** — Python version manager
- **pyright** — Python type checker
- **ruff** — Python linter/formatter
- **tmux** — terminal multiplexer
- **tree** — directory listing

## Post-Bootstrap

- [ ] Open tmux and press `prefix + I` to install TPM plugins
- [ ] Run `p10k configure` if the prompt needs reconfiguring
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
