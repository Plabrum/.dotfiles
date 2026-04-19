return {
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

    -- Python: match pre-commit configuration
    opts.formatters_by_ft.python = { "ruff_fix", "ruff_format" }

    -- Configure ruff_fix to match pre-commit rules (not --select ALL)
    opts.formatters = opts.formatters or {}
    opts.formatters.ruff_fix = {
      -- Override LazyVim's default --select ALL
      -- Use rules from pyproject.toml: E, W, F, I, N, UP
      args = {
        "check",
        "--fix",
        "--force-exclude",
        "--stdin-filename",
        "$FILENAME",
      },
    }

    return opts
  end,
}
