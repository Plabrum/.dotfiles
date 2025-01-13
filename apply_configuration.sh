#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

REPO_URL=https://github.com/protiumx/.dotfiles.git
REPO_PATH="$HOME/.dotfiles"

# Directory where your dotfiles are stored
DOTFILES_DIR="$HOME/dotfiles"

# List of directories to stow (update as needed)
CONFIGS=("nvim" "zsh" "tmux" "git" "bash")


apps=(
	
)

mas_apps=(
	"937984704"  # Amphetamine
	"1444383602" # Good Notes 5
	"768053424"  # Gappling (svg viewer)
)

packages=(
	bat        # https://github.com/sharkdp/bat
	bandwhich  # https://github.com/imsnif/bandwhich
	bottom     # https://github.com/ClementTsang/bottom
	cmake
	ctags
	curl
	dasel      # https://github.com/TomWright/dasel
	dust       # https://github.com/bootandy/dust
	eza        # https://github.com/eza-community/eza
	fzf        # https://github.com/junegunn/fzf
	fd         # https://github.com/sharkdp/fd
	gettext
	git-delta  # https://github.com/dandavison/delta
	gpg
	go
	graphviz   # https://graphviz.org/
	grpcurl    # https://github.com/fullstorydev/grpcurl
	httpie     # https://github.com/httpie/httpie
	imagemagick
	jless      # https://github.com/PaulJuliusMartinez/jless
	jq
	k9s        # https://github.com/derailed/k9s
	kubernetes-cli
	hyperfine  # https://github.com/sharkdp/hyperfine
	lazydocker # https://github.com/jesseduffield/lazydocker
	lf         # https://github.com/gokcehan/lf
	libpq
	lynx       # https://lynx.invisible-island.net/
	mas        # https://github.com/mas-cli/mas
	minikube
	neovim
	node
	nmap
	openjdk
	openssl
	pinentry-mac
	postgresql
	procs      # https://github.com/dalance/procs/
	python3
	protobuf
	ripgrep    # https://github.com/BurntSushi/ripgre
	rustup
	sd         # https://github.com/chmln/sd
	shellcheck
	stow
	stylua     # https://github.com/JohnnyMorganz/StyLua
	telnet
	usql       # https://github.com/xo/usql
	websocat   # https://github.com/vi/websocat
	wget
	zsh
  zinit      # https://github.com/zdharma-continuum/zinit
	zoxide     # https://github.com/ajeetdsouza/zoxide
)



info "####### dotfiles #######"
read -p -r "Press enter to start:"
info "Bootstraping..."


run_installer "xcode cli tools" install_xcode


info "Cloning .dotfiles repo from $REPO_URL into $REPO_PATH"
git clone "$REPO_URL" "$REPO_PATH"


run_installer "HomeBrew" install_homebrew
run_installer "HomeBrew Packages" install_brew_formulas "${packages[@]}"
run_installer "MacOS Apps from brew Cask" install_brew_casks "${apps[@]}"
run_installer "MacOS Apps from App Store" install_masApps "${mas_apps[@]}"


# Example usage of the function
declare -A config  # Declare the associative array

config_file="config.ini"
parse_config "$config_file" config  # Pass the array as a reference

# Output the parsed config (for demonstration)
for section_key in "${!config[@]}"; do
    echo "$section_key=${config[$section_key]}"
done
