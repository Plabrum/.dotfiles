if true then
  return {}
end
return {
  "quarto-dev/quarto-nvim",
  ft = { "quarto", "markdown" },
  dependencies = {
    "jmbuhr/otter.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    codeRunner = {
      enabled = true,
      default_method = "molten",
    },
    lspFeatures = {
      -- NOTE: put whatever languages you want here:
      languages = { "r", "python", "rust" },
      chunks = "all",
      diagnostics = {
        enabled = true,
        triggers = { "BufWritePost" },
      },
      completion = {
        enabled = true,
      },
    },
    keymap = {
      -- NOTE: setup your own keymaps:
      hover = "H",
      definition = "gd",
      rename = "<leader>rn",
      references = "gr",
      format = "<leader>gf",
      runner = function()
        local runner = require("quarto.runner")
        vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
        vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
        vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
        vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
        vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
        vim.keymap.set("n", "<localleader>RA", function()
          runner.run_all(true)
        end, { desc = "run all cells of all languages", silent = true })
      end,
    },
  },
}
