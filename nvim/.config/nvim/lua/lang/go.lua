-- Go: gopls (with LazyVim-equivalent analyses/hints), goimports/gofumpt
-- formatting, golangci-lint diagnostics via nvim-lint.
--
-- Loaded after `config.lsp`/`config.format`/`config.treesitter`, before their
-- `finalize()` calls -- see `init.lua`. This module only registers itself onto
-- their tables; it doesn't install or enable anything by itself.

local util = require("config.util")
local lsp = require("config.lsp")
local format = require("config.format")

require("nvim-treesitter").install({ "go", "gomod", "gowork", "gosum" })

lsp.servers.gopls = {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}

format.formatters_by_ft.go = { "goimports", "gofumpt" }
vim.list_extend(lsp.mason_tools, { "goimports", "gofumpt", "golangci-lint" })

-- gopls doesn't run golangci-lint itself; nvim-lint runs it out-of-process and
-- reports through the same `vim.diagnostic` UI as the LSP.
vim.pack.add({ util.gh("mfussenegger/nvim-lint") })
local lint = require("lint")
lint.linters_by_ft = lint.linters_by_ft or {}
lint.linters_by_ft.go = { "golangcilint" }

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("slim-lang-go-lint", { clear = true }),
  pattern = "*.go",
  callback = function()
    lint.try_lint()
  end,
})
