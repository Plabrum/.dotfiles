return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-python",
    },
    opts = function(_, opts)
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.ts",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        })
      )
      table.insert(
        opts.adapters,
        require("neotest-python")({
          dap = { justMyCode = false },
          root_files = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" },
          runner = "pytest",
          cwd = function()
            return vim.fn.getcwd()
          end,
        })
      )
    end,
  },
}
