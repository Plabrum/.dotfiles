return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local hide_in_explorer = function()
      return vim.bo.filetype ~= "snacks_picker_list"
    end
    local winbar_config = {
      lualine_c = {
        {
          "filetype",
          icon_only = true,
          separator = "",
          padding = { left = 3, right = 1 },
          color = { bg = "none" },
        },

        {
          LazyVim.lualine.pretty_path({ length = 5 }),
          color = { bg = "none", gui = "bold" },
          cond = hide_in_explorer,
        },
      },
    }

    opts.options.disabled_filetypes =
      { winbar = { "dashboard", "alpha", "ministarter", "snacks_dashboard", "snacks_explorer" } }

    opts.winbar = winbar_config
    opts.inactive_winbar = winbar_config
  end,
}
