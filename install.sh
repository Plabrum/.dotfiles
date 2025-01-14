#!/bin/zsh
set -o errexit

REPO_URL=https://github.com/plabrum/.dotfiles.git
REPO_PATH="$HOME/.dotfiles"

# Install the xcode command line tools to get git
if xcode-select -p >/dev/null; then
	echo "xCode Command Line Tools already installed"
else
	echo "Installing xCode Command Line Tools..."
	xcode-select --install
	sudo xcodebuild -license accept
fi

# Use git to clone the dotfiles repo
echo "Cloning .dotfiles repo from $REPO_URL into $REPO_PATH"
git clone "$REPO_URL" "$REPO_PATH"

# Navigate to the dotfiles directory
echo "Change path to $REPO_PATH"
cd "$REPO_PATH"

echo "Starting installation"
bash apply_configuration.sh


# Main script execution
install_miniconda
install_conda_packages

echo "Miniconda and packages installed successfully."
