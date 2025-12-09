#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utils for colored output
source "$SCRIPT_DIR/utils.sh"

# Available packages - modify this list to add/remove packages
AVAILABLE_PACKAGES=(
    "zsh"
    "p10k"
    "nvim"
    "tmux"
    "ghostty"
    "karabiner"
    "bin"
)

# Default packages to stow if no arguments provided
DEFAULT_PACKAGES=(
    "zsh"
    "nvim"
    "tmux"
    "bin"
)

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [PACKAGES...]"
    echo ""
    echo "Stow dotfiles packages to \$HOME using GNU stow"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List available packages"
    echo "  -a, --all      Stow all available packages"
    echo ""
    echo "Available packages:"
    for pkg in "${AVAILABLE_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")              # Stow default packages: ${DEFAULT_PACKAGES[*]}"
    echo "  $(basename "$0") zsh nvim     # Stow only zsh and nvim"
    echo "  $(basename "$0") --all        # Stow all available packages"
}

list_packages() {
    info "Available packages:"
    for pkg in "${AVAILABLE_PACKAGES[@]}"; do
        if [[ -d "$DOTFILES_ROOT/$pkg" ]]; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (directory not found)"
        fi
    done
}

stow_package() {
    local package=$1
    local force_adopt=${2:-false}

    if [[ ! -d "$DOTFILES_ROOT/$package" ]]; then
        warn "Package '$package' not found at $DOTFILES_ROOT/$package, skipping"
        return 1
    fi

    info "Stowing package: $package"

    if $force_adopt; then
        stow -v 1 --adopt -t "$HOME" -d "$DOTFILES_ROOT" "$package"
    else
        if stow -v 1 -R -t "$HOME" -d "$DOTFILES_ROOT" "$package" 2>&1; then
            success "✓ $package stowed successfully"
            return 0
        else
            return 1
        fi
    fi
}

stow_dotfiles() {
    local packages=("$@")

    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        err "Error: stow is not installed. Install it with: brew install stow"
        exit 1
    fi

    # Use default packages if none specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        packages=("${DEFAULT_PACKAGES[@]}")
        info "No packages specified, using defaults: ${packages[*]}"
    fi

    local failed_packages=()

    # Try to stow each package
    for package in "${packages[@]}"; do
        if ! stow_package "$package" false; then
            failed_packages+=("$package")
        fi
    done

    # Handle conflicts if any packages failed
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo ""
        warn "Stow encountered conflicts with the following packages:"
        for pkg in "${failed_packages[@]}"; do
            echo "  - $pkg"
        done
        echo ""
        info "This likely means you have existing files that aren't symlinks yet"
        info ""
        info "Options:"
        info "  1. Backup and force stow (recommended for first-time setup)"
        info "  2. Cancel and handle conflicts manually"
        echo ""
        read -r -p "Backup existing files and force stow? (y/n): " response

        if [[ "$response" == "y" ]]; then
            BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            info "Backing up conflicting files to $BACKUP_DIR"

            # Adopt and restore for each failed package
            for package in "${failed_packages[@]}"; do
                info "Adopting conflicts for: $package"
                stow_package "$package" true
            done

            # Reset any changes in the repo to restore tracked versions
            cd "$DOTFILES_ROOT"
            for package in "${failed_packages[@]}"; do
                git restore "$package/" 2>/dev/null || warn "Could not restore tracked versions for $package"
            done

            success "All packages stowed successfully!"
            info "Original files were adopted and tracked versions restored"
        else
            info "Stow cancelled. Please resolve conflicts manually."
            exit 1
        fi
    else
        echo ""
        success "All packages stowed successfully!"
    fi
}

# Parse arguments
PACKAGES=()
SHOW_HELP=false
LIST_PACKAGES=false
STOW_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        -l|--list)
            LIST_PACKAGES=true
            shift
            ;;
        -a|--all)
            STOW_ALL=true
            shift
            ;;
        *)
            PACKAGES+=("$1")
            shift
            ;;
    esac
done

# Execute based on flags
if $SHOW_HELP; then
    show_help
    exit 0
fi

if $LIST_PACKAGES; then
    list_packages
    exit 0
fi

if $STOW_ALL; then
    stow_dotfiles "${AVAILABLE_PACKAGES[@]}"
else
    stow_dotfiles "${PACKAGES[@]}"
fi
