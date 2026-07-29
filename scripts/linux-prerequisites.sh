#!/bin/bash

# CLI tools the stowed configs expect, from the native package manager.
#
# These are all in `brew_packages_minimal` too, but Homebrew-on-Linux is a slow
# sudo detour and one unavailable formula aborts the whole install, so on Linux
# it's worth getting the essentials from apt/dnf first. Anything already present
# is a no-op for the package manager.
#
# Deliberately NOT here: neovim (distro versions are too old for the slim config
# -- see install_neovim_linux) and lazygit (no Debian/Ubuntu package).
install_linux_cli_tools() {
	# fd is packaged as `fd-find` on Debian (binary `fdfind`) and `fd-find` on
	# Fedora (binary `fd`).
	local debian_pkgs=(tmux ripgrep fd-find jq fzf xz-utils unzip)
	local redhat_pkgs=(tmux ripgrep fd-find jq fzf xz unzip)

	if is_debian; then
		info "Installing CLI tools (apt)..."
		sudo apt-get install -y "${debian_pkgs[@]}"
	elif is_redhat; then
		info "Installing CLI tools (dnf)..."
		sudo dnf install -y "${redhat_pkgs[@]}"
	else
		warn "Unknown distribution - install these manually: ${debian_pkgs[*]}"
		return 0
	fi

	success "CLI tools installed"
}

install_linux_build_tools() {
	if is_debian; then
		info "Installing build prerequisites for Ubuntu/Debian..."
		sudo apt-get update
		sudo apt-get install -y build-essential procps curl file git zsh
		success "Build tools installed (Debian-based)"
	elif is_redhat; then
		info "Installing build prerequisites for Fedora/RHEL..."
		sudo dnf groupinstall -y 'Development Tools'
		sudo dnf install -y procps-ng curl file git zsh
		success "Build tools installed (RedHat-based)"
	else
		warn "Unsupported Linux distribution, attempting generic installation..."
		if command -v apt-get &>/dev/null; then
			sudo apt-get update && sudo apt-get install -y build-essential procps curl file git zsh
		elif command -v dnf &>/dev/null; then
			sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y procps-ng curl file git zsh
		elif command -v yum &>/dev/null; then
			sudo yum groupinstall -y 'Development Tools' && sudo yum install -y procps-ng curl file git zsh
		else
			err "Could not install build prerequisites"
			return 1
		fi
		success "Build tools installed"
	fi
}
