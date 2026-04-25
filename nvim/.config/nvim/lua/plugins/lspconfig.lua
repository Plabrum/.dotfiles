-- Show linters for the current buffer's file type
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.typescript = {
        "prettierd",
        "prettier",
        stop_after_first = true,
      }
      opts.formatters_by_ft.typescriptreact = {
        "prettierd",
        "prettier",
        stop_after_first = true,
      }
      opts.formatters_by_ft.swift = { "swiftformat" }
      opts.formatters_by_ft.python = { "ruff_format", "ruff_organize_imports" }

      return opts
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = {
          "ruff",
          -- "dmypy"
        },
        swift = { "swiftlint" },
        markdown = {},
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = false },
      -- codelens = {
      --   enabled = true,
      -- },
      diagnostics = {
        --   virtual_lines = {
        --     current_line = true,
        --   },
        virtual_text = {
          current_line = false,
        },
      },
      servers = {
        basedpyright = {},
        ruff = { enabled = true },
      },
    },
  },
}
