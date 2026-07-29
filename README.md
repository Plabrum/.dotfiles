# .dotfiles

Personal development environment setup and configuration. macOS is the primary
target; Linux (Debian/Ubuntu, RedHat/Fedora) is supported for the CLI half.

## Quick Setup (New Machine)

On a fresh machine, run this single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/plabrum/.dotfiles/main/bootstrap.sh)
```

This will:
1. Install Xcode Command Line Tools (macOS) or build prerequisites (Linux)
2. Clone this repository to `~/.dotfiles`
3. Run the full installation process

### Install profiles

`install.sh` asks for a profile, or takes `INSTALL_PROFILE` non-interactively:

- **minimal** (default) — CLI-only dev environment. All platforms.
- **full** — adds GUI apps, Mac App Store apps, Neovim.app and file
  associations. macOS only; the GUI steps skip themselves on Linux.

```bash
INSTALL_PROFILE=minimal ./install.sh   # no prompt
```

The profile also decides how much gets stowed: **full** on macOS stows *every*
package, anything else stows only `DEFAULT_PACKAGES` (see below).

Note that steps do **not** prompt individually — once started, `install.sh` runs
every step for the chosen profile in order (Homebrew, packages, oh-my-zsh, stow,
shell setup, `gh auth login`). The only questions asked are the profile itself,
stow's conflict prompt, `sudo`, and whatever `gh auth login` needs. To run just
part of it, call the pieces directly — see "Syncing an existing machine".

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

### Fonts
- BlexMono Nerd Font (IBM Plex Mono, patched) — a Homebrew cask on macOS, and
  fetched from the Nerd Fonts release into `~/.local/share/fonts` on Linux

### Applications (`full` profile, macOS)
- Docker, Ghostty
- 1Password, Magnet
- Alfred, Karabiner Elements
- Slack, ChatGPT
- And more (see `scripts/packages.sh`)

### Configurations
- Neovim config (with LSP, formatters, linters) — plus a separate LazyVim config
- Tmux config
- Zsh config with aliases (plus p10k prompt)
- lazygit config (branch prefix, Graphite custom commands)
- Karabiner Elements key mappings
- Ghostty terminal settings

### Custom Setup
- Machine-local `~/.zshrc` / `~/.aliases` wired to the shared config
- zsh set as the login shell
- "Open in Neovim" app for file associations (macOS)
- File type associations for code files (macOS)
- GitHub authentication via `gh` CLI (auto-generates SSH keys)

## Manual Setup (Already Cloned)

If you've already cloned the repo:

```bash
cd ~/.dotfiles
./install.sh
```

The installer asks for a profile, then runs every step for it start to finish —
it does *not* offer a yes/no per section.

## Syncing an existing machine

To pull config changes without re-running the installers:

```bash
cd ~/.dotfiles && git pull
./scripts/stow.sh --all                 # or omit --all for DEFAULT_PACKAGES
```

If the changes touched shell bootstrapping or the login shell, run those two
steps on their own instead of the whole installer:

```bash
bash -c 'source scripts/utils.sh && source scripts/terminal.sh &&
         ensure_shell_bootstrap && ensure_default_shell'
```

Then start a new login shell (`exec zsh -l`) to pick everything up.

## Managing Dotfiles

Dotfiles are organized into separate packages that can be independently stowed/unstowed.

### Available Packages
- `zsh` - Shell configuration (`.zshrc.shared`, `.aliases.shared`)
- `p10k` - Powerlevel10k theme configuration
- `nvim` - Neovim configuration (the hand-rolled "slim" config; plain `nvim`)
- `nvim-lazyvim` - LazyVim configuration (`nviml`, via `NVIM_APPNAME`)
- `tmux` - Tmux configuration
- `ghostty` - Ghostty terminal configuration
- `karabiner` - Karabiner Elements key mappings
- `lazygit` - lazygit config (branch prefix, Graphite custom commands)
- `claude` - Claude Code skills
- `bin` - Custom scripts in `.local/bin`

Packages in `DEFAULT_PACKAGES` (stowed when no arguments are given): `zsh`,
`p10k`, `nvim`, `tmux`, `bin`, `claude`, `lazygit`. The rest — `nvim-lazyvim`,
`ghostty`, `karabiner` — need `--all` or an explicit name, so a Linux or minimal
install doesn't get macOS-only GUI configs.

### Stow your configs

Stow default packages:
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

### Re-syncing after changes

`scripts/stow.sh` uses `stow -R` (restow), so it's idempotent — re-run it any
time to sync:

```bash
./scripts/stow.sh --all
```

Most packages are stowed as a *single directory symlink* (`~/.config/nvim`,
`~/.config/tmux`, `~/.config/lazygit`, …), so **editing or adding files inside
them needs no restow** — the changes are live immediately.

The exception is `bin`: `~/.local/bin` already exists as a real directory, so
stow links each file individually. **Adding a new script to `bin/` requires
`./scripts/stow.sh bin`** or it won't appear on your PATH. Restowing also clears
symlinks left behind by deleted files.

### Per-Machine Setup for .zshrc

`~/.zshrc` and `~/.aliases` are deliberately **not** stowed — they're
machine-local (PATH entries, per-box env) and each sources its shared half from
this repo. `install.sh` wires this up for you (`ensure_shell_bootstrap`):
creating them if missing, appending the source line if the file exists without
it, and doing nothing if it's already there.

To do it by hand:

```bash
# ~/.zshrc - Machine-specific configuration
export SOME_MACHINE_SPECIFIC_VAR="value"

