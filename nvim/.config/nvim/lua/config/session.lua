-- Sessions (persistence.nvim).
--
-- Loaded before `config.ui`: the dashboard's Sessions section is generated from
-- persistence's session list, so the plugin must be on the runtimepath by the
-- time mini.starter builds its items.

local util = require("config.util")

vim.pack.add({ util.gh("folke/persistence.nvim") })
require("persistence").setup({})

vim.keymap.set("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Restore Session" })
vim.keymap.set("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Restore Last Session" })
vim.keymap.set("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Don't Save Current Session" })
