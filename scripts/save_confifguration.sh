#!/bin/zsh
. scripts/utils.sh

info "Saving VSCode settings..."
source "$REPO_PATH/scripts/utils.sh"
stow_vscode_settings
exit 0
