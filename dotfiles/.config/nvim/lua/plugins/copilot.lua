return {
  -- {
  --   "zbirenbaum/copilot.lua",
  --   optional = true,
  --   opts = function()
  --     require("copilot.api").status = require("copilot.status")
  --   end,
  -- },
  -- {
  --   "saghen/blink.cmp",
  --   opts = {
  --     keymap = {
  --       ["<C-q>"] = { "show", "hide" },
  --       ["<Up>"] = { "select_prev", "fallback" },
  --       ["<Down>"] = { "select_next", "fallback" },
  --       ["<CR>"] = { "accept", "fallback" },
  --       ["<Right>"] = { "accept", "fallback" },
  --       ["<Left>"] = { "hide" },
  --     },
  --   },
  -- },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   build = ":Copilot auth",
  --   event = "BufReadPost",
  --   opts = {
  --     suggestion = {
  --       enabled = not vim.g.ai_cmp,
  --       auto_trigger = true,
  --       hide_during_completion = vim.g.ai_cmp,
  --       keymap = {
  --         accept = false, -- handled by nvim-cmp / blink.cmp
  --         next = "<M-]>",
  --         prev = "<M-[>",
  --       },
  --     },
  --     panel = { enabled = false },
  --     filetypes = {
  --       markdown = true,
  --       help = true,
  --     },
  --   },
  -- },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- dependencies = {
    --   { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
    --   { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    -- },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      -- {
      -- window = {
      --   layout = "float",
      -- },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
