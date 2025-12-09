return {
  "folke/flash.nvim",
  opts = {
    modes = {
      treesitter = {
        actions = {
          ["<c-space>"] = "next",
          ["<BS>"] = "prev",
        },
        labels = "",
        label = { after = false, before = false },
      },
    },
  },
}
