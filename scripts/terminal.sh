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
		# RUNZSH=no: the installer otherwise ends with `exec zsh -l` and parks the
		# install in a nested shell. CHSH stays on so it still sets the login shell.
		ZSH=~/.oh-my-zsh ZSH_DISABLE_COMPFIX=true RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		chmod 744 ~/.oh-my-zsh/oh-my-zsh.sh
	else
		warn "oh-my-zsh already installed"
	fi

	# Install powerlevel10k theme
	if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
		info "Installing powerlevel10k theme..."
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	fi

	# Install custom plugins
	if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
		info "Installing zsh-syntax-highlighting plugin..."
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
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

# Create ~/.zshrc and ~/.aliases (machine-local, not stowed) sourcing their
# .shared halves from this repo. Idempotent.
ensure_shell_bootstrap() {
	local rc="$HOME/.zshrc"
	if [ ! -f "$rc" ]; then
		info "Creating $rc (machine-local, sources .zshrc.shared)"
		cat >"$rc" <<-'EOF'
			# Machine-specific configuration
			# Add any machine-specific environment variables, paths, or settings here

			# Source shared dotfiles configuration
			[ -f ~/.zshrc.shared ] && source ~/.zshrc.shared
		EOF
	elif grep -q "zshrc.shared" "$rc"; then
		warn "$rc already sources .zshrc.shared"
	else
		info "Appending .zshrc.shared source line to existing $rc"
		printf '\n# Source shared dotfiles configuration\n[ -f ~/.zshrc.shared ] && source ~/.zshrc.shared\n' >>"$rc"
		# .zshrc.shared loads oh-my-zsh itself, so appending to the stock template
		# loads it twice.
		warn "If $rc is oh-my-zsh's stock template, trim its body: .zshrc.shared loads oh-my-zsh itself"
	fi

	local aliases="$HOME/.aliases"
	if [ ! -f "$aliases" ]; then
		info "Creating $aliases (machine-local, sources .aliases.shared)"
		cat >"$aliases" <<-'EOF'
			# Machine-specific aliases
			# Add any machine-specific aliases or functions here

			# Source shared aliases
			[ -f ~/.aliases.shared ] && source ~/.aliases.shared
		EOF
	elif grep -q "aliases.shared" "$aliases"; then
		warn "$aliases already sources .aliases.shared"
	else
		info "Appending .aliases.shared source line to existing $aliases"
		printf '\n# Source shared aliases\n[ -f ~/.aliases.shared ] && source ~/.aliases.shared\n' >>"$aliases"
	fi
}

# Install/upgrade Neovim from the latest GitHub release into ~/.local (no sudo).
# The slim config needs >= 0.12 for vim.pack; distro packages are older.
install_neovim_linux() {
	if is_macos; then
		info "Skipping - macOS gets neovim from Homebrew"
		return 0
	fi

	local arch asset
	arch="$(uname -m)"
	case "$arch" in
		x86_64 | amd64) asset="nvim-linux-x86_64.tar.gz" ;;
		aarch64 | arm64) asset="nvim-linux-arm64.tar.gz" ;;
		*)
			err "No Neovim release build for architecture '$arch'"
			return 1
			;;
	esac

	# /releases/latest redirects to the tagged release; avoids needing jq.
	local latest
	latest="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
		https://github.com/neovim/neovim/releases/latest | sed 's|.*/tag/||')"
	if [ -z "$latest" ]; then
		err "Could not determine the latest Neovim release"
		return 1
	fi

	local current=""
	if command -v nvim &>/dev/null; then
		# `nvim --version` line 1 looks like: NVIM v0.12.4
		current="$(nvim --version | head -1 | awk '{print $2}')"
	fi

	if [ "$current" = "$latest" ]; then
		warn "Neovim $current is already the latest release"
		return 0
	fi

	if [ -n "$current" ]; then
		info "Upgrading Neovim $current -> $latest..."
	else
		info "Installing Neovim $latest..."
	fi

	local tmp_archive
	tmp_archive="$(mktemp)"
	if ! curl -fsSL "https://github.com/neovim/neovim/releases/download/${latest}/${asset}" -o "$tmp_archive"; then
		err "Failed to download Neovim $latest ($asset)"
		rm -f "$tmp_archive"
		return 1
	fi

	# Strip the release-name top-level dir.
	mkdir -p "$HOME/.local"
	if ! tar -xzf "$tmp_archive" -C "$HOME/.local" --strip-components=1; then
		err "Failed to unpack $tmp_archive"
		rm -f "$tmp_archive"
		return 1
	fi
	rm -f "$tmp_archive"

	local installed
	installed="$("$HOME/.local/bin/nvim" --version | head -1 | awk '{print $2}')"
	if [ "$installed" = "$latest" ]; then
		success "Neovim $installed installed to $HOME/.local"
	else
		warn "Installed Neovim reports $installed, expected $latest"
	fi
}

