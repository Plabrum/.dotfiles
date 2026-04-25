#!/bin/bash

# Cross-platform CLI packages installed for every profile (minimal + full).
# NOTE: zsh is NOT in this list - it's installed via native package manager on Linux
# (in linux-prerequisites.sh) to avoid breaking login features.
export brew_packages_minimal=(
  # Shell + editor essentials (configs in this repo depend on these)
  git
  gh
  stow
  neovim
  tmux
  ripgrep
  fd
  jq
  font-blex-mono-nerd-font
  zsh-syntax-highlighting
  # Dev tooling
  python3
  node
  go
  pyenv
  uv
  lazygit
  lazydocker
  shellcheck
  shfmt
  tree-sitter
  awscli
  postgresql
  fortune
)

# macOS-only CLI packages installed only with the `full` profile.
# `mas` is required to drive `mas_apps_full`, so it lives with the GUI tier.
export brew_packages_macos_full=(
  mas
)

# GUI applications (macOS only - Homebrew Casks). Full profile only.
export brew_apps_full=(
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

# Mac App Store apps (macOS only). Full profile only.
export mas_apps_full=(
  1569813296 # 1Password
  441258766  # Magnet
)
