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

set -Eeuo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=0
NON_INTERACTIVE=0

for arg in "$@"; do
    case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --non-interactive) NON_INTERACTIVE=1 ;;
    -h | --help)
        echo "Usage: $0 [--dry-run] [--non-interactive]"
        exit 0
        ;;
    *)
        echo "Unknown argument: $arg" >&2
        exit 2
        ;;
    esac
done

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
trap 'error "Failed at line $LINENO: $BASH_COMMAND"' ERR

PACKAGES=(
    zsh bash git wezterm vim tmux nvim ghostty karabiner aerospace
    sketchybar lazygit yazi btop fish atuin spotify-player calcure
    zed agents codex pi
)
STOW_ARGS=(
    --no-folding
    '--ignore=(^|/)\.DS_Store$'
    '--ignore=(^|/)node_modules($|/)'
    '--ignore=(^|/)\.env$'
    '--ignore=(^|/)(auth|trust|models-store)\.json$'
    '--ignore=.*\.(log|tmp|bak|swp|swo)$'
)

preflight() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        error "This bootstrap currently supports macOS only."
        return 1
    fi
    [[ -f "$DOTFILES_DIR/Brewfile" ]] || {
        error "Brewfile not found under $DOTFILES_DIR"
        return 1
    }
    ((DRY_RUN == 1)) || [[ -w "$HOME" ]] || {
        error "Home directory is not writable: $HOME"
        return 1
    }
    success "Preflight passed ($(uname -m), repository: $DOTFILES_DIR)"
}

show_dry_run() {
    info "Dry run: no system or home-directory changes will be made"
    if command -v brew >/dev/null 2>&1; then
        if brew bundle check --file="$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
            success "Brewfile is already satisfied"
        else
            warn "Brewfile has missing/outdated packages, or Homebrew could not access its cache"
        fi
    else
        warn "Homebrew is not installed"
    fi

    if ! command -v stow >/dev/null 2>&1; then
        warn "GNU Stow is not installed; cannot simulate links"
        return
    fi

    local target output planned
    target="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-stow.XXXXXX")"
    output="$(mktemp "${TMPDIR:-/tmp}/dotfiles-stow-output.XXXXXX")"
    local package
    for package in "${PACKAGES[@]}"; do
        [[ -d "$DOTFILES_DIR/$package" ]] || continue
        stow --simulate --verbose -d "$DOTFILES_DIR" -t "$target" "${STOW_ARGS[@]}" "$package" >>"$output" 2>&1
    done
    planned="$(rg -c '^(LINK|MKDIR):' "$output" 2>/dev/null || echo 0)"
    success "Stow simulation is conflict-free ($planned planned links/directories)"
    rm -rf -- "$target"
    rm -f -- "$output"
}

# ============================================================================
# 1. Xcode Command Line Tools
# ============================================================================
install_xcode_cli() {
    if xcode-select -p &>/dev/null; then
        success "Xcode CLI tools already installed"
    else
        info "Installing Xcode CLI tools..."
        xcode-select --install
        warn "Finish the Xcode Command Line Tools installer, then rerun this script."
        return 1
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
        local brew_bin
        for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            [[ -x "$brew_bin" ]] || continue
            eval "$("$brew_bin" shellenv)"
            break
        done
        command -v brew >/dev/null 2>&1 || {
            error "Homebrew installed but could not be found in a standard prefix"
            return 1
        }
        success "Homebrew installed"
    fi
}

