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

    return opts
  end,
}
