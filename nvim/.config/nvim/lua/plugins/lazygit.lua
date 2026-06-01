local function tmux_pane(dir)
  return function()
    vim.fn.system({ "tmux", "select-pane", "-" .. dir })
  end
end

return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      win = {
        position = "float",
        width = 0,
        height = 0,
        backdrop = false,
        border = "none",
        keys = {
          nav_h = { "<C-h>", tmux_pane("L"), mode = { "n", "t", "i" }, desc = "tmux pane left" },
          nav_j = { "<C-j>", tmux_pane("D"), mode = { "n", "t", "i" }, desc = "tmux pane down" },
          nav_k = { "<C-k>", tmux_pane("U"), mode = { "n", "t", "i" }, desc = "tmux pane up" },
          nav_l = { "<C-l>", tmux_pane("R"), mode = { "n", "t", "i" }, desc = "tmux pane right" },
        },
      },
    },
  },
}
