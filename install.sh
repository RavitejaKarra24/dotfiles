#!/usr/bin/env bash
#
# install.sh - Bootstrap script for dotfiles
#
# Usage:
#   On a fresh Mac:
#     git clone git@github.com:RavitejaKarra24/dotfiles.git ~/.dotfiles
#     cd ~/.dotfiles && ./install.sh
#
#   To re-run (safe to run multiple times):
#     ~/.dotfiles/install.sh
#

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================================================
# 1. Xcode Command Line Tools
# ============================================================================
install_xcode_cli() {
    if xcode-select -p &>/dev/null; then
        success "Xcode CLI tools already installed"
    else
        info "Installing Xcode CLI tools..."
        xcode-select --install
        echo "Press any key after Xcode CLI tools installation is complete..."
        read -n 1
    fi
}

# ============================================================================
# 2. Homebrew
# ============================================================================
install_homebrew() {
    if command -v brew &>/dev/null; then
        success "Homebrew already installed"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for this session
        eval "$(/opt/homebrew/bin/brew shellenv)"
        success "Homebrew installed"
    fi
}

# ============================================================================
# 3. Brew Bundle (install all packages from Brewfile)
# ============================================================================
install_brew_packages() {
    info "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
    success "Brew packages installed"
}

# ============================================================================
# 4. Oh-My-Zsh
# ============================================================================
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh-My-Zsh already installed"
    else
        info "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh-My-Zsh installed"
    fi
}

# ============================================================================
# 5. Zsh Custom Plugins & Themes
# ============================================================================
install_zsh_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Powerlevel10k theme
    if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        success "Powerlevel10k already installed"
    else
        info "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        success "Powerlevel10k installed"
    fi

    # zsh-autosuggestions
    if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        success "zsh-autosuggestions already installed"
    else
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        success "zsh-autosuggestions installed"
    fi

    # zsh-syntax-highlighting
    if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        success "zsh-syntax-highlighting already installed"
    else
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        success "zsh-syntax-highlighting installed"
    fi
}

# ============================================================================
# 6. Tmux Plugin Manager (TPM)
# ============================================================================
install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        success "TPM already installed"
    else
        info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        success "TPM installed (run prefix + I inside tmux to install plugins)"
    fi
}

# ============================================================================
# 7. Vim-Plug
# ============================================================================
install_vim_plug() {
    if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
        success "vim-plug already installed"
    else
        info "Installing vim-plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        success "vim-plug installed"
    fi
}

# ============================================================================
# 8. Rust (via rustup)
# ============================================================================
install_rust() {
    if command -v rustup &>/dev/null; then
        success "Rust already installed"
    else
        info "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        success "Rust installed"
    fi
}

# ============================================================================
# 9. NVM (Node Version Manager)
# ============================================================================
install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        success "NVM already installed"
    else
        info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        success "NVM installed"
    fi
}

# ============================================================================
# 10. Bun
# ============================================================================
install_bun() {
    if command -v bun &>/dev/null; then
        success "Bun already installed"
    else
        info "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        success "Bun installed"
    fi
}

# ============================================================================
# 11. Backup existing configs & Stow symlinks
# ============================================================================
stow_packages() {
    # List of all stow packages
    local packages=(
        zsh
        bash
        git
        wezterm
        vim
        tmux
        nvim
        ghostty
        karabiner
        yabai
        skhd
        sketchybar
        lazygit
        yazi
        btop
        fish
        atuin
        spotify-player
        calcure
        zed
    )

    info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    for package in "${packages[@]}"; do
        local pkg_dir="$DOTFILES_DIR/$package"
        [ -d "$pkg_dir" ] || continue

        info "Stowing $package..."

        # Try stow, if it fails due to existing files, back them up first
        if ! stow -d "$DOTFILES_DIR" -t "$HOME" --no-folding "$package" 2>/dev/null; then
            warn "Conflict detected for $package, backing up existing files..."

            # Find all files in the stow package and back up their targets
            while IFS= read -r file; do
                # Get the relative path (strip the package dir prefix)
                local rel_path="${file#$pkg_dir/}"
                local target="$HOME/$rel_path"

                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    local backup_path="$BACKUP_DIR/$rel_path"
                    mkdir -p "$(dirname "$backup_path")"
                    mv "$target" "$backup_path"
                    info "  Backed up: ~/$rel_path"
                elif [ -L "$target" ]; then
                    rm "$target"
                fi
            done < <(find "$pkg_dir" -type f)

            # Try stow again after backup
            stow -d "$DOTFILES_DIR" -t "$HOME" --no-folding "$package"
        fi

        success "Stowed $package"
    done
}

