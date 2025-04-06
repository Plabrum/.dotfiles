#!/bin/bash

# Define variables
DOTFILES_REPO="$HOME/.dotfiles"    # Path to your dotfiles repository
BACKUP_DIR="$DOTFILES_REPO/backup" # Directory to store backups of modified files

# Check if the dotfiles repository exists
if [[ ! -d "$DOTFILES_REPO" ]]; then
	echo "Error: Dotfiles repository not found at $DOTFILES_REPO"
	exit 1
fi

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

echo "Unstowing dotfiles and copying them to the repository..."

# Loop through each stow package in the repository
for package in "$DOTFILES_REPO"/stow/*/; do
	package_name=$(basename "$package")

	echo "Processing package: $package_name"

	# Check if the package is currently stowed
	stow -n -D -d "$DOTFILES_REPO"/stow -t "$HOME" "$package_name" &>/dev/null
	if [[ $? -ne 0 ]]; then
		echo "  Skipping: $package_name is not stowed."
		continue
	fi

	# Unstow the package
	stow -D -d "$DOTFILES_REPO" -t "$HOME" "$package_name"

	# Copy files back to the repository
	for file in "$HOME"/.*; do
		# Skip special directories
		[[ "$file" == "$HOME/." || "$file" == "$HOME/.." ]] && continue
		file_name=$(basename "$file")

		# Check if the file belongs to this package
		if [[ -e "$DOTFILES_REPO/$package_name/$file_name" ]]; then
			# Backup if file exists and is different
			if [[ -f "$DOTFILES_REPO/$package_name/$file_name" ]] && ! cmp -s "$file" "$DOTFILES_REPO/$package_name/$file_name"; then
				echo "  Backing up modified file: $file_name"
				cp -L "$file" "$BACKUP_DIR/$file_name"
			fi

			echo "  Copying $file_name to $package_name"
			cp -L "$file" "$DOTFILES_REPO/$package_name/"
		fi
	done
done

echo "Unstow and copy complete. Check $BACKUP_DIR for backups of modified files."
