--Options automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- In init.lua
if vim.env.VSCODE then
  vim.g.vscode = true
end
vim.g.lazyvim_python_lsp = "basedpyright"
-- vim.g.python3_host_prog = vim.fn.exepath("python3") -- This finds Python in your PATH
vim.g.python3_host_prog = "~/.pyenv/versions/neovim/bin/python3"
-- vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/default/bin/python3")
vim.g.lazyvim_prettier_needs_config = true
vim.opt.wrap = true
vim.g.snacks_animate = false
vim.g.ai_cmp = true
