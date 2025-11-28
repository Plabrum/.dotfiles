#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")/dotfiles"

# Source utils for colored output
source "$SCRIPT_DIR/utils.sh"

unstow_dotfiles() {
    info "Unstowing dotfiles from $HOME"

    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        err "Error: dotfiles directory not found at $DOTFILES_DIR"
        exit 1
    fi

    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        err "Error: stow is not installed. Install it with: brew install stow"
        exit 1
    fi

    # Unstow the dotfiles directory
    # -v 1 = verbose level 1
    # -D = delete/unstow
    # -t = target directory (where symlinks are)
    # -d = source directory (where stow packages are located)
    stow -v 1 -D -t "$HOME" -d "$(dirname "$DOTFILES_DIR")" dotfiles

    success "Dotfiles unstowed successfully!"
}

# Run the function
unstow_dotfiles
