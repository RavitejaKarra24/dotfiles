#!/usr/bin/env bash
#
# Update the system-wide developer tools and global packages on this Mac.
#
# Usage:
#   ./update.sh
#   ./update.sh --dry-run
#   ./update.sh --greedy
#
# This intentionally updates global tools only. Run the appropriate package
# manager inside each project to update that project's lockfile/dependencies.

set -uo pipefail

DRY_RUN=0
GREEDY_CASKS=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SUCCEEDED=()
FAILED=()
SKIPPED=()

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    RESET=''
fi

usage() {
    cat <<'EOF'
Usage: ./update.sh [--dry-run] [--greedy] [--help]

Update detected system-wide package managers, runtimes, global CLI packages,
Mac App Store apps, and editor extensions.

Options:
  -n, --dry-run  Print the update tasks without changing anything
      --greedy   Also update casks that normally auto-update themselves
  -h, --help     Show this help

Project dependencies are deliberately excluded. Update those from each
project directory so its tests and lockfile can be reviewed together.
EOF
}

while (($# > 0)); do
    case "$1" in
    -n | --dry-run)
        DRY_RUN=1
        ;;
    --greedy)
        GREEDY_CASKS=1
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        printf '%sUnknown option:%s %s\n\n' "$RED" "$RESET" "$1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
done

has() {
    command -v "$1" >/dev/null 2>&1
}

section() {
    printf '\n%s%s==> %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
}

print_command() {
    printf '    '
    printf '%q ' "$@"
    printf '\n'
}

run_step() {
    local label="$1"
    shift

    printf '%s[RUN]%s %s\n' "$BLUE" "$RESET" "$label"
    print_command "$@"

    if ((DRY_RUN)); then
        return 0
    fi

    if "$@"; then
        SUCCEEDED+=("$label")
        printf '%s[OK]%s  %s\n' "$GREEN" "$RESET" "$label"
        return 0
    fi

    FAILED+=("$label")
    printf '%s[FAIL]%s %s\n' "$RED" "$RESET" "$label" >&2
    return 0
}

skip_step() {
    local label="$1"
    local reason="$2"

    SKIPPED+=("$label — $reason")
    printf '%s[SKIP]%s %s (%s)\n' "$YELLOW" "$RESET" "$label" "$reason"
}

BREW_PREFIX=''
BREW_PACKAGES=''
BREW_INVENTORY_LOADED=0

load_brew_inventory() {
    ((BREW_INVENTORY_LOADED)) && return 0
    BREW_INVENTORY_LOADED=1
    has brew || return 0

    BREW_PREFIX="$(brew --prefix 2>/dev/null)"
    BREW_PACKAGES=$'\n'"$(
        brew list --formula -1 2>/dev/null
        brew list --cask -1 2>/dev/null
    )"$'\n'
}

