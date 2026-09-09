-- Python: basedpyright for types, ruff for formatting/imports. See `lang/go.lua`
-- for how this plugs into `config.lsp`/`config.format`/`config.treesitter`.

local lsp = require("config.lsp")
local format = require("config.format")

require("nvim-treesitter").install({ "python" })

-- basedpyright is a type checker and serves no document formatting, so without
-- a dedicated formatter conform's `lsp_format = "fallback"` had nothing to fall
-- back to and Python never formatted on save. ruff does both jobs: sort imports,
-- then format -- the same pair LazyVim's python extra registers. mason installs
-- the `ruff` binary (see `lsp.finalize()`); conform's built-in recipes find it.
format.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
vim.list_extend(lsp.mason_tools, { "ruff" })

-- basedpyright re-analyzes on nearly every change and reports it as work-done
-- progress, which mini.notify's `lsp_progress` turns into a stream of
-- `basedpyright: (100%)` toasts (see `config.ui`). Advertising that this client
-- doesn't handle work-done progress makes the server stop emitting `$/progress`
-- at the source -- so basedpyright goes quiet while every other server keeps its
-- progress notifications. Merges over Neovim's default client capabilities.
lsp.servers.basedpyright = {
  capabilities = {
    window = { workDoneProgress = false },
  },
}
