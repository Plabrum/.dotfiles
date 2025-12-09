#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utils for colored output
source "$SCRIPT_DIR/utils.sh"

# Available packages - should match stow.sh
AVAILABLE_PACKAGES=(
    "zsh"
    "p10k"
    "nvim"
    "tmux"
    "ghostty"
    "karabiner"
    "bin"
)

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [PACKAGES...]"
    echo ""
    echo "Unstow dotfiles packages from \$HOME using GNU stow"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -a, --all      Unstow all available packages"
    echo ""
    echo "Available packages:"
    for pkg in "${AVAILABLE_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")              # Unstow all packages"
    echo "  $(basename "$0") zsh nvim     # Unstow only zsh and nvim"
    echo "  $(basename "$0") --all        # Unstow all available packages"
}

unstow_package() {
    local package=$1

    if [[ ! -d "$DOTFILES_ROOT/$package" ]]; then
        warn "Package '$package' not found at $DOTFILES_ROOT/$package, skipping"
        return 1
    fi

    info "Unstowing package: $package"
    if stow -v 1 -D -t "$HOME" -d "$DOTFILES_ROOT" "$package" 2>&1; then
        success "✓ $package unstowed successfully"
        return 0
    else
        warn "Failed to unstow $package"
        return 1
    fi
}

unstow_dotfiles() {
    local packages=("$@")

    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        err "Error: stow is not installed. Install it with: brew install stow"
        exit 1
    fi

    # Unstow all packages if none specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        packages=("${AVAILABLE_PACKAGES[@]}")
        info "No packages specified, unstowing all packages"
    fi

    # Unstow each package
    for package in "${packages[@]}"; do
        unstow_package "$package"
    done

    echo ""
    success "Unstow complete!"
}

# Parse arguments
PACKAGES=()
SHOW_HELP=false
UNSTOW_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        -a|--all)
            UNSTOW_ALL=true
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

if $UNSTOW_ALL; then
    unstow_dotfiles "${AVAILABLE_PACKAGES[@]}"
else
    unstow_dotfiles "${PACKAGES[@]}"
fi
