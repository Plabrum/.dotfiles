-- Helper function to find git root for monorepo support
local function get_git_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and git_root then
    return git_root
  end
  return vim.fn.getcwd()
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        grep = {
          fuzzy = true,
          -- matcher = {},
        },
        files = {
          -- hidden = true,
          -- ignored = true,
          follow = true,
        },
        explorer = {
          hidden = true,
        },
      },
      win = {
        input = {
          keys = {
            ["J"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["K"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["H"] = { "preview_scroll_left", mode = { "i", "n" } },
            ["L"] = { "preview_scroll_right", mode = { "i", "n" } },
          },
        },
      },
      formatters = {
        file = { truncate = 80 },
      },
    },
  },

  -- from https://github.com/linkarzu/dotfiles-latest/blob/6047da942948e93faf1cbc856ab5a262c4207997/neovim/neobean/lua/plugins/snacks.lua
  keys = {
    -- Override default LazyVim file picker to use git root
    {
      "<leader><space>",
      function()
        Snacks.picker.files({ cwd = get_git_root() })
      end,
      desc = "Find Files (Git Root)",
    },
    -- Override grep to use git root
    {
      "<leader>/",
      function()
        Snacks.picker.grep({ cwd = get_git_root() })
      end,
      desc = "Grep (Git Root)",
    },
    {
      "<leader>,",
      function()
        Snacks.picker.buffers({
          -- I always want my buffers picker to start in normal mode
          -- on_show = function()
          --   vim.cmd.stopinsert()
          -- end,
          finder = "buffers",
          format = "buffer",
          hidden = false,
          unloaded = true,
          current = true,
          sort_lastused = true,
          win = {
            input = {
              keys = {
                ["d"] = "bufdelete",
              },
            },
            list = { keys = { ["d"] = "bufdelete" } },
          },
        })
      end,
      desc = "[P]Snacks picker buffers",
    },
  },
}
