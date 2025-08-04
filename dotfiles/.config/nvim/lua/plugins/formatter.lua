return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    opts.formatters_by_ft.lua = { "stylua" }
    opts.formatters_by_ft.python = { "autoflake", "isort", "black" }
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

    -- Formatter overrides
    opts.formatters = opts.formatters or {}

    -- Get virtualenv black path if active
    -- local venv = os.getenv("VIRTUAL_ENV")
    -- local black_path = venv and (venv .. "/bin/black") or "black"
    --
    opts.formatters.black = {
      -- command = black_path,
      prepend_args = { "--line-length", "80" },
    }

    opts.formatters.isort = {
      prepend_args = { "--profile", "black", "--line-length", "80" },
    }

    opts.formatters.autoflake = {
      prepend_args = {
        "--in-place",
        "--expand-star-imports",
        "--remove-all-unused-imports",
      },
    }

    return opts
  end,
}
