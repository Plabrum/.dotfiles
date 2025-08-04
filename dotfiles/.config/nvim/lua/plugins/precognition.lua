return {
  "tris203/precognition.nvim",
  -- config = function(_, opts)
  --   local precognition = require("precognition")
  --
  --   local enabled = false
  --
  --   Snacks.toggle({
  --     name = "Precognition",
  --     get = function()
  --       return enabled
  --     end,
  --
  --     set = function(state)
  --       enabled = state
  --       precognition.toggle()
  --     end,
  --   }):map("<leader>uP")
  -- end,
  opts = { startVisible = false },
}
