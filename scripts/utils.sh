#!/bin/zsh

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
	read -r "REPLY?Press enter to continue: "
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

unstow_vscode_settings() {
	local vscode_dir="$HOME/Library/Application Support/Code/User"
	local config_dir="$(pwd)/configs/vscode"

	mkdir -p "$config_dir/snippets"
	
	[ -f "$vscode_dir/keybindings.json" ] && cp "$vscode_dir/keybindings.json" "$config_dir/keybindings.json"
	[ -f "$vscode_dir/settings.json" ] && cp "$vscode_dir/settings.json" "$config_dir/settings.json"
	[ -d "$vscode_dir/snippets" ] && cp "$vscode_dir/snippets/"*.json "$config_dir/snippets/"
	
	success "VSCode settings loaded into $config_dir"
}

stow_vscode_settings() {
	local vscode_dir="$HOME/Library/Application Support/Code/User"
	local config_dir="$(pwd)/configs/vscode"

	echo "Copying VSCode settings from $vscode_dir to $config_dir"
	[ -f "$config_dir/keybindings.json" ] && cp "$config_dir/keybindings.json" "$vscode_dir/keybindings.json"
	[ -f "$config_dir/settings.json" ] && cp "$config_dir/settings.json" "$vscode_dir/settings.json"
	[ -d "$config_dir/snippets" ] && cp "$config_dir/snippets/"*.json "$vscode_dir/snippets/"
	
	success "VSCode settings saved from $config_dir"
}

print_sections(){
	local section=$1
	for section in "${(@k)config}"; do
		echo "Section: $section"
		for item in ${(s: :)config[$section]}; do
			key="${item%%.*}"
			value="${item#*.}"
			echo "  $key = $value"
		done
	done
}
