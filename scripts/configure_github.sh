#!/bin/bash

setup_github_ssh() {
	local email
	read -r -p "Enter your GitHub email: " email

	info "Generating SSH key for $email"
	ssh-keygen -t ed25519 -C "$email"

	info "Adding SSH key to keychain"
	ssh-add -K ~/.ssh/id_ed25519

	info "Copying SSH key to clipboard"
	pbcopy <~/.ssh/id_ed25519.pub

	success "SSH key generated and copied to clipboard. Add it to your GitHub account."
}
