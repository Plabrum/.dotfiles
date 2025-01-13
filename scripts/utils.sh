#!/bin/bash

reset_color=$(tput sgr 0)

info() {
	printf "%s[*] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"
}

success() {
	printf "%s[*] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"
}

err() {
	printf "%s[*] %s%s\n" "$(tput setaf 1)" "$1" "$reset_color"
}

warn() {
	printf "%s[*] %s%s\n" "$(tput setaf 3)" "$1" "$reset_color"
}

print_section_header() {
  info "################################################################################"
  info "$1"
  info "################################################################################"
}

wait_input() {
	read -p -r "Press enter to continue: "
}

# General installation function
run_installer() {
    local name="Installing $1..."
    local installing_function="$2"
    local args="$3"
    
    wait_input
    print_section_header "$name"
    # Call the passed function by its name with arguments
    $installing_function "$args"
    success "Finished installing $name."
}


restart_system() {
  info "System needs to restart. Restart?"

	select yn in "y" "n"; do
		case $yn in
		y)
			sudo shutdown -r now
			break
			;;
		n) exit ;;
		esac
	done
}

# Function to stow configurations
stow_configs() {
  # $1 is DOTFILES_DIR is the directory where your dotfiles are stored
  #  $2 is the list of directories to stow
    for config in "${CONFIGS[@]}"; do
        echo "Stowing $config..."
        stow --dir="$DOTFILES_DIR" --target="$HOME" "$config"
        if [ $? -eq 0 ]; then
            echo "Successfully stowed $config"
        else
            echo "Failed to stow $config" >&2
        fi
    done
}

setup_github_ssh() {
	if [ -z "${SSH_PASSPHRASE}" ]; then
		echo "SSH_PASSPHRASE not set"
	else
		info "Using $SSH_PASSPHRASE"
		ssh-keygen -t ed25519 -C "$SSH_PASSPHRASE"

		info "Adding ssh key to keychain"
		ssh-add -K ~/.ssh/id_ed25519

		info "Remember add ssh key to github account 'pbcopy < ~/.ssh/id_ed25519.pub'"
	fi
}

parse_config() {
  local config_file="$1"
  declare -n config="$2"  # Declare a reference to the associative array passed as the second argument

  # Read through the configuration file
  local current_section=""

  while IFS= read -r line; do
      # Skip empty lines and comments
      [[ -z "$line" || "$line" =~ ^# ]] && continue

      # Handle section headers
      if [[ "$line" =~ ^\[(.*)\]$ ]]; then
          current_section="${BASH_REMATCH[1]}"
          continue
      fi

      # Handle key-value pairs
      if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
          local key="${BASH_REMATCH[1]}"
          local value="${BASH_REMATCH[2]}"

          # Store the key-value pair in the passed associative array
          config["$current_section:$key"]="$value"
      fi
  done < "$config_file"
}