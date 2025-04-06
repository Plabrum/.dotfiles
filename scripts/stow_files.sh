#!/bin/bash
set -euo pipefail

# # Function to log information
# info() {
#     echo "[INFO] $1"
# }

# Function to stow configurations
stow_configs() {

    # Find all directories in /stow
    to_stow=$(find stow -maxdepth 1 -type d -mindepth 1 | awk -F "/" '{print $NF}' ORS=' ')
    info "Stowing: $to_stow"

    # Check if directories exist
    for dir in $to_stow; do
        if [[ ! -d "stow/$dir" ]]; then
            echo "[ERROR] Directory stow/$dir does not exist"
            exit 1
        fi
    done

    # Remove existing files managed by stow
    for dir in $to_stow; do
        if [[ -d "stow/$dir" ]]; then
            echo "Removing existing files for $dir"
            stow -d stow --verbose 1 --target "$HOME" -D "$dir"
        fi
    done

    # Stow the configurations
    stow -d stow --verbose 1 --target "$HOME" $to_stow
}

# Call the function
# stow_configs