# True when `brew upgrade` above already updated this tool, so re-updating it
# here would fight Homebrew. Both halves matter: the package name alone is
# misleading (brew lists its `ruby` even when /usr/bin/ruby wins on PATH), and
# the install prefix alone is misleading (npm links its own global binaries
# into the Homebrew prefix). Usage: brew_manages <command> [formula/cask name]
brew_manages() {
    local command_name="$1"
    local package="${2:-$1}"
    local command_path

    load_brew_inventory
    [[ -n "$BREW_PREFIX" ]] || return 1
    [[ "$BREW_PACKAGES" == *$'\n'"$package"$'\n'* ]] || return 1
    command_path="$(command -v "$command_name" 2>/dev/null)" || return 1
    [[ "$command_path" == "$BREW_PREFIX"/* ]]
}

update_global_npm_packages() {
    local root package path
    local packages=()

    root="$(npm root --global 2>/dev/null)"
    if [[ -z "$root" ]]; then
        skip_step "Global npm packages" "cannot resolve the global prefix"
        return
    fi

    while IFS= read -r path; do
        package="${path#"$root"/}"
        # The listing leads with the prefix itself, which strips to nothing.
        [[ "$package" != "$path" ]] || continue

        # npm and corepack ship inside Homebrew's node formula. Updating them
        # here rewrites files brew owns and is undone by the next node upgrade.
        if [[ "$package" == npm || "$package" == corepack ]] &&
            brew_manages npm node; then
            skip_step "Global npm package: $package" "ships with Homebrew's node"
            continue
        fi

        packages+=("$package")
    done < <(npm ls --global --depth=0 --parseable 2>/dev/null)

    if ((${#packages[@]} == 0)); then
        skip_step "Global npm packages" "none installed"
        return
    fi

    run_step "Update global npm packages (TypeScript, pi, etc.)" \
        npm update --global "${packages[@]}"
}

update_cargo_packages() {
    local line
    local package
    local source_url
    local found=0

    while IFS= read -r line; do
        [[ "$line" == " "* ]] && continue

        if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+v[^[:space:]]+([[:space:]]+\(([^#\)]+)(#[^\)]*)?\))?:$ ]]; then
            found=1
            package="${BASH_REMATCH[1]}"
            source_url="${BASH_REMATCH[3]:-}"

            # AVM has an official updater that preserves its installation
            # details. It separately updates the managed Anchor CLI.
            if [[ "$package" == "avm" ]] && has avm; then
                run_step "Update Cargo package: avm" avm self-update
                run_step "Update Anchor CLI to the latest version" avm update
            elif brew_manages "$package"; then
                skip_step "Cargo package: $package" "shadowed by Homebrew"
            elif [[ -n "$source_url" ]]; then
                run_step "Update Cargo package: $package" \
                    cargo install --git "$source_url" "$package" --locked --force
            else
                run_step "Update Cargo package: $package" \
                    cargo install "$package" --locked
            fi
        fi
    done < <(cargo install --list 2>/dev/null)

    if ((! found)); then
        skip_step "Cargo-installed CLI packages" "none installed"
    fi
}

update_go_binaries() {
    local go_bin
    local binary
    local package
    local seen=''
    local found=0

    go_bin="$(go env GOBIN 2>/dev/null)"
    if [[ -z "$go_bin" ]]; then
        go_bin="$(go env GOPATH 2>/dev/null)/bin"
    fi

    if [[ ! -d "$go_bin" ]]; then
        skip_step "Go-installed CLI packages" "none installed"
        return
    fi

    for binary in "$go_bin"/*; do
        [[ -f "$binary" ]] || continue
        package="$(
            go version -m "$binary" 2>/dev/null |
                awk '$1 == "path" { print $2; exit }'
        )"
        [[ -n "$package" ]] || continue

        case "
$seen
" in
        *"
$package
"*)
            continue
            ;;
        esac

        seen="${seen}${package}"$'\n'
        found=1

        if brew_manages "$(basename "$binary")"; then
            skip_step "Go package: $package" "shadowed by Homebrew"
            continue
        fi

        run_step "Update Go package: $package" go install "${package}@latest"
    done

    if ((! found)); then
        skip_step "Go-installed CLI packages" "none installed"
    fi
}

update_user_gems() {
    local user_gem_home

    user_gem_home="$(gem environment user_gemhome 2>/dev/null)"
    if [[ -z "$user_gem_home" || ! -d "$user_gem_home/specifications" ]]; then
        skip_step "User-installed Ruby gems" "none installed"
        return
    fi

    if ! compgen -G "$user_gem_home/specifications/*.gemspec" >/dev/null; then
        skip_step "User-installed Ruby gems" "none installed"
        return
    fi

    run_step "Update user-installed Ruby gems" \
        gem update --user-install --no-document
}

show_versions() {
    local version

    section "Installed runtime versions"

    if has brew; then
        brew --version | sed -n '1p'
    fi
    if has node; then
        printf 'Node %s\n' "$(node --version)"
    fi
    if has npm; then
        printf 'npm %s\n' "$(npm --version)"
    fi
    if has bun; then
        printf 'Bun %s\n' "$(bun --version)"
    fi
    if has deno; then
        deno --version | sed -n '1p'
    fi
    if has rustc; then
        rustc --version
    fi
    if has go; then
        go version
    fi
    if has python3; then
        python3 --version
    fi
    if has ruby; then
        version="$(ruby --version)"
        printf '%s\n' "$version"
    fi
}

printf '%sDeveloper environment updater%s\n' "$BOLD" "$RESET"
if ((DRY_RUN)); then
    printf '%sDry run: no packages will be changed.%s\n' "$YELLOW" "$RESET"
else
    DOTFILES_UPDATE_LOG_DIR="$HOME/Library/Logs/dotfiles"
    mkdir -p "$DOTFILES_UPDATE_LOG_DIR"
    DOTFILES_UPDATE_LOG="$DOTFILES_UPDATE_LOG_DIR/update-$(date +%Y%m%d-%H%M%S).log"
    exec > >(tee -a "$DOTFILES_UPDATE_LOG") 2>&1
    # Close the pipe and let tee drain, otherwise exiting can truncate the log.
    trap 'exec 1>&- 2>&-; wait' EXIT
    printf 'Log: %s\n' "$DOTFILES_UPDATE_LOG"
    section "Pre-update version snapshot"
    show_versions
fi

section "Homebrew packages and applications"
if has brew; then
    run_step "Refresh Homebrew metadata" brew update
    run_step "Upgrade Homebrew formulae" brew upgrade --formula --yes
    if ((GREEDY_CASKS)); then
        run_step "Upgrade Homebrew casks (including auto-updating apps)" \
            brew upgrade --cask --greedy --yes
    else
        run_step "Upgrade Homebrew casks" brew upgrade --cask --yes
    fi
else
    skip_step "Homebrew formulae and casks" "brew not installed"
fi

section "JavaScript and TypeScript"
if has npm; then
    update_global_npm_packages
else
    skip_step "Global npm packages" "npm not installed"
fi

if has bun; then
    if brew_manages bun; then
        skip_step "Bun runtime" "managed by Homebrew"
    else
        run_step "Update Bun runtime" bun upgrade
    fi
    run_step "Update global Bun packages (next-auth, Vite, etc.)" \
        bun update --global --latest
else
    skip_step "Bun runtime and global packages" "bun not installed"
fi

if has deno; then
    if brew_manages deno; then
        skip_step "Deno runtime" "managed by Homebrew"
    else
        run_step "Update Deno runtime" deno upgrade
    fi
fi

section "Rust"
if has rustup; then
    run_step "Update rustup and installed Rust toolchains" rustup update
else
    skip_step "Rust toolchains" "rustup not installed"
fi

if has cargo; then
    update_cargo_packages
else
    skip_step "Cargo-installed CLI packages" "cargo not installed"
fi

if has agave-install; then
    run_step "Update Solana/Agave CLI" agave-install update
elif has solana-install; then
    run_step "Update Solana CLI" solana-install update
fi

section "Go"
if has go; then
    if brew_manages go; then
        skip_step "Go runtime" "managed by Homebrew"
    fi
    update_go_binaries
else
    skip_step "Go runtime and CLI packages" "go not installed"
fi

section "Python CLI tools"
if has uv; then
    if brew_manages uv; then
        skip_step "uv runtime" "managed by Homebrew"
    else
        run_step "Update uv" uv self update
    fi
    run_step "Update uv-managed tools" uv tool upgrade --all
else
    skip_step "uv-managed tools" "uv not installed"
fi

if has pipx; then
    run_step "Update pipx-managed tools (calcure, etc.)" pipx upgrade-all
else
    skip_step "pipx-managed tools" "pipx not installed"
fi

section "Ruby"
if has gem; then
    if brew_manages gem ruby; then
        skip_step "Ruby runtime and default gems" "managed by Homebrew"
    fi
    update_user_gems
else
    skip_step "User-installed Ruby gems" "gem not installed"
fi

section "Applications and editor extensions"
if has mas; then
    run_step "Update Mac App Store applications" mas upgrade
else
    skip_step "Mac App Store applications" "mas not installed"
fi

if has code; then
    run_step "Update Visual Studio Code extensions" code --update-extensions
else
    skip_step "Visual Studio Code extensions" "code CLI not installed"
fi

if has cursor; then
    run_step "Update Cursor extensions" cursor --update-extensions
else
    skip_step "Cursor extensions" "cursor CLI not installed"
fi

if ((DRY_RUN)); then
    printf '\n%sDry run complete.%s Run %s./update.sh%s to apply these updates.\n' \
        "$GREEN" "$RESET" "$BOLD" "$RESET"
    exit 0
fi

show_versions

if [[ -x "$SCRIPT_DIR/doctor.sh" ]]; then
    section "Post-update health check"
    run_step "Run the quick dotfiles doctor" "$SCRIPT_DIR/doctor.sh" --quick
fi

section "Summary"
printf '%sSucceeded:%s %d\n' "$GREEN" "$RESET" "${#SUCCEEDED[@]}"
printf '%sSkipped:%s   %d\n' "$YELLOW" "$RESET" "${#SKIPPED[@]}"
printf '%sFailed:%s    %d\n' "$RED" "$RESET" "${#FAILED[@]}"

if ((${#FAILED[@]} > 0)); then
    printf '\n%sThe following update tasks failed:%s\n' "$RED" "$RESET" >&2
    for item in "${FAILED[@]}"; do
        printf '  - %s\n' "$item" >&2
    done
    printf '\nRe-run the script after fixing the errors above.\n' >&2
    exit 1
fi

printf '\n%sAll detected global package updates completed successfully.%s\n' \
    "$GREEN" "$RESET"
