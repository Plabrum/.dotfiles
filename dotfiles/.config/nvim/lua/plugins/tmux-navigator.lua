return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = true,
    keys = {
      { "<c-Left>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-Down>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-Up>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-Right>", "<cmd>TmuxNavigateRight<cr>" },
      { "<c-h>" },
      { "<c-j>" },
      { "<c-k>" },
      { "<c-l>" },
    },
  },
  {
    "christopher-francisco/tmux-status.nvim",
    lazy = true,
    opts = {
      -- force_show = false,
      manage_tmux_status = false,
    },
  },
}
