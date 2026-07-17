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

function M.finalize()
  require("conform").setup({
    notify_on_error = false,
    default_format_opts = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },
    format_on_save = {},
    formatters_by_ft = M.formatters_by_ft,
  })
end

return M
