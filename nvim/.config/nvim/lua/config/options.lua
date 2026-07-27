-- Built-in Neovim behaviour. Loaded first: `mapleader` must be set before any
-- `<leader>` mapping is defined, or those mappings bind to the old leader.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)
vim.o.breakindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
-- Popup-menu / floating-window polish (matches nvim-minimax). `pumborder` draws a
-- border around the popup menu -- this is what makes the mini.cmdline command-line
-- completion popup look bordered/framed instead of a borderless full-width block.
-- `winborder` does the same for floats (LSP hover, signature, etc). Requires nvim 0.11+.
vim.o.pumborder = "single" -- Border around the popup / cmdline-completion menu
vim.o.pumheight = 10 -- Cap popup menu height
vim.o.pummaxwidth = 100 -- Cap popup menu width
vim.o.winborder = "single" -- Border around floating windows
vim.o.confirm = true
vim.o.laststatus = 0 -- no bottom statusline; bufferline.nvim shows files at the top instead
vim.o.cmdheight = 0 -- collapse the command/message row when idle, so no persistent bottom footer (noice used to do this)
-- mini.notify (see `config.ui`) only intercepts `vim.notify()`, not raw Neovim
-- messages (`:w` "written", search counts, completion chatter). noice used to
-- fade those too via ext_messages; the mini approach instead quiets them at the
-- source. This is MiniMax's exact value -- see nvim-minimax's plugin/10_options.lua.
vim.o.shortmess = "CFOSWaco"
