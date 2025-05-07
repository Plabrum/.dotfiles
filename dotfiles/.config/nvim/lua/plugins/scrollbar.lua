-- if true then
--   return {}
-- end
return {
  -- {
  --   "lewis6991/gitsigns.nvim",
  -- config = function()
  --   require("gitsigns").setup()
  -- end,
  -- },
  {
    "kevinhwang91/nvim-hlslens",
    config = function(_, opts)
      require("scrollbar.handlers.search").setup(opts)
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    dependencies = { "lewis6991/gitsigns.nvim", "kevinhwang91/nvim-hlslens" },
    event = "VeryLazy",
    opts = {
      handlers = {
        -- gitsigns = true,
        search = true,
      },
    },
    -- config = function(_, opts)
    --   require("scrollbar.handlers.gitsigns").setup()
    -- end,
  },
}
