return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      themes = "wave",
      -- transparent = true,
    },
  },
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "classic",
      colorscheme = "classic",
      filter = "classic",
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      -- transparent = true,
      -- styles = {
      -- sidebars = "transparent",
      -- floats = "transparent",
      -- },
    },
  },
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = {} },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "monokai-pro",
      colorscheme = "tokyonight-moon",
    },
  },
}
