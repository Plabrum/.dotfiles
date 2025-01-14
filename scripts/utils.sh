#!/bin/bash

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
	local to_stow="$(find stow -maxdepth 1 -type d -mindepth 1 | awk -F "/" '{print $NF}' ORS=' ')"
	info "Stowing: $to_stow"
	stow -d stow --verbose 1 --target "$HOME" "$to_stow"
}

setup_github_ssh() {
	local email
	read -p "Enter your GitHub email: " email

	info "Generating SSH key for $email"
	ssh-keygen -t ed25519 -C "$email"

	info "Adding SSH key to keychain"
	ssh-add -K ~/.ssh/id_ed25519

	info "Copying SSH key to clipboard"
	pbcopy < ~/.ssh/id_ed25519.pub

	success "SSH key generated and copied to clipboard. Add it to your GitHub account."
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
