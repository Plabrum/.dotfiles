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
  zsh-syntax-highlighting
  # Dev tooling
  python3
  node
  go
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

# Nerd Font, installed for every profile -- the terminal configs in this repo
# assume its glyphs. Kept out of `brew_packages_minimal` because it's a *cask*:
# `brew install` auto-detects that on macOS, but Homebrew on Linux has no cask
# support at all, so a plain formula-style install errors out there. Linux gets
# the same font from the Nerd Fonts release instead (`install_nerd_font`).
export brew_fonts_macos=(
  font-blex-mono-nerd-font
)

# macOS-only CLI packages installed only with the `full` profile.
# `mas` is required to drive `mas_apps_full`, so it lives with the GUI tier.
export brew_packages_macos_full=(
  mas
  mole
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
