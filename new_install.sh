#!/bin/bash

# Script to stow dotfiles independently using GNU Stow

# Set variables
DOTFILES_DIR="$PWD/dotfiles"  # Assuming the script is run from your repository root
TARGET_DIR="$HOME"            # Target directory (usually home directory)
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"  # Directory for backups

# Options
FORCE_MODE=false  # Whether to force stowing (backup and replace existing files)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--force|-f]"
            exit 1
            ;;
    esac
done

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed. Please install it first."
    exit 1
fi

echo "Stowing dotfiles from $DOTFILES_DIR to $TARGET_DIR"
echo "Force mode: $FORCE_MODE"

# Create backup directory if force mode is enabled
if $FORCE_MODE; then
    mkdir -p "$BACKUP_DIR"
    echo "Backup directory created at $BACKUP_DIR"
fi

# Function to stow a single file
stow_file() {
    local file="$1"
    local rel_path="${file#$DOTFILES_DIR/}"
    local target_file="$TARGET_DIR/$rel_path"
    local target_dir="$(dirname "$target_file")"
    
    echo "Processing: $rel_path"
    
    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Check if target file exists and handle accordingly
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        if [ -L "$target_file" ]; then
            echo "  Symlink already exists at $target_file"
            if $FORCE_MODE; then
                echo "  Removing existing symlink"
                rm -f "$target_file"
            else
                echo "  Skipping (use --force to replace)"
                return
            fi
        else
            echo "  File already exists at $target_file"
            if $FORCE_MODE; then
                echo "  Backing up to $BACKUP_DIR/$rel_path"
                mkdir -p "$(dirname "$BACKUP_DIR/$rel_path")"
                mv "$target_file" "$BACKUP_DIR/$rel_path"
            else
                echo "  Skipping (use --force to backup and replace)"
                return
            fi
        fi
    fi
    
    # Create the symlink directly without using stow for individual files
    ln -s "$file" "$target_file"
    echo "  Symlinked successfully"
}

# Function to stow a directory
stow_directory() {
    local dir="$1"
    local rel_path="${dir#$DOTFILES_DIR/}"
    local target_dir="$TARGET_DIR/$rel_path"
    
    echo "Processing directory: $rel_path"
    
    # Check if target exists and handle accordingly
    if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
        if [ -L "$target_dir" ]; then
            echo "  Symlink already exists at $target_dir"
            if $FORCE_MODE; then
                echo "  Removing existing symlink"
                rm -f "$target_dir"
            else
                echo "  Skipping (use --force to replace)"
                return
            fi
        elif [ -d "$target_dir" ]; then
            echo "  Directory already exists at $target_dir"
            if $FORCE_MODE; then
                echo "  Backing up to $BACKUP_DIR/$rel_path"
                mkdir -p "$(dirname "$BACKUP_DIR/$rel_path")"
                if [ -e "$BACKUP_DIR/$rel_path" ]; then
                    rm -rf "${BACKUP_DIR:?}/${rel_path:?}"
                fi
                mv "$target_dir" "$BACKUP_DIR/$rel_path"
            else
                echo "  Skipping (use --force to backup and replace)"
                return
            fi
        fi
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target_dir")"
    
    # Create the symlink directly
    ln -s "$dir" "$target_dir"
    echo "  Symlinked successfully"
}

# Process top-level files in dotfiles directory
for file in "$DOTFILES_DIR"/*; do
    if [ -f "$file" ]; then
        stow_file "$file"
    elif [ -d "$file" ] && [ "$(basename "$file")" != ".config" ]; then
        stow_directory "$file"
    fi
done

# Process .config subdirectories
if [ -d "$DOTFILES_DIR/.config" ]; then
    echo "Processing .config subdirectories"
    
    # Make sure .config exists in target
    mkdir -p "$TARGET_DIR/.config"
    
    for item in "$DOTFILES_DIR/.config"/*; do
        if [ -d "$item" ]; then
            stow_directory "$item"
        elif [ -f "$item" ]; then
            stow_file "$item"
        fi
    done
fi

if $FORCE_MODE && [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    echo "No files were backed up, removing empty backup directory"
    rmdir "$BACKUP_DIR"
fi

echo "All dotfiles have been processed!"