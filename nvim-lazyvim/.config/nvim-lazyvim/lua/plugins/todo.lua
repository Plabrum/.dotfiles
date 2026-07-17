return {
  -- TODO PAL:
  {
    "folke/todo-comments.nvim",
    optional = true,
  -- stylua: ignore
  keys = {
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
    { "<leader>sT", function () Snacks.picker.todo_comments({ keywords = { "PAL_TODO" } }) end, desc = "Todo/Fix/Fixme" },
  },
    opts = {
      keywords = {
        PAL_TODO = { icon = "", color = "warning", alt = { "TODO PAL" } },
      },
    },
  },
}
