#!/bin/bash
set -o errexit

# Color Printing
reset_color=$(tput sgr 0)

info() {
  printf "%s[*] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"
}

success() {
  printf "%s[*] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"
}

REPO_URL=https://github.com/plabrum/.dotfiles.git
REPO_PATH="$HOME/.dotfiles"

# Install the xcode command line tools to get git
if xcode-select -p >/dev/null; then
  info "xCode Command Line Tools already installed"
else
  info "Installing xCode Command Line Tools..."
  xcode-select --install
  sudo xcodebuild -license accept
  success "Finished installing xCode Command Line Tools."
fi

# Clone or pull the dotfiles repo
if [ -d "$REPO_PATH" ]; then
  info "Updating .dotfiles repo in $REPO_PATH"
  cd "$REPO_PATH"
  git pull
else
  info "Cloning .dotfiles repo from $REPO_URL into $REPO_PATH"
  git clone "$REPO_URL" "$REPO_PATH"
  cd "$REPO_PATH"
fi

# Navigate to the dotfiles directory
cd "$REPO_PATH"

# Run the apply_configuration.sh script
bash scripts/apply_configuration.sh
