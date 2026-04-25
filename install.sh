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

# Profile selection: minimal is a CLI-only dev environment, full adds GUI apps
# (macOS only). Override non-interactively with INSTALL_PROFILE=minimal|full.
INSTALL_PROFILE="${INSTALL_PROFILE:-}"
if [ -z "$INSTALL_PROFILE" ]; then
    read -r -p "Install profile [minimal/full] (default: minimal): " profile_input
    INSTALL_PROFILE="${profile_input:-minimal}"
fi
case "$INSTALL_PROFILE" in
    minimal|full) ;;
    *)
        err "Unknown install profile '$INSTALL_PROFILE' (expected minimal or full)"
        exit 1
        ;;
esac
info "Profile: $INSTALL_PROFILE"
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
    # 1. Build prerequisites
    if is_macos; then
        run_installer "Xcode Command Line Tools" install_xcode_tools
    else
        run_installer "Build Prerequisites" install_build_prerequisites
    fi

    # 2. Homebrew (works on both platforms)
    run_installer "Homebrew" install_homebrew

    # 3. Minimal CLI packages (always installed)
    run_installer "Homebrew Packages" install_brew_packages "${brew_packages_minimal[@]}"

    # 4. Full-profile extras (macOS GUI bundle)
    if [ "$INSTALL_PROFILE" = "full" ]; then
        if is_macos; then
            run_installer "macOS Homebrew Packages" install_brew_packages "${brew_packages_macos_full[@]}"
            run_installer "Homebrew Applications" install_brew_casks "${brew_apps_full[@]}"
            run_installer "Mac App Store Apps" install_masApps "${mas_apps_full[@]}"
        else
            info "GUI extras skipped (macOS only)"
        fi
    fi

    # 5. Oh My Zsh + p10k + plugins
    run_installer "Oh My Zsh" install_oh_my_zsh

    # 6. Stow dotfiles
    if [ "$SCRIPT_DIR" = "$REPO_PATH" ]; then
        if [ "$INSTALL_PROFILE" = "full" ] && is_macos; then
            run_installer "Dotfiles (Stow)" bash "$SCRIPT_DIR/scripts/stow.sh" --all
        else
            run_installer "Dotfiles (Stow)" bash "$SCRIPT_DIR/scripts/stow.sh"
        fi
    else
        warn "Skipping stow - run from $REPO_PATH after cloning"
    fi

    # 7. macOS-only GUI extras: Neovim.app + file associations
    if [ "$INSTALL_PROFILE" = "full" ] && is_macos; then
        run_installer "Neovim.app" bash "$SCRIPT_DIR/scripts/create-neovim-app.sh"
        run_installer "File Associations" bash "$SCRIPT_DIR/scripts/reset-xcode-file-associations.sh"
    fi

    # 8. GitHub SSH setup (cross-platform)
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
