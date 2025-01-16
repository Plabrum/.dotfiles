#!/bin/bash

install_homebrew() {
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"
	if hash brew &>/dev/null; then
		warn "Homebrew already installed"
	else
		info "Installing homebrew..."
		sudo --validate # reset `sudo` timeout to use Homebrew install in noninteractive mode
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
}

install_oh_my_zsh() {
	if [[ ! -f ~/.zshrc ]]; then
		info "Installing oh my zsh..."
		ZSH=~/.oh-my-zsh ZSH_DISABLE_COMPFIX=true sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		chmod 744 ~/.oh-my-zsh/oh-my-zsh.sh
		# plugins
		git clone "https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab"
	else
		warn "oh-my-zsh already installed"
	fi
}

configure_iterm2() {
	if [ -d "/Applications/iTerm.app" ]; then
		info "Configuring iTerm2..."
		# Specify the preferences directory
		defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$(pwd)/configs/iterm2"
		# Tell iTerm2 to use the custom preferences in the directory
		defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
		# Tell iTerm2 to save preferences automatically
		defaults write com.googlecode.iterm2.plist "NoSyncNeverRemindPrefsChangesLostForFile_selection" -int 2
		success "iTerm2 configured successfully"
	fi
}

apply_brew_taps() {
	local tap_packages=$*
	for tap in $tap_packages; do
		if brew tap | grep "$tap" >/dev/null; then
			warn "Tap $tap is already applied"
		else
			brew tap "$tap"
		fi
	done
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
	local casks=$*
	for cask in $casks; do
		if brew list --casks | grep "$cask" >/dev/null; then
			warn "Cask $cask is already installed"
		else
			info "Installing cask < $cask >"
			brew install --cask "$cask"
		fi
	done
}

install_masApps() {
	local mas_apps=$*
	info "Installing App Store apps..."
	for app in "${mas_apps[@]}"; do
		mas install "$app"
	done
}

install_vs_code_extensions() {
	vs_code_extensions=$*
	info "Installing Visual Studio Code extensions..."
	for extension in "${vs_code_extensions[@]}"; do
		code --install-extension "$extension"
	done
}

# Function to stow configurations
stow_configs() {
	local -r to_stow="$(find stow -maxdepth 1 -type d -mindepth 1 | awk -F "/" '{print $NF}' ORS=' ')"
	info "Stowing: $to_stow"
	stow -d stow --verbose 1 --target "$HOME" "$to_stow"
}

unstow_vscode_settings() {
	local vscode_dir="$HOME/Library/Application Support/Code/User"
	local -r config_dir="$(pwd)/configs/vscode"

	mkdir -p "$config_dir/snippets"

	[ -f "$vscode_dir/keybindings.json" ] && cp "$vscode_dir/keybindings.json" "$config_dir/keybindings.json"
	[ -f "$vscode_dir/settings.json" ] && cp "$vscode_dir/settings.json" "$config_dir/settings.json"
	[ -d "$vscode_dir/snippets" ] && cp "$vscode_dir/snippets/"*.json "$config_dir/snippets/"

	success "VSCode settings loaded into $config_dir"
}

stow_vscode_settings() {
	ocal vscode_dir="$HOME/Library/Application Support/Code/User"
	local -r config_dir="$(pwd)/configs/vscode"

	echo "Copying VSCode settings from $vscode_dir to $config_dir"
	[ -f "$config_dir/keybindings.json" ] && cp "$config_dir/keybindings.json" "$vscode_dir/keybindings.json"
	[ -f "$config_dir/settings.json" ] && cp "$config_dir/settings.json" "$vscode_dir/settings.json"
	[ -d "$config_dir/snippets" ] && cp "$config_dir/snippets/"*.json "$vscode_dir/snippets/"

	success "VSCode settings saved from $config_dir"
}
