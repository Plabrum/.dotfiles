-- from https://github.com/linkarzu/dotfiles-latest/blob/6047da942948e93faf1cbc856ab5a262c4207997/neovim/neobean/lua/plugins/snacks.lua
return {
  "folke/snacks.nvim",
  keys = {
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
