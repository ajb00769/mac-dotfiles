#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# --- Flag parsing ---
WORK=false
NO_SUDO=false

for arg in "$@"; do
    case "$arg" in
        --work)    WORK=true ;;
        --no-sudo) NO_SUDO=true ;;
        *)         echo "Unknown flag: $arg"; echo "Usage: bootstrap.sh [--work] [--no-sudo]"; exit 1 ;;
    esac
done

echo "==> Dotfiles bootstrap"
echo "    Mode: $(if $WORK; then echo 'work'; else echo 'personal'; fi)"
echo "    Sudo: $(if $NO_SUDO; then echo 'no'; else echo 'yes'; fi)"
echo ""

# --- Helper functions ---

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$target")"
        echo "    Backing up $target -> $backup_path"
        mv "$target" "$backup_path"
    fi
}

manual_symlink() {
    local src="$1"
    local dest="$2"
    backup_if_exists "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "    Linked $dest -> $src"
}

# --- Stow packages to install ---

PACKAGES=(zsh bash git vim ideavim tmux ssh local-bin)

if ! $WORK; then
    PACKAGES+=(ghostty zed)
fi

# --- Main install logic ---

if ! $NO_SUDO; then
    # 1. Xcode Command Line Tools
    echo "==> Checking Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        echo "    Installing Xcode CLT (a dialog will appear)..."
        xcode-select --install
        echo "    After installation completes, re-run this script."
        exit 1
    fi
    echo "    Xcode CLT already installed."

    # 2. Homebrew
    echo "==> Checking Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "    Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "    Homebrew ready."

    # 3. Brew bundle
    echo "==> Installing packages from Brewfile..."
    if $WORK; then
        brew bundle --file="$DOTFILES_DIR/Brewfile.work"
    else
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
fi

# 4. Oh My Zsh
echo "==> Checking Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "    Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
echo "    Oh My Zsh ready."

# 5. Powerlevel10k
echo "==> Checking Powerlevel10k..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "    Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
echo "    Powerlevel10k ready."

# 6. TPM (Tmux Plugin Manager)
echo "==> Checking TPM..."
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "    Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
echo "    TPM ready."

# 7. SDKMAN
echo "==> Checking SDKMAN..."
if [ ! -d "$HOME/.sdkman" ]; then
    echo "    Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
fi
echo "    SDKMAN ready."

# 8. Symlink dotfiles
echo "==> Linking dotfiles..."

if ! $NO_SUDO && command -v stow &>/dev/null; then
    # Use GNU Stow
    cd "$DOTFILES_DIR"
    for pkg in "${PACKAGES[@]}"; do
        echo "    Stowing $pkg..."
        # Back up any conflicting files first
        case "$pkg" in
            zsh)       for f in .zshrc .zprofile .p10k.zsh; do backup_if_exists "$HOME/$f"; done ;;
            bash)      backup_if_exists "$HOME/.bash_profile" ;;
            git)       for f in .gitconfig .gitconfig-personal .gitconfig-work; do backup_if_exists "$HOME/$f"; done ;;
            vim)       backup_if_exists "$HOME/.vimrc" ;;
            ideavim)   backup_if_exists "$HOME/.ideavimrc" ;;
            tmux)      backup_if_exists "$HOME/.tmux.conf" ;;
            ssh)       backup_if_exists "$HOME/.ssh/config" ;;
            ghostty)   backup_if_exists "$HOME/.config/ghostty/config" ;;
            zed)       for f in settings.json keymap.json; do backup_if_exists "$HOME/.config/zed/$f"; done ;;
            local-bin) backup_if_exists "$HOME/.local/bin/env" ;;
        esac
        stow -v -R -t "$HOME" "$pkg"
    done
else
    # Manual symlinks (no stow available)
    echo "    Stow not available, using manual symlinks..."

    # zsh
    manual_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    manual_symlink "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
    manual_symlink "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

    # bash
    manual_symlink "$DOTFILES_DIR/bash/.bash_profile" "$HOME/.bash_profile"

    # git
    manual_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    manual_symlink "$DOTFILES_DIR/git/.gitconfig-personal" "$HOME/.gitconfig-personal"
    manual_symlink "$DOTFILES_DIR/git/.gitconfig-work" "$HOME/.gitconfig-work"

    # vim
    manual_symlink "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"

    # ideavim
    manual_symlink "$DOTFILES_DIR/ideavim/.ideavimrc" "$HOME/.ideavimrc"

    # tmux
    manual_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

    # ssh
    mkdir -p "$HOME/.ssh"
    manual_symlink "$DOTFILES_DIR/ssh/.ssh/config" "$HOME/.ssh/config"

    # local-bin
    manual_symlink "$DOTFILES_DIR/local-bin/.local/bin/env" "$HOME/.local/bin/env"

    if ! $WORK; then
        # ghostty
        manual_symlink "$DOTFILES_DIR/ghostty/.config/ghostty/config" "$HOME/.config/ghostty/config"

        # zed
        manual_symlink "$DOTFILES_DIR/zed/.config/zed/settings.json" "$HOME/.config/zed/settings.json"
        manual_symlink "$DOTFILES_DIR/zed/.config/zed/keymap.json" "$HOME/.config/zed/keymap.json"
    fi
fi

# 9. Work machine: prompt for git identity
if $WORK; then
    echo ""
    echo "==> Work machine git identity setup"
    read -rp "    Enter your work email: " work_email
    if [ -n "$work_email" ]; then
        sed -i '' "s/allen@WORKDOMAIN.com/$work_email/" "$HOME/.gitconfig-work"
        echo "    Updated ~/.gitconfig-work with $work_email"
    fi
    echo "    Remember to create ~/Work/ for your work repos (triggers gitconfig conditional include)."
fi

# 10. Print summary
echo ""
echo "==> Bootstrap complete!"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo "    Backed-up files are in: $BACKUP_DIR"
fi

echo ""
echo "    MANUAL STEPS REMAINING:"
echo "    1. Generate SSH key:"
if $WORK; then
    echo "       ssh-keygen -t ed25519 -C \"your-work-email\" -f ~/.ssh/work-key"
else
    echo "       ssh-keygen -t ed25519 -C \"your-email@example.com\" -f ~/.ssh/personal-key"
fi
echo "    2. Add SSH key to GitHub: https://github.com/settings/keys"
echo "    3. Test: ssh -T git@github.com"
echo "    4. Open tmux and press prefix + I to install TPM plugins"

if $NO_SUDO; then
    echo ""
    echo "    TOOLS TO INSTALL MANUALLY (no brew available):"
    echo "    biome, colima, docker, fastfetch, fd, fzf, go, nvm,"
    echo "    pyenv, pyright, ruff, tmux, tree"
    echo "    Install these through your company's software portal or ask IT."
fi

echo ""
echo "    Open a new terminal to apply changes."
