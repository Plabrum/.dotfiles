# .dotfiles

Personal macOS development environment setup and configuration.

## Quick Setup (New Machine)

On a fresh Mac, run this single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/plabrum/.dotfiles/main/bootstrap.sh)
```

This will:
1. Install Xcode Command Line Tools
2. Clone this repository to `~/.dotfiles`
3. Run the full installation process

## What Gets Installed

### Package Managers
- Homebrew
- Oh My Zsh

### Development Tools
- Neovim, tmux, git, gh (GitHub CLI), lazygit, lazydocker
- Node.js, Python 3 (+ pyenv, uv)
- Go, PostgreSQL
- ripgrep, fzf, jq, shellcheck, shfmt
- GNU Stow (for dotfiles management)

### Applications
- Docker, Ghostty
- 1Password, Magnet
- Alfred, Karabiner Elements
- Slack, ChatGPT
- And more (see `scripts/packages.sh`)

### Configurations
- Neovim config (with LSP, formatters, linters)
- Tmux config
- Zsh config with aliases
- Karabiner Elements key mappings
- Ghostty terminal settings

### Custom Setup
- "Open in Neovim" app for file associations
- File type associations for code files
- GitHub authentication via `gh` CLI (auto-generates SSH keys)

## Manual Setup (Already Cloned)

If you've already cloned the repo:

```bash
cd ~/.dotfiles
./install.sh
```

The installer will prompt you for each section (Homebrew, packages, etc.) - you can skip sections you don't need.

## Managing Dotfiles

Dotfiles are organized into separate packages that can be independently stowed/unstowed.

### Available Packages
- `zsh` - Shell configuration (`.zshrc.shared`, `.aliases`)
- `p10k` - Powerlevel10k theme configuration
- `nvim` - Neovim configuration
- `tmux` - Tmux configuration
- `ghostty` - Ghostty terminal configuration
- `karabiner` - Karabiner Elements key mappings
- `bin` - Custom scripts in `.local/bin`

### Stow your configs

Stow default packages (zsh, nvim, tmux, bin):
```bash
./scripts/stow.sh
```

Stow specific packages:
```bash
./scripts/stow.sh nvim tmux    # Only stow nvim and tmux
```

Stow all available packages:
```bash
./scripts/stow.sh --all
```

List available packages:
```bash
./scripts/stow.sh --list
```

### Unstow your configs
```bash
./scripts/unstow.sh
```

### Per-Machine Setup for .zshrc

The stow process creates `~/.zshrc.shared` with your shared configuration. On each machine, create a local `~/.zshrc` that sources it:

```bash
# ~/.zshrc - Machine-specific configuration
# Add any machine-specific environment variables, paths, or settings here
export SOME_MACHINE_SPECIFIC_VAR="value"

# Source shared dotfiles configuration
[ -f ~/.zshrc.shared ] && source ~/.zshrc.shared
```

This approach allows each machine to have its own customizations while sharing common configuration.

### Update packages list
Edit `scripts/packages.sh` to add/remove:
- `brew_apps` - GUI applications
- `brew_packages` - CLI tools
- `mas_apps` - Mac App Store apps

### Add new dotfiles
1. Add files to the appropriate package directory (e.g., `zsh/`, `nvim/`, etc.)
2. Run `./scripts/stow.sh <package>` to create symlinks

## Scripts

- `bootstrap.sh` - Initial setup on a fresh Mac
- `install.sh` - Main installation script
- `scripts/stow.sh` - Symlink dotfiles to home directory
- `scripts/unstow.sh` - Remove dotfile symlinks
- `scripts/create-neovim-app.sh` - Create "Open in Neovim" app
- `scripts/reset-xcode-file-associations.sh` - Set file type associations

## Credits

Inspired by:
- <https://github.com/Stratus3D/dotfiles>
- <https://github.com/protiumx/.dotfiles>
- <https://github.com/joshukraine/dotfiles>
- <https://github.com/anishathalye/dotbot>
