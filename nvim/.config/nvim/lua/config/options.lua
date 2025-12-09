--Options automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.g.ai_cmp = false
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.python3_host_prog = "~/.pyenv/versions/neovim/bin/python3"
vim.g.lazyvim_prettier_needs_config = true
vim.opt.wrap = true
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "snacks"

-- Configure cursor appearance and blinking for different modes
vim.opt.guicursor = {
  "n-v-c:block-Cursor/lCursor-blinkwait300-blinkon100-blinkoff100",
  "i-ci:ver25-Cursor/lCursor-blinkwait300-blinkon100-blinkoff100",
  "r-cr:hor20-Cursor/lCursor-blinkwait300-blinkon100-blinkoff100",
}

vim.g.phil_allow_extras = true
