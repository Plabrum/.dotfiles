# .dotfiles

Mac Os Dotfiles

## Install Configuration

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Plabrum/.dotfiles/refs/heads/main/install.sh)"
```

Inspo:

https://github.com/Stratus3D/dotfiles/blob/master/scripts/setup/darwin.sh

https://github.com/protiumx/.dotfiles/tree/main

https://github.com/joshukraine/dotfiles?tab=readme-ov-file

# REPO_URL=https://github.com/protiumx/.dotfiles.git

# REPO_PATH="$HOME/.dotfiles"

# info "####### dotfiles #######"

# read -r "REPLY?Press enter to start:"

# info "Bootstraping..."

# run_installer "xcode cli tools" install_xcode

# info "Cloning .dotfiles repo from $REPO_URL into $REPO_PATH"

# git clone "$REPO_URL" "$REPO_PATH"

# run_installer "HomeBrew" install_homebrew

# run_installer "HomeBrew Packages" install_brew_formulas "${packages[@]}"

# run_installer "MacOS Apps from brew Cask" install_brew_casks "${apps[@]}"

# run_installer "MacOS Apps from App Store" install_masApps "${mas_apps[@]}"
