-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Lua

-- vim.keymap.set("i", "<M-h>", "<C-o>^", { desc = "Move to beginning of line" })
-- vim.keymap.set("i", "<M-l>", "<C-o>$", { desc = "Move to end of line" })
local map = vim.keymap.set
map("n", "H", "^", { desc = "Move to beginning of line" })
map("n", "L", "$", { desc = "Move to end of line" })

map("i", "jj", "<Esc>", { noremap = false })
map("i", "jk", "<Esc>", { noremap = false })

-- vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
-- vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = false }
