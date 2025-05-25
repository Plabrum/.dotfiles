--Options automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- In init.lua
-- if vim.env.VSCODE then
--   vim.g.vscode = true
-- end

-- if vim.g.vscode then
--   local opts = { noremap = true, silent = true }
--   vim.keymap.set("n", "gr", function()
--     vim.lsp.buf.references()
--   end, opts)
-- end
--
vim.g.lazyvim_python_lsp = "basedpyright"
-- vim.g.python3_host_prog = vim.fn.exepath("python3") -- This finds Python in your PATH
vim.g.python3_host_prog = "~/.pyenv/versions/neovim/bin/python3"
-- vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/default/bin/python3")
vim.g.lazyvim_prettier_needs_config = true
vim.opt.wrap = true
-- vim.g.snacks_animate = false
-- vim.g.ai_cmp = true

-- Configure cursor appearance and blinking for different modes
vim.opt.guicursor = {
  "n-v-c:block-Cursor/lCursor-blinkwait300-blinkon100-blinkoff100",
  "i-ci:ver25-Cursor/lCursor-blinkwait300-blinkon100-blinkoff100",
  "r-cr:hor20-Cursor/lCursor-blinkwait300-blinkon100-blinkoff100",
}