# Install/upgrade the tree-sitter CLI into ~/.local/bin. nvim-treesitter's main
# branch shells out to it to build parsers. macOS gets it from Homebrew.
install_treesitter_cli_linux() {
	if is_macos; then
		info "Skipping - macOS gets tree-sitter from Homebrew"
		return 0
	fi

	local arch asset
	arch="$(uname -m)"
	case "$arch" in
		x86_64 | amd64) asset="tree-sitter-linux-x64.gz" ;;
		aarch64 | arm64) asset="tree-sitter-linux-arm64.gz" ;;
		*)
			err "No tree-sitter release build for architecture '$arch'"
			return 1
			;;
	esac

	local latest
	latest="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
		https://github.com/tree-sitter/tree-sitter/releases/latest | sed 's|.*/tag/||')"
	if [ -z "$latest" ]; then
		err "Could not determine the latest tree-sitter release"
		return 1
	fi

	local current=""
	if command -v tree-sitter &>/dev/null; then
		# `tree-sitter --version` prints e.g. "tree-sitter 0.26.11" (no leading v)
		current="v$(tree-sitter --version | awk '{print $2}')"
	fi

	if [ "$current" = "$latest" ]; then
		warn "tree-sitter ${current} is already the latest release"
		return 0
	fi

	if [ -n "$current" ]; then
		info "Upgrading tree-sitter $current -> $latest..."
	else
		info "Installing tree-sitter $latest..."
	fi

	# Releases are glibc-linked and the floor varies by build (v0.26.11 needs 2.39,
	# v0.25.10 needs 2.34, v0.24.7 needs 2.29), so try newest first and keep the
	# first one that actually runs.
	mkdir -p "$HOME/.local/bin"
	local dest="$HOME/.local/bin/tree-sitter"
	local candidate tmp_gz tmp_bin
	for candidate in "$latest" v0.25.10 v0.24.7; do
		tmp_gz="$(mktemp)"
		tmp_bin="$(mktemp)"
		if ! curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/${candidate}/${asset}" -o "$tmp_gz"; then
			warn "Could not download tree-sitter $candidate"
			rm -f "$tmp_gz" "$tmp_bin"
			continue
		fi
		if ! gunzip -c "$tmp_gz" >"$tmp_bin"; then
			warn "Could not unpack tree-sitter $candidate"
			rm -f "$tmp_gz" "$tmp_bin"
			continue
		fi
		chmod +x "$tmp_bin"
		if "$tmp_bin" --version &>/dev/null; then
			mv "$tmp_bin" "$dest"
			rm -f "$tmp_gz"
			[ "$candidate" = "$latest" ] || warn "Using tree-sitter $candidate: $latest needs a newer glibc than this system has"
			success "tree-sitter $("$dest" --version | awk '{print $2}') installed"
			return 0
		fi
		warn "tree-sitter $candidate will not run here (likely glibc too old) - trying an older release"
		rm -f "$tmp_gz" "$tmp_bin"
	done

	err "No published tree-sitter build runs on this system"
	info "Options: 'brew install tree-sitter' (Homebrew ships its own glibc), or"
	info "'cargo install tree-sitter-cli' to compile against the system glibc"
	return 1
}

