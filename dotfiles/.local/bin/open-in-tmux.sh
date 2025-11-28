#!/bin/bash
# Open file in Neovim inside existing tmux session (or start one if none)
# Bring Ghostty to foreground if already open

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

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
  /Applications/Ghostty.app/Contents/MacOS/ghostty -- bash -lc "tmux new-session '$cmd'"
fi

# --- Focus Ghostty ---
osascript -e 'delay 0.1' -e 'tell application "Ghostty" to activate'
