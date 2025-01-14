#!/bin/zsh

set -o errexit
set -o nounset
set -o pipefail

. scripts/utils.sh
. scripts/terminal.sh


configure_iterm2
exit 0 

config_file="config.ini"

typeset -A config

parse_ini_file() {
	local file=$1
	local -n config_ref=$2
	local current_section=""
	local active_section=()
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Skip comments and empty lines
		[[ "$line" =~ '^[[:space:]]*([#;]|$)' ]] && continue
		# Detect section
		if [[ "$line" =~ '^\[(.*)\]$' ]]; then
			# if the active section is not empty, store it in the config array
			if [[ ${#active_section} -ne 0 ]]; then
				config_ref["${current_section}"]="${active_section[@]}"
				active_section=()
			fi
			current_section="${line#"["}"
			current_section="${current_section%"]"}"
			continue
		fi
		
		# Parse key-value pairs
		if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
			key="${line%%=*}"
			value="${line#*=}"
			# Store in associative array with section prefix
			active_section+=("${key}.${value}")
		fi
	done < $file
	config_ref["${current_section}"]="${active_section[@]}"
}

parse_ini_file $config_file config

print_sections config



# Main script execution
install_miniconda
install_conda_packages

echo "Miniconda and packages installed successfully."