# ============================================================================
# 12. Secrets file template
# ============================================================================
setup_secrets() {
    if [ -f "$HOME/.zshrc.secrets" ]; then
        success "Secrets file already exists at ~/.zshrc.secrets"
    else
        warn "No ~/.zshrc.secrets file found!"
        info "Creating template at ~/.zshrc.secrets"
        cat > "$HOME/.zshrc.secrets" << 'SECRETS_EOF'
# API Keys and Secrets - DO NOT COMMIT THIS FILE
# Fill in your API keys below

export NVIDIA_API_KEY=""
export GROQ_API_KEY=""
export ANTHROPIC_API_KEY=""
export OPEN_ROUTER_API_KEY=""
export XAI_API_KEY=""
export GEMINI_API_KEY=""
export OPENAI_API_KEY=""
export KAMAL_REGISTRY_PASSWORD=""
SECRETS_EOF
        warn "Edit ~/.zshrc.secrets and add your API keys"
    fi
}

# ============================================================================
# 13. macOS Defaults (optional)
# ============================================================================
set_macos_defaults() {
    echo ""
    read -p "$(echo -e "${YELLOW}Set recommended macOS defaults? (y/n): ${NC}")" -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Skipping macOS defaults"
        return
    fi

    info "Setting macOS defaults..."

    # Dock
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.4
    defaults write com.apple.dock tilesize -int 48
    defaults write com.apple.dock show-recents -bool false

    # Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Keyboard
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Trackpad
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0

    # Screenshots
    defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture type -string "png"

    # Restart affected applications
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true

    success "macOS defaults set"
}

# ============================================================================
# 14. GitHub repo creation
# ============================================================================
create_github_repo() {
    echo ""
    read -p "$(echo -e "${YELLOW}Create GitHub repo 'dotfiles'? (y/n): ${NC}")" -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Skipping GitHub repo creation"
        return
    fi

    if ! command -v gh &>/dev/null; then
        error "GitHub CLI (gh) not installed. Run: brew install gh"
        return 1
    fi

    if ! gh auth status &>/dev/null; then
        info "Authenticating with GitHub..."
        gh auth login
    fi

    # Check if repo already exists
    if gh repo view "$(gh api user -q .login)/dotfiles" &>/dev/null; then
        success "GitHub repo 'dotfiles' already exists"
    else
        info "Creating GitHub repo..."
        gh repo create dotfiles --public --description "My macOS dotfiles - managed with GNU Stow" --source="$DOTFILES_DIR" --push
        success "GitHub repo created and pushed"
    fi
}

# ============================================================================
# 15. Start services
# ============================================================================
start_services() {
    echo ""
    read -p "$(echo -e "${YELLOW}Start yabai, skhd, and sketchybar services? (y/n): ${NC}")" -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Skipping service startup"
        return
    fi

    info "Starting services..."
    brew services start yabai 2>/dev/null && success "yabai started" || warn "yabai failed to start"
    brew services start skhd 2>/dev/null && success "skhd started" || warn "skhd failed to start"
    brew services start sketchybar 2>/dev/null && success "sketchybar started" || warn "sketchybar failed to start"
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Dotfiles Bootstrap Script${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Core setup
    install_xcode_cli
    install_homebrew
    install_brew_packages

    # Shell setup
    install_oh_my_zsh
    install_zsh_plugins

    # Development tools
    install_tpm
    install_vim_plug
    install_rust
    install_nvm
    install_bun

    # Symlink configs
    stow_packages

    # Secrets
    setup_secrets

    # Optional
    set_macos_defaults
    start_services

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Edit ~/.zshrc.secrets with your API keys"
    echo "  3. In tmux, press prefix + I to install tmux plugins"
    echo "  4. In vim, run :PlugInstall to install vim plugins"
    echo "  5. Open Neovim to let lazy.nvim sync plugins"
    echo ""
}

main "$@"
