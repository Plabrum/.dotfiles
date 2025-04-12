-- Show linters for the current buffer's file type
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        python = { "flake8", "dmypy" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        -- Define your formatters
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black", "autoflake" },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        },

        format_on_save = {
          -- I recommend these options. See :help conform.format for details.
          lsp_format = "fallback",
          timeout_ms = 500,
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = false },
      codelens = {
        enabled = true,
      },
      diagnostics = {
        virtual_text = {
          current_line = true,
        },
      },
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                importStrategy = "useBundled",
              },
              disableLanguageServices = false,
            },
          },
          on_attach = function(client)
            client.config.settings.basedpyright.disableLanguageServices = false
            client.notify("workspace/didChangeConfiguration")
          end,
        },
        ruff = { enabled = false },
      },
    },
  },
}
