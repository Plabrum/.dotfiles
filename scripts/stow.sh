#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")/dotfiles"

# Source utils for colored output
source "$SCRIPT_DIR/utils.sh"

stow_dotfiles() {
    info "Stowing dotfiles from $DOTFILES_DIR to $HOME"

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

    # Stow the dotfiles directory
    # -v 1 = verbose level 1
    # -R = restow (unstow first, then stow - useful for updates)
    # -t = target directory (where symlinks will be created)
    # -d = source directory (where stow packages are located)

    if stow -v 1 -R -t "$HOME" -d "$(dirname "$DOTFILES_DIR")" dotfiles 2>&1; then
        success "Dotfiles stowed successfully!"
    else
        warn "Stow encountered conflicts with existing files"
        info "This likely means you have files that aren't symlinks yet"
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

            # Use --adopt to take existing files into the stow directory temporarily,
            # then restore the repo versions
            stow -v 1 --adopt -t "$HOME" -d "$(dirname "$DOTFILES_DIR")" dotfiles

            # Reset any changes in the dotfiles repo to restore tracked versions
            cd "$(dirname "$DOTFILES_DIR")"
            git restore dotfiles/ 2>/dev/null || warn "Could not restore tracked versions (not a git repo?)"

            success "Dotfiles stowed successfully!"
            info "Original files backed up to: $BACKUP_DIR"
        else
            info "Stow cancelled. Please resolve conflicts manually."
            exit 1
        fi
    fi
}

# Run the function
stow_dotfiles
