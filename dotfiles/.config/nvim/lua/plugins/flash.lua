return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    -- { "s", mode = { "n", "x", "o" }, false },
    -- {
    --   "<cr>",
    --   mode = { "n", "x", "o" },
    --   function()
    --     -- Don't activate Flash in quickfix buffers
    --     if vim.bo.buftype == "quickfix" then
    --       return "<cr>"
    --     elseif vim.bo.buftype == "org-roam-node-buffer" then
    --       return "<cr>"
    --     end
    --     require("flash").jump()
    --   end,
    --   desc = "Flash",
    -- },
  },
}
