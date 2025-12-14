#!/bin/bash
# Reset file associations after Xcode installation
# Sets "Open in Neovim" as the default for code files

# Get script directory and source utils
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# macOS only
if ! is_macos; then
    info "File associations with duti are macOS-only, skipping..."
    exit 0
fi

# Check if duti is installed
if ! command -v duti &> /dev/null; then
    echo "duti not found. Installing via Homebrew..."
    brew install duti
fi

NEOVIM_APP="com.apple.automator.Open-in-Neovim"

echo "Setting file associations for 'Open in Neovim'..."

# Swift and Objective-C files
duti -s "$NEOVIM_APP" .swift all
duti -s "$NEOVIM_APP" .m all
duti -s "$NEOVIM_APP" .mm all
duti -s "$NEOVIM_APP" .h all

# C/C++ files
duti -s "$NEOVIM_APP" .c all
duti -s "$NEOVIM_APP" .cpp all
duti -s "$NEOVIM_APP" .cc all
duti -s "$NEOVIM_APP" .cxx all
duti -s "$NEOVIM_APP" .hpp all
duti -s "$NEOVIM_APP" .hxx all

# Other common development files
duti -s "$NEOVIM_APP" .txt all
duti -s "$NEOVIM_APP" .md all
duti -s "$NEOVIM_APP" .json all
duti -s "$NEOVIM_APP" .yaml all
duti -s "$NEOVIM_APP" .yml all
duti -s "$NEOVIM_APP" .xml all
duti -s "$NEOVIM_APP" .plist all
duti -s "$NEOVIM_APP" .sh all
duti -s "$NEOVIM_APP" .bash all
duti -s "$NEOVIM_APP" .zsh all

# Scripting languages
duti -s "$NEOVIM_APP" .py all
duti -s "$NEOVIM_APP" .rb all
duti -s "$NEOVIM_APP" .js all
duti -s "$NEOVIM_APP" .ts all
duti -s "$NEOVIM_APP" .jsx all
duti -s "$NEOVIM_APP" .tsx all

# Web files
duti -s "$NEOVIM_APP" .html all
duti -s "$NEOVIM_APP" .css all
duti -s "$NEOVIM_APP" .scss all

# Config files
duti -s "$NEOVIM_APP" .conf all
duti -s "$NEOVIM_APP" .config all
duti -s "$NEOVIM_APP" .toml all
duti -s "$NEOVIM_APP" .ini all

# Rust, Go, etc.
duti -s "$NEOVIM_APP" .rs all
duti -s "$NEOVIM_APP" .go all

echo "✓ File associations updated!"
echo "Note: You may need to log out and back in for all changes to take effect."