# Make zsh the login shell. Usually a no-op -- oh-my-zsh's installer does this
# too -- but needed when install_oh_my_zsh is skipped because ~/.zshrc exists.
ensure_default_shell() {
	# Prefer the system zsh on macOS: it's already in /etc/shells, whereas a
	# Homebrew zsh (which `command -v` would find first) would need adding.
	local zsh_path
	if is_macos && [ -x /bin/zsh ]; then
		zsh_path="/bin/zsh"
	elif ! zsh_path="$(command -v zsh)"; then
		err "zsh is not installed - cannot set it as the login shell"
		return 1
	fi

	# The *login* shell from the user database, not $SHELL (which only reflects
	# the current process and would report zsh inside any zsh subshell).
	local current=""
	if command -v getent &>/dev/null; then
		current="$(getent passwd "$USER" | cut -d: -f7)"
	elif is_macos; then
		current="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
	fi
	current="${current:-$SHELL}"

	if [ "$(basename "$current")" = "zsh" ]; then
		warn "Login shell is already zsh ($current)"
		return 0
	fi

	# chsh refuses any shell that isn't listed in /etc/shells.
	if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
		info "Adding $zsh_path to /etc/shells (requires sudo)"
		if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
			err "Could not add $zsh_path to /etc/shells"
			return 1
		fi
	fi

	info "Changing login shell from $current to $zsh_path..."
	if sudo -n true 2>/dev/null; then
		sudo chsh -s "$zsh_path" "$USER" || { err "chsh failed - run: chsh -s $zsh_path"; return 1; }
	else
		# Prompts for the *user's* password, not sudo's.
		chsh -s "$zsh_path" || { err "chsh failed - run: chsh -s $zsh_path"; return 1; }
	fi

	success "Login shell set to $zsh_path (takes effect on next login)"
}

# Install the Nerd Font the terminal configs assume.
#
# macOS gets it as a Homebrew cask. Linux downloads the same font from the Nerd
# Fonts release into the user font dir -- no sudo, no package manager.
#
# Worth knowing what this does *not* fix: the Linux framebuffer console
# (TERM=linux) loads PSF fonts via setfont/console-setup, which are capped at
# 512 glyphs, so Nerd Font icons can never render there no matter what is
# installed. This only helps GUI/desktop terminals. `.zshrc.shared` handles the
# console case by falling back to POWERLEVEL9K_MODE=ascii.
install_nerd_font() {
	if is_macos; then
		install_brew_casks "$@"
		return $?
	fi

	# The Nerd Fonts release asset matching the macOS cask. Pinned rather than
	# tracking `latest` so a new machine gets the same font version as the others.
	local nerd_font_version="v3.4.0"
	local nerd_font_archive="IBMPlexMono.tar.xz"

	# fontconfig is what makes a font in ~/.local/share/fonts discoverable. On a
	# headless server it's often absent -- and without a GUI there's nothing to
	# render the font anyway, so skip rather than pull in dependencies.
	if ! command -v fc-cache &>/dev/null; then
		warn "fontconfig (fc-cache) not found - skipping font install"
		info "Nothing renders fonts server-side over SSH; your client's font is what matters"
		return 0
	fi

	local font_dir="$HOME/.local/share/fonts/BlexMonoNerdFont"
	if [ -d "$font_dir" ] && [ -n "$(find "$font_dir" -name '*.ttf' -print -quit 2>/dev/null)" ]; then
		warn "Nerd Font already installed at $font_dir"
		return 0
	fi

	if ! command -v tar &>/dev/null || ! command -v xz &>/dev/null; then
		err "tar with xz support is required to unpack $nerd_font_archive (try: apt-get install xz-utils)"
		return 1
	fi

	local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_font_version}/${nerd_font_archive}"
	local tmp_archive
	tmp_archive="$(mktemp)"

	info "Downloading ${nerd_font_archive} (${nerd_font_version})..."
	if ! curl -fsSL "$url" -o "$tmp_archive"; then
		err "Failed to download $url"
		rm -f "$tmp_archive"
		return 1
	fi

	mkdir -p "$font_dir"
	info "Unpacking into $font_dir..."
	if ! tar -xJf "$tmp_archive" -C "$font_dir"; then
		err "Failed to unpack $tmp_archive"
		rm -f "$tmp_archive"
		return 1
	fi
	rm -f "$tmp_archive"

	info "Rebuilding font cache..."
	fc-cache -f "$font_dir" >/dev/null

	if fc-list | grep -qi "blexmono"; then
		success "BlexMono Nerd Font installed"
	else
		warn "Font unpacked but fontconfig doesn't list it - check $font_dir"
	fi
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
