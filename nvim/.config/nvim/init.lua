-- nvim-slim: hand-rolled, minimal config. No plugin manager beyond
-- Neovim's built-in `vim.pack` (:help vim.pack). No distro, no framework.
-- Launch with: NVIM_APPNAME=nvim-slim nvim
--
-- Goal: every plugin here is one you deliberately chose, not one that came
-- bundled. Add things only when you miss them.
--
-- Structure:
--
-- ├ init.lua              This file: decides *when* each module loads.
-- ├ lua/config/
-- ├── util.lua            Shared helpers (no plugin deps; loaded first).
-- ├── options.lua         Built-in Neovim behaviour.
-- ├── keymaps.lua         Core mappings + tmux navigation + mini.clue.
-- ├── session.lua         persistence.nvim.
-- ├── ui.lua              Icons, colorscheme, tabline, winbar, dashboard, messages.
-- ├── editing.lua         Textobjects, surround, comments, pairs, yank, dial.
-- ├── nav.lua             Picker, explorer, harpoon, flash.
-- ├── git.lua             mini.diff, mini.git, lazygit.
-- ├── orgmode.lua         nvim-orgmode (loaded lazily on the `org` filetype).
-- ├── lsp.lua             Servers, diagnostics, LSP mappings. Base servers only --
-- │                       exports `M.servers`/`M.mason_tools` for `lang.*` to add to,
-- │                       and `M.finalize()` to install/enable them all.
-- ├── completion.lua      mini.completion + mini.keymap.
-- ├── format.lua          conform.nvim. Base formatters only -- exports
-- │                       `M.formatters_by_ft` for `lang.*` to add to, and
-- │                       `M.finalize()` to apply the full table.
-- ├── treesitter.lua      Base parsers + attach autocmd.
-- ├── retrain.lua         Temporary LazyVim compat shims (delete when ready).
-- ├ lua/lang/
-- ├── go.lua              gopls, goimports/gofumpt, golangci-lint (nvim-lint).
-- ├── ocaml.lua           ocamllsp + ocamlformat, both via `opam exec`.
-- ├── python.lua          basedpyright.
-- ├── rust.lua            rustaceanvim (rust-analyzer), crates.nvim.
-- ├── typescript.lua      ts_ls.
--
-- Each `config.*` module is self-contained: it adds its own plugins with
-- `vim.pack.add()`, configures them, and defines their mappings. To find where
-- something is set, find the module that owns the feature -- all the git config
-- is in git.lua, all the LSP config is in lsp.lua, and so on.
--
-- `lang.*` modules are per-language instead: each one registers its server,
-- formatter, parsers and any extra tooling onto the `config.*` modules above.
-- They load after `config.lsp`/`config.format`/`config.treesitter`, and before
-- `config.lsp`/`config.format`'s `finalize()` calls -- see the load order below.

if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({
    { "nvim-slim requires Neovim >= 0.12 (needs vim.pack). ", "ErrorMsg" },
    { "You have " .. tostring(vim.version()), "ErrorMsg" },
  }, true, {})
  return
end

-- `config.util` is pure Lua with no plugin dependencies, so it can be required
-- before anything is installed.
local util = require("config.util")

-- 'mini.nvim' is the one dependency added here rather than in a module: it
-- powers several of them (icons, starter, files, clue, surround, notify, ...),
-- and `mini.misc` provides the loading helper used just below.
vim.pack.add({ util.gh("nvim-mini/mini.nvim") })

-- `MiniMisc.safely(when, f)` runs `f` at `when` and turns any error into a
-- `vim.notify()` warning instead of aborting the rest of the config -- so one
-- broken module degrades to a warning rather than an unusable editor.
--
-- `when` accepts 'now', 'later', 'delay:<ms>', 'event:<events>' and
-- 'filetype:<fts>'. See `:h MiniMisc.safely()`.
local safely = require("mini.misc").safely

---@param when string see `:h MiniMisc.safely()`
---@param module string module name under `lua/`
local function load(when, module)
  safely(when, function()
    require(module)
  end)
end

-- Language tooling only matters once a file is actually open, and it's the
-- expensive part of startup. Load it immediately when Neovim was given a file
-- (`nvim foo.lua`), and defer it when we're landing on the dashboard instead.
local if_args = vim.fn.argc(-1) > 0 and "now" or "later"

-- Order matters in three places, noted below. Everything else is independent,
-- and `now` keeps it predictable.
load("now", "config.options") -- must precede any `<leader>` mapping: sets mapleader
load("now", "config.keymaps")
load("now", "config.session") -- must precede ui: the dashboard lists its sessions
load("now", "config.ui") -- must precede nav: sets up mini.icons for the picker
load("now", "config.editing")
load("now", "config.nav")
load("now", "config.git")
load("now", "config.retrain")

-- Filetype-scoped: nothing here matters until an `.org` file is opened.
load("filetype:org", "config.orgmode")

load(if_args, "config.lsp")
load(if_args, "config.completion")
load(if_args, "config.format")
load(if_args, "config.treesitter")

load(if_args, "lang.go")
load(if_args, "lang.ocaml")
load(if_args, "lang.python")
load(if_args, "lang.rust")
load(if_args, "lang.typescript")

-- `lang.*` modules only register themselves onto `config.lsp`/`config.format`;
-- this actually installs and enables everything they registered.
safely(if_args, function()
  require("config.lsp").finalize()
  require("config.format").finalize()
end)
