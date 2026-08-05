-- Formatting (conform.nvim).
--
-- `lsp_format = "fallback"` means: use the dedicated formatter listed below if
-- there is one, otherwise ask the language server to format.

local util = require("config.util")

vim.pack.add({ util.gh("stevearc/conform.nvim") })

-- Base formatters live here; `lang.*` modules add their own entries to
-- `M.formatters_by_ft`, and `M.finalize()` (called once from `init.lua`, after
-- all `lang.*` modules have loaded) applies the full table to conform.

local M = {}

---@type table<string, string[]>
M.formatters_by_ft = {
  lua = { "stylua" },
}

-- Overrides for individual formatters, merged over conform's built-in recipes
-- (`:h conform-formatters`). Only needed when the default recipe doesn't fit --
-- e.g. a binary that has to be invoked through a toolchain wrapper rather than
-- found on `$PATH`. `lang.*` modules add their own entries.
---@type table<string, conform.FormatterConfigOverride>
M.formatters = {}

function M.finalize()
  require("conform").setup({
    notify_on_error = false,
    default_format_opts = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },
    format_on_save = {},
    formatters_by_ft = M.formatters_by_ft,
    formatters = M.formatters,
  })
end

return M
