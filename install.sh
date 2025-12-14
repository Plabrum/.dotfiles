#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities and package lists
source "$SCRIPT_DIR/scripts/utils.sh"
source "$SCRIPT_DIR/scripts/terminal.sh"
source "$SCRIPT_DIR/scripts/packages.sh"

REPO_PATH="$HOME/.dotfiles"

print_section_header "Development Environment Setup ($(uname -s))"

# Ask about GUI applications
read -r -p "Install GUI applications? (Recommended for desktop, skip for servers) (y/n): " install_gui_response
if [[ "$install_gui_response" == "y" ]]; then
    INSTALL_GUI_APPS=true
    info "Will install GUI applications"
else
    INSTALL_GUI_APPS=false
    info "Skipping GUI applications (headless/server mode)"
fi
echo ""

# Install Xcode Command Line Tools
install_xcode_tools() {
    if ! is_macos; then
        info "Skipping Xcode Command Line Tools (macOS only)"
        return 0
    fi

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

# Install Linux build prerequisites
install_build_prerequisites() {
    if is_linux; then
        source "$SCRIPT_DIR/scripts/linux-prerequisites.sh"
        install_linux_build_tools
    else
        info "Skipping Linux build prerequisites (macOS system)"
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
    # 1. Install build prerequisites
    if is_macos; then
        run_installer "Xcode Command Line Tools" install_xcode_tools
    else
        run_installer "Build Prerequisites" install_build_prerequisites
    fi

    # 2. Install Homebrew (works on both platforms)
    run_installer "Homebrew" install_homebrew

    # 3. Install packages
    run_installer "Homebrew Packages" install_brew_packages "${brew_packages[@]}"

    # GUI applications (macOS only: Casks and Mac App Store apps)
    if [ "$INSTALL_GUI_APPS" = true ] && is_macos; then
        run_installer "Homebrew Applications" install_brew_casks "${brew_apps[@]}"
        run_installer "Mac App Store Apps" install_masApps "${mas_apps[@]}"
    elif is_macos; then
        info "Skipping GUI applications (headless/server mode)"
    else
        info "Skipping Homebrew Casks and Mac App Store (macOS only)"
    fi

    # 4. Install Oh My Zsh
    run_installer "Oh My Zsh" install_oh_my_zsh

    # 5. Stow dotfiles
    if [ "$SCRIPT_DIR" = "$REPO_PATH" ]; then
        run_installer "Dotfiles (Stow)" bash "$SCRIPT_DIR/scripts/stow.sh"
    else
        warn "Skipping stow - run from $REPO_PATH after cloning"
    fi

    # macOS-only: Create Neovim app and set file associations
    if [ "$INSTALL_GUI_APPS" = true ] && is_macos; then
        run_installer "Neovim.app" bash "$SCRIPT_DIR/scripts/create-neovim-app.sh"
        run_installer "File Associations" bash "$SCRIPT_DIR/scripts/reset-xcode-file-associations.sh"
    elif is_macos; then
        info "Skipping Neovim.app and file associations (headless/server mode)"
    else
        info "Skipping Neovim.app and file associations (macOS only)"
    fi

    # 6. GitHub SSH setup (cross-platform)
    run_installer "GitHub SSH" setup_github

    print_section_header "Installation Complete!"
    success "Your development environment is ready!"
    info "You may need to:"
    info "  1. Restart your terminal"
    info "  2. Log out and back in for some settings to take effect"
    info "  3. Verify GitHub auth: gh auth status"
    if is_linux; then
        info "  4. Add Homebrew to PATH: eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
    fi
}

# Run main installation
main
