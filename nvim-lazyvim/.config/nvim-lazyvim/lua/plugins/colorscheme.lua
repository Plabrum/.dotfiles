return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      themes = "wave",
      -- transparent = true,
    },
  },
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = "#928374" })
  --     vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#928374" })
  --   end,
  --   opts = {
  --     theme = "classic",
  --     colorscheme = "classic",
  --     filter = "classic",
  --   },
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      -- transparent = true,
      -- styles = {
      --   sidebars = "transparent",
      --   floats = "transparent",
      -- },
    },
  },
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = {} },

  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.sonokai_enable_italic = false
      vim.cmd.colorscheme("sonokai")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "monokai-pro-classic",
      -- colorscheme = "tokyonight",
      -- colorscheme = "catppuccin-frappe",
      colorscheme = "sonokai",
    },
  },
}
