#!/bin/bash
# Open file in Neovim inside existing tmux session (or start one if none)
# Bring terminal to foreground if already open

# Platform-specific PATH and terminal setup
if [ "$(uname -s)" = "Darwin" ]; then
    export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
    TERMINAL_BIN="/Applications/Ghostty.app/Contents/MacOS/ghostty"
else
    export PATH="/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin"
    TERMINAL_BIN="ghostty"  # Assumes Ghostty is in PATH on Linux
fi

file="$1"

if [ -z "$file" ]; then
  cmd="nvim"
  win_name="nvim"
else
  cmd="nvim \"$file\""
  win_name="$(basename "$file")"
fi

if tmux has-session 2>/dev/null; then
  tmux new-window -n "$win_name" "$cmd" \; select-window -t :$
else
  $TERMINAL_BIN -- bash -lc "tmux new-session '$cmd'"
fi

# Focus terminal - platform specific
if [ "$(uname -s)" = "Darwin" ]; then
  osascript -e 'delay 0.1' -e 'tell application "Ghostty" to activate'
fi
