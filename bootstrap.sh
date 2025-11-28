#!/bin/bash
# Bootstrap script - run this on a fresh Mac
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/plabrum/.dotfiles/main/bootstrap.sh)

set -euo pipefail

# Color output
reset_color=$(tput sgr 0)
info() { printf "%s[*] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"; }
success() { printf "%s[*] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"; }
err() { printf "%s[*] %s%s\n" "$(tput setaf 1)" "$1" "$reset_color"; }

REPO_URL=https://github.com/plabrum/.dotfiles.git
REPO_PATH="$HOME/.dotfiles"

info "Starting dotfiles bootstrap..."

# Install Xcode Command Line Tools first (needed for git)
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install

    info "Waiting for Xcode Command Line Tools installation..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    success "Xcode Command Line Tools installed"
else
    info "Xcode Command Line Tools already installed"
fi

# Clone the dotfiles repository
if [ -d "$REPO_PATH" ]; then
    info "Dotfiles repo already exists at $REPO_PATH"
    cd "$REPO_PATH"
    git pull
else
    info "Cloning dotfiles repo from $REPO_URL"
    git clone "$REPO_URL" "$REPO_PATH"
    cd "$REPO_PATH"
fi

success "Dotfiles repository ready!"
info "Starting main installation..."
echo ""

# Run the main install script
bash "$REPO_PATH/install.sh"
