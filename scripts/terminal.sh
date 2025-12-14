#!/bin/bash

install_homebrew() {
	if is_macos; then
		export HOMEBREW_CASK_OPTS="--appdir=/Applications"
	fi

	if hash brew &>/dev/null; then
		warn "Homebrew already installed"
	else
		info "Installing homebrew..."
		sudo --validate # reset `sudo` timeout to use Homebrew install in noninteractive mode
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

		# On Linux, add Homebrew to PATH for this session
		if is_linux; then
			if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
				eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
				success "Homebrew installed and added to current session PATH"
			fi
		fi
	fi
}

install_oh_my_zsh() {
	if [[ ! -f ~/.zshrc ]]; then
		info "Installing oh my zsh..."
		ZSH=~/.oh-my-zsh ZSH_DISABLE_COMPFIX=true sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		chmod 744 ~/.oh-my-zsh/oh-my-zsh.sh
	else
		warn "oh-my-zsh already installed"
	fi

	# Install custom plugins
	if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
		info "Installing zsh-syntax-highlighting plugin..."
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
	fi
}

install_brew_packages() {
	local packages=$*
	for package in $packages; do
		if brew list --formula | grep "$package" >/dev/null; then
			warn "Formula $package is already installed"
		else
			info "Installing package < $package >"
			brew install "$package"
		fi
	done
}

install_brew_casks() {
	if ! is_macos; then
		warn "Casks are macOS-only, skipping..."
		return 0
	fi

	local casks=("$@")
	echo "Casks: ${casks[*]}"
	for cask in "${casks[@]}"; do
		app_name=$(brew info --json=v2 --cask "$cask" | jq -r '.casks[0].artifacts[] | select(.app) | .app[0]')
		echo "App name: ${app_name} (from ${app_name:-$cask})"
		if [ -n "$app_name" ] && [ -d "/Applications/$app_name" ]; then
			warn "App $app_name is already in Applications"
		elif brew list --casks | grep "$cask" >/dev/null; then
			warn "Cask $cask is already installed"
		else
			echo "/Applications/$app_name"
			info "Installing cask < $cask >"
			brew install --cask "$cask"
		fi
	done
}

install_masApps() {
	if ! is_macos; then
		warn "Mac App Store is macOS-only, skipping..."
		return 0
	fi

	local mas_apps=("$@")
	info "Installing App Store apps..."
	for app in "${mas_apps[@]}"; do
		mas install "$app"
	done
}
