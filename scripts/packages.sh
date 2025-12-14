#!/bin/bash

# GUI applications (macOS only - Homebrew Casks)
export brew_apps=(
  docker
  google-chrome
  slack
  spotify
  1password
  daisydisk
  logi-options+
  chatgpt
  typora
  mimestream
  aldente
  karabiner-elements
  ghostty
)

# Mac App Store apps (macOS only)
export mas_apps=(
  1569813296 # 1Password
  441258766  # Magnet
)

# Cross-platform CLI packages (work on both macOS and Linux)
export brew_packages=(
  neovim
  git
  gh
  lazygit
  lazydocker
  jq
  python3
  tmux
  node
  ripgrep
  fd
  tree-sitter
  shellcheck
  stow
  postgresql
  go
  awscli
  font-blex-mono-nerd-font
  shfmt
  pyenv
  fortune
  uv
)

# macOS-only CLI packages
export brew_packages_macos=(
  mas  # Mac App Store CLI
)
