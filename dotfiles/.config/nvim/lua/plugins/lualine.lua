return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local icons = LazyVim.config.icons
      local tmux_status = require("tmux-status")
      -- tmux_status.setup({
      -- TmuxStatusComponentColors
      -- window_active string
      -- window_inactive string
      -- window_inactive_recent string
      -- session string
      -- datetime string
      -- battery string
      -- })

      local tmux_window = {
        tmux_status.tmux_windows,
        cond = require("tmux-status").show,
        padding = { left = 2, right = 1 },
        -- separator = "|",
      }
      local tmux_session = {
        tmux_status.tmux_session,
        cond = require("tmux-status").show,
        padding = { left = 1, right = 1 },
      }

      opts.section_separators = { left = "}", right = "" }
      opts.compomenent_separators = { left = "}", right = "" }
      opts.sections.lualine_b = {
        tmux_session,
        tmux_window,
        -- { separator = { right = " ", left = " " } },
        seperator = nil,
      }

      opts.sections.lualine_c = {
        -- LazyVim.lualine.root_dir(),
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
        -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        -- { LazyVim.lualine.pretty_path({ length = 4 }) },
      }
    end,
  },
}
