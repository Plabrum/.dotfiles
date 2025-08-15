-- Show linters for the current buffer's file type
return {
  { "dmmulroy/ts-error-translator.nvim", opts = {} },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Extend or initialize the events
      opts.events = opts.events or {}
      vim.list_extend(opts.events, { "BufWritePost", "BufReadPost", "InsertLeave" })

      -- Extend or initialize linters_by_ft
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.python = { "flake8", "dmypy" }
      opts.linters_by_ft.markdown = {}

      -- Extend or initialize linters
      opts.linters = opts.linters or {}
      opts.linters.sqlfluff = {
        args = {
          "lint",
          "--format=json",
          "--dialect=postgres",
        },
      }

      return opts
    end,
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
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                -- autoImportCompletions = true,
                -- useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                -- diagnosticMode = "workspace",
                -- importStrategy = "useBundled",
              },
              -- disableLanguageServices = false,
            },
          },
          -- on_attach = function(client)
          --   client.config.settings.basedpyright.disableLanguageServices = false
          --   client.notify("workspace/didChangeConfiguration")
          -- end,
        },
        ruff = { enabled = false },
      },
    },
  },
  -- {
  --   "neovim/nvim-lspconfig",
  --   ---@class PluginLspOpts
  --   opts = {
  --     inlay_hints = { enabled = false },
  --     diagnostics = {
  --       virtual_text = {
  --         current_line = false,
  --       },
  --     },
  --     servers = {
  --       basedpyright = {
  --         settings = {
  --           basedpyright = {
  --             analysis = {
  --               typeCheckingMode = "basic",
  --               autoSearchPaths = true,
  --               diagnosticMode = "wodkspace",
  --               autoImportCompletions = true,
  --             },
  --           },
  --           on_attach = function(client, bufnr)
  --             -- after a short warmup, switch to openFilesOnly to avoid heavy reindexing on each save
  --             vim.defer_fn(function()
  --               local new = {
  --                 basedpyright = { analysis = { diagnosticMode = "openFilesOnly" } },
  --               }
  --               client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, new)
  --               client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  --             end, 4000) -- tweak delay if needed
  --           end,
  --         },
  --       },
  --       -- on_attach = function(client)
  --       --   client.config.settings.basedpyright.disableLanguageServices = false
  --       --   client.notify("workspace/didChangeConfiguration")
  --       -- end,
  --     },
  --     ruff = { enabled = false },
  --   },
  -- },
}