# Source shared dotfiles configuration
[ -f ~/.zshrc.shared ] && source ~/.zshrc.shared
```

```bash
# ~/.aliases - Machine-specific aliases

# Source shared aliases
[ -f ~/.aliases.shared ] && source ~/.aliases.shared
```

Without these, the stowed files exist but are never loaded — no p10k theme, no
aliases, no `LG_CONFIG_FILE`.

### Update packages list
Edit `scripts/packages.sh` to add/remove:
- `brew_packages_minimal` - CLI tools, every platform and profile
- `brew_fonts_macos` - Nerd Font casks (macOS; Linux fetches the font from the
  Nerd Fonts release instead — casks don't exist on Homebrew for Linux)
- `brew_packages_macos_full` - macOS-only CLI tools, `full` profile
- `brew_apps_full` - GUI applications (Homebrew Casks), `full` profile
- `mas_apps_full` - Mac App Store apps, `full` profile

### Add new dotfiles
1. Add files to the appropriate package directory (e.g., `zsh/`, `nvim/`, etc.)
2. Run `./scripts/stow.sh <package>` to create symlinks

## Linux / server notes

The `minimal` profile is the intended path on a Linux box:

```bash
cd ~/.dotfiles && INSTALL_PROFILE=minimal ./install.sh
```

- **zsh** comes from the native package manager (`apt`/`dnf`), not Homebrew, so
  login features aren't broken. It's installed with the build prerequisites in
  step 1. Homebrew still gets installed (to `/home/linuxbrew`) for everything
  else, and needs `sudo`.
- **Login shell**: oh-my-zsh's installer runs `chsh` itself, and step 6c
  (`ensure_default_shell`) covers the case where oh-my-zsh is skipped because
  `~/.zshrc` already exists. Takes effect on next login.
- **GUI steps** (casks, Mac App Store, Neovim.app, Karabiner) skip themselves.
- **Nerd Font**: on Linux the font is fetched from the Nerd Fonts release into
  `~/.local/share/fonts`, and skipped entirely if `fontconfig` is absent — over
  SSH the font that matters is your *client's*, not the server's.
- **Neovim + tree-sitter** come from GitHub releases into `~/.local/bin`, not the
  package manager: the slim config needs Neovim >= 0.12 (`vim.pack`), which
  distros don't ship yet, and nvim-treesitter's `main` branch shells out to the
  `tree-sitter` CLI to build parsers. Both steps resolve the newest release each
  run, so re-running them is also the upgrade path.
- **Physical console**: on tty1 (`TERM=linux`) the kernel renders a PSF font,
  which is capped at 512 glyphs, so none of the prompt's glyphs exist there —
  not the Nerd Font icons, and not `❯ ✔ ✘ …` either. `.zshrc.shared` skips
  powerlevel10k entirely in that case and uses a plain ASCII prompt. SSH
  sessions are unaffected, since `TERM` then comes from the client.

### First Neovim launch

The first `nvim` start installs every plugin and builds parsers, which prints
enough messages to trigger a hit-enter prompt after each one. Do it headlessly
instead:

```bash
nvim --headless -c 'qa'     # installs plugins; repeat once for parsers
```

If parsers still fail with `ENOENT ... 'tree-sitter'`, the CLI is missing —
`tree-sitter --version` should work, and `~/.local/bin` must be on PATH.

## Scripts

- `bootstrap.sh` - Initial setup on a fresh machine (installs prereqs, clones, installs)
- `install.sh` - Main installation script; orchestrates the steps below
- `scripts/packages.sh` - Package lists (see "Update packages list")
- `scripts/terminal.sh` - Homebrew, oh-my-zsh, fonts, shell bootstrap, login shell
- `scripts/linux-prerequisites.sh` - Build tools + zsh via apt/dnf/yum
- `scripts/stow.sh` - Symlink dotfiles to home directory
- `scripts/unstow.sh` - Remove dotfile symlinks
- `scripts/create-neovim-app.sh` - Create "Open in Neovim" app (macOS)
- `scripts/reset-xcode-file-associations.sh` - Set file type associations (macOS)

## Credits

Inspired by:
- <https://github.com/Stratus3D/dotfiles>
- <https://github.com/protiumx/.dotfiles>
- <https://github.com/joshukraine/dotfiles>
- <https://github.com/anishathalye/dotbot>
