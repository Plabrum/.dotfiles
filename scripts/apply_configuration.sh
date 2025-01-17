#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

. scripts/utils.sh
. scripts/terminal.sh
. scripts/packages.sh
. scripts/configure_github.sh
. scripts/conda.sh
. scripts/osx_settings.sh
. scripts/stow_files.sh

echo "Starting installation"
run_installer "Homebrew" install_homebrew
run_installer "Brew Apps" install_brew_casks "${brew_apps[@]}"
run_installer "Brew Packages" install_brew_packages "${brew_packages[@]}"
run_installer "Mac App Store Apps" install_masApps "${mas_apps[@]}"
run_installer "Oh My Zsh" install_oh_my_zsh
run_installer "Iterm2" configure_iterm2
run_installer "VS Code Extensions" install_vs_code_extensions "${vs_code_extensions[@]}"
run_installer "Miniconda" install_miniconda
run_installer "Conda Packages" install_conda_packages conda_packages
run_installer "Stowed Configs" stow_configs
run_installer "VS Code Settings" stow_vscode_settings
run_installer "Apply OSX Settings" setup_osx
run_installer "Github SSH" setup_github_ssh
