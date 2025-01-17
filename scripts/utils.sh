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

cleanup() {
	err "Last command failed"
	info "Finishing..."
}

print_section_header() {
	info "################################################################################"
	info "$1"
	info "################################################################################"
}

# General installation function
run_installer() {
	local name="Installing $1..."
	local installing_function="$2"
	local args="$3"

	read -r -p "Would you like to run the $name section? (y/n): " respsonse
	if [[ "$respsonse" == "y" ]]; then
		print_section_header "$name"
		# Call the passed function by its name with arguments
		$installing_function "$args"
		success "Finished installing $name."
	else
		info "Skipping $name."
	fi
	trap cleanup SIGINT SIGTERM ERR EXIT
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
