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

# Platform detection
detect_os() {
	case "$(uname -s)" in
	Darwin)
		echo "macos"
		;;
	Linux)
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			case "$ID" in
			ubuntu | debian)
				echo "debian"
				;;
			fedora | rhel | centos | rocky | almalinux)
				echo "redhat"
				;;
			*)
				echo "linux"
				;;
			esac
		else
			echo "linux"
		fi
		;;
	*)
		echo "unknown"
		;;
	esac
}

export OS_TYPE=$(detect_os)

is_macos() {
	[ "$OS_TYPE" = "macos" ]
}

is_linux() {
	[ "$OS_TYPE" = "debian" ] || [ "$OS_TYPE" = "redhat" ] || [ "$OS_TYPE" = "linux" ]
}

is_debian() {
	[ "$OS_TYPE" = "debian" ]
}

is_redhat() {
	[ "$OS_TYPE" = "redhat" ]
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

# General installation function. The profile chosen at the top of install.sh
# decides which sections run; this just announces and executes.
run_installer() {
	local name=$1
	local installing_function="$2"
	shift 2

	print_section_header "$name"
	$installing_function "$@"
	success "Finished installing $name."
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