# ============================================================================
# 3. Brew Bundle (install all packages from Brewfile)
# ============================================================================
install_brew_packages() {
    info "Installing packages from Brewfile..."
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
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
        # shellcheck source=/dev/null
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
list_stow_files() {
    local package_dir="$1"
    find "$package_dir" \
        \( -name .git -o -name node_modules \
        -o -path '*/.pi/agent/sessions' \
        -o -path '*/.pi/agent/workflows' \
        -o -path '*/.pi/agent/bin' \) -prune \
        -o -type f \
        ! -name .DS_Store \
        ! -name .env \
        ! -name auth.json \
        ! -name trust.json \
        ! -name models-store.json \
        ! -name '*.log' \
        ! -name '*.tmp' \
        ! -name '*.bak' \
        ! -name '*.swp' \
        ! -name '*.swo' \
        -print
}

stow_packages() {
    local manifest="$BACKUP_DIR/manifest.tsv"
    local backup_created=0
    local package
    for package in "${PACKAGES[@]}"; do
        local pkg_dir="$DOTFILES_DIR/$package"
        [ -d "$pkg_dir" ] || continue

        info "Stowing $package..."

        # Try stow, if it fails due to existing files, back them up first
        if ! stow -d "$DOTFILES_DIR" -t "$HOME" "${STOW_ARGS[@]}" "$package" 2>/dev/null; then
            warn "Conflict detected for $package; checking every target before changing anything..."

            # Refuse to replace any symlink not already pointing at this source.
            while IFS= read -r file; do
                local rel_path="${file#"$pkg_dir"/}"
                local target="$HOME/$rel_path"
                if [ -L "$target" ]; then
                    local target_real source_real
                    target_real="$(realpath "$target" 2>/dev/null || true)"
                    source_real="$(realpath "$file" 2>/dev/null || true)"
                    if [[ -z "$target_real" || "$target_real" != "$source_real" ]]; then
                        error "Refusing to replace unrelated symlink: $target"
                        error "It points to: $(readlink "$target")"
                        return 1
                    fi
                fi
            done < <(list_stow_files "$pkg_dir")

            # Back up only real conflicting files/directories. Correct links stay.
            while IFS= read -r file; do
                local rel_path="${file#"$pkg_dir"/}"
                local target="$HOME/$rel_path"
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    local backup_path="$BACKUP_DIR/$rel_path"
                    if ((backup_created == 0)); then
                        mkdir -p "$BACKUP_DIR"
                        printf 'target\tbackup\ttype\tsha256\n' >"$manifest"
                        backup_created=1
                    fi
                    mkdir -p "$(dirname "$backup_path")"
                    mv "$target" "$backup_path"
                    local checksum="-"
                    [[ -f "$backup_path" ]] && checksum="$(shasum -a 256 "$backup_path" | awk '{print $1}')"
                    printf '%s\t%s\t%s\t%s\n' "$target" "$backup_path" "$(stat -f %HT "$backup_path")" "$checksum" >>"$manifest"
                    info "  Backed up: ~/$rel_path"
                fi
            done < <(list_stow_files "$pkg_dir")

            # Try stow again after backup
            stow -d "$DOTFILES_DIR" -t "$HOME" "${STOW_ARGS[@]}" "$package"
        fi

        success "Stowed $package"
    done
}

# ============================================================================
# 12. pi coding agent (global CLI + agent deps)
# ============================================================================
install_pi() {
    if command -v pi &>/dev/null; then
        success "pi already installed ($(pi --version 2>/dev/null || echo present))"
        return
    fi

    if ! command -v npm &>/dev/null; then
        warn "npm not found; skip pi install (install node first)"
        return
    fi

    info "Installing @earendil-works/pi-coding-agent globally..."
    npm install -g @earendil-works/pi-coding-agent
    success "pi installed"
}

# Link shared ~/.agents/skills into ~/.pi/agent/skills (pi-local skills take priority)
link_pi_shared_skills() {
    local agents_skills="$HOME/.agents/skills"
    local pi_skills="$HOME/.pi/agent/skills"

    if [ ! -d "$agents_skills" ]; then
        warn "No ~/.agents/skills (stow agents package first); skip pi skill links"
        return
    fi

    mkdir -p "$pi_skills"

    local linked=0
    local skipped=0
    local name target dest

    for target in "$agents_skills"/*; do
        [ -e "$target" ] || continue
        name="$(basename "$target")"
        dest="$pi_skills/$name"

        # Keep pi-local / stowed skills (real dirs or already-correct links)
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            if [ -L "$dest" ]; then
                # Refresh symlink if it points elsewhere
                local current
                current="$(readlink "$dest" 2>/dev/null || true)"
                if [ "$current" = "../../../.agents/skills/$name" ] || [ "$current" = "$target" ]; then
                    skipped=$((skipped + 1))
                    continue
                fi
                rm -f "$dest"
            else
                # Real directory (pi package skill) — do not replace
                skipped=$((skipped + 1))
                continue
            fi
        fi

        ln -s "../../../.agents/skills/$name" "$dest"
        linked=$((linked + 1))
    done

    success "pi shared skills: linked=$linked kept/skipped=$skipped"
}

# Install only reviewed, explicitly enabled skill packages.
install_pi_skill_deps() {
    local pi_skills="$HOME/.pi/agent/skills"
    [ -d "$pi_skills" ] || return

    if ! command -v npm &>/dev/null; then
        warn "npm not found; skip pi skill package installs"
        return
    fi

    local approved=(
        "pi-skills/brave-search"
        "pi-skills/browser-tools"
        "pi-skills/youtube-transcript"
    )
    local relative dir
    for relative in "${approved[@]}"; do
        dir="$pi_skills/$relative"
        [[ -f "$dir/package.json" ]] || continue
        if [ -d "$dir/node_modules" ]; then
            continue
        fi
        if [[ ! -f "$dir/package-lock.json" ]]; then
            warn "Skipping unlocked skill dependency: $relative"
            continue
        fi
        info "Installing locked dependencies for $relative..."
        (cd "$dir" && npm ci --ignore-scripts --no-fund --no-audit)
    done
}

setup_pi_agent() {
    local agent_dir="$HOME/.pi/agent"

    if [ ! -f "$agent_dir/package.json" ]; then
        warn "pi agent config missing at ~/.pi/agent (stow pi package first)"
        return
    fi

    if ! command -v npm &>/dev/null; then
        warn "npm not found; skip pi agent npm install"
        return
    fi

    # Extensions resolve modules from the real stow path (package.json target),
    # not ~/.pi/agent — so install node_modules next to the real package.json.
    local install_dir
    install_dir="$(cd "$(dirname "$(realpath "$agent_dir/package.json")")" && pwd)"

    info "Installing locked pi agent dependencies (extensions) in $install_dir ..."
    (cd "$install_dir" && npm ci --no-fund --no-audit)
    success "pi agent dependencies installed"

    link_pi_shared_skills
    install_pi_skill_deps

    if [ ! -f "$agent_dir/.env" ] && [ -f "$agent_dir/.env.example" ]; then
        cp "$agent_dir/.env.example" "$agent_dir/.env"
        warn "Created ~/.pi/agent/.env — set FIRECRAWL_API_KEY if you use firecrawl tools"
    fi
}

# ============================================================================
# 13. Secrets file template
# ============================================================================
setup_secrets() {
    umask 077
    if [ -f "$HOME/.zshrc.secrets" ]; then
        chmod 600 "$HOME/.zshrc.secrets"
        success "Secrets file already exists at ~/.zshrc.secrets"
    else
        warn "No ~/.zshrc.secrets file found!"
        info "Creating template at ~/.zshrc.secrets"
        cat >"$HOME/.zshrc.secrets" <<'SECRETS_EOF'
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
# Optional: also used by some tools; pi firecrawl uses ~/.pi/agent/.env
export FIRECRAWL_API_KEY=""
SECRETS_EOF
        chmod 600 "$HOME/.zshrc.secrets"
        warn "Edit ~/.zshrc.secrets and add your API keys"
    fi
}

# ============================================================================
# 14. macOS Defaults (optional)
# ============================================================================
set_macos_defaults() {
    if ((NON_INTERACTIVE == 1)); then
        info "Skipping opt-in macOS defaults in non-interactive mode"
        return
    fi
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
# Main
# ============================================================================
main() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Dotfiles Bootstrap Script${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    preflight
    if ((DRY_RUN == 1)); then
        show_dry_run
        success "Dry run complete"
        return
    fi

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
    install_pi

    # Symlink configs
    stow_packages

    # pi agent deps after stow (package.json lives under ~/.pi/agent)
    setup_pi_agent

    # Secrets
    setup_secrets

    # Optional
    set_macos_defaults
    info "AeroSpace owns SketchyBar startup; no duplicate Brew service is started"

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Edit ~/.zshrc.secrets with your API keys"
    echo "  3. Optional: set FIRECRAWL_API_KEY in ~/.pi/agent/.env for pi firecrawl tools"
    echo "  4. In tmux, press prefix + I to install tmux plugins"
    echo "  5. In vim, run :PlugInstall to install vim plugins"
    echo "  6. Open Neovim to let lazy.nvim sync plugins"
    echo ""
}

main "$@"
