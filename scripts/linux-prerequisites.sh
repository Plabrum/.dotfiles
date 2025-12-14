#!/bin/bash

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
