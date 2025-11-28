#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities and package lists
source "$SCRIPT_DIR/scripts/utils.sh"
source "$SCRIPT_DIR/scripts/terminal.sh"
source "$SCRIPT_DIR/scripts/packages.sh"

REPO_PATH="$HOME/.dotfiles"

print_section_header "macOS Development Environment Setup"

# Install Xcode Command Line Tools
install_xcode_tools() {
    if xcode-select -p &>/dev/null; then
        warn "Xcode Command Line Tools already installed"
    else
        info "Installing Xcode Command Line Tools..."
        xcode-select --install

        # Wait for installation to complete
        info "Waiting for Xcode Command Line Tools installation..."
        until xcode-select -p &>/dev/null; do
            sleep 5
        done

        # Accept license
        sudo xcodebuild -license accept 2>/dev/null || true
        success "Xcode Command Line Tools installed"
    fi
}

# Setup GitHub authentication with gh CLI
setup_github() {
    if ! command -v gh &>/dev/null; then
        warn "GitHub CLI (gh) not installed, skipping authentication"
        return 0
    fi

    # Check if already authenticated
    if gh auth status &>/dev/null; then
        success "Already authenticated with GitHub"
        return 0
    fi

    info "Setting up GitHub authentication..."
    info "This will open your browser to authenticate with GitHub"

    # gh auth login is interactive and handles everything:
    # - SSH key generation
    # - Adding key to GitHub
    # - Git credential setup
    gh auth login

    if gh auth status &>/dev/null; then
        success "GitHub authentication successful!"
    else
        warn "GitHub authentication may have failed - check manually with: gh auth status"
    fi
}

# Main installation flow
main() {
    # 1. Install Xcode tools
    run_installer "Xcode Command Line Tools" install_xcode_tools

    # 2. Install Homebrew
    run_installer "Homebrew" install_homebrew

    # 3. Install packages
    run_installer "Homebrew Packages" install_brew_packages "${brew_packages[@]}"
    run_installer "Homebrew Applications" install_brew_casks "${brew_apps[@]}"
    run_installer "Mac App Store Apps" install_masApps "${mas_apps[@]}"

    # 4. Install Oh My Zsh
    run_installer "Oh My Zsh" install_oh_my_zsh

    # 5. Stow dotfiles
    if [ "$SCRIPT_DIR" = "$REPO_PATH" ]; then
        run_installer "Dotfiles (Stow)" bash "$SCRIPT_DIR/scripts/stow.sh"
    else
        warn "Skipping stow - run from $REPO_PATH after cloning"
    fi

    # 6. Create Neovim app
    run_installer "Neovim.app" bash "$SCRIPT_DIR/scripts/create-neovim-app.sh"

    # 7. Set file associations
    run_installer "File Associations" bash "$SCRIPT_DIR/scripts/reset-xcode-file-associations.sh"

    # 8. GitHub SSH setup
    run_installer "GitHub SSH" setup_github

    print_section_header "Installation Complete!"
    success "Your development environment is ready!"
    info "You may need to:"
    info "  1. Restart your terminal"
    info "  2. Log out and back in for some settings to take effect"
    info "  3. Verify GitHub auth: gh auth status"
}

# Run main installation
main
