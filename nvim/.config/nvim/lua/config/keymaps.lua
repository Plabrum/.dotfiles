-- Core mappings: everything that doesn't belong to a specific plugin's module.
-- Plugin-owned mappings live next to that plugin's setup (yanky in
-- `config.editing`, flash/harpoon in `config.nav`, and so on).
--
-- Two exceptions live here because they're about mappings themselves rather
-- than about a feature: vim-tmux-navigator (which is really just `<C-hjkl>`),
-- and mini.clue (which documents the mappings the rest of the config defines).

local util = require("config.util")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New File" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save File" })
vim.keymap.set("n", "<leader>qq", "<cmd>qall<CR>", { desc = "Quit all" })

vim.keymap.set("n", "q", "<Nop>", { desc = "Disabled (was macro record)" })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste from system clipboard" })

for _, mode in ipairs({ "n", "i", "t" }) do
  vim.keymap.set(mode, "<M-Left>", "<Nop>", { silent = true })
  vim.keymap.set(mode, "<M-Right>", "<Nop>", { silent = true })
  vim.keymap.set(mode, "<M-Up>", "<Nop>", { silent = true })
  vim.keymap.set(mode, "<M-Down>", "<Nop>", { silent = true })
end

-- No yank-highlight autocmd here on purpose. LazyVim (and kickstart) register a
-- `TextYankPost` handler calling `vim.hl.on_yank()`, but that's for configs where
-- yanky is optional -- yanky does its own highlighting (`on_yank`/`on_put`, see
-- `config.editing`), and both write to the same `nvim.hlyank` namespace, so
-- yanky's simply overwrites it. Since yanky is unconditional here, such an
-- autocmd would be unconditionally dead code.

-- H/L as start/end of line instead of top/bottom of screen, except inside
-- a picker where H/L should keep doing whatever the picker expects.
---@param lhs string
---@param rhs string
---@param opts table
local function safe_map(lhs, rhs, opts)
  opts = opts or {}
  opts.expr = true
  vim.keymap.set("n", lhs, function()
    -- Only remap in real editable buffers (`buftype == ""`); leave H/L alone in
    -- special buffers like the snacks picker so its own bindings still work.
    if vim.bo.buftype == "" then
      return rhs
    else
      return lhs
    end
  end, opts)
end
safe_map("H", "^", { desc = "Move to beginning of line unless in picker" })
safe_map("L", "$", { desc = "Move to end of line unless in picker" })

vim.keymap.set("n", "<leader>yy", function()
  local save_cursor = vim.fn.getpos(".")
  vim.cmd('keepjumps normal! gg"+yG')
  vim.fn.setpos(".", save_cursor)
end, { desc = "Yank entire buffer to clipboard" })

vim.keymap.set("n", "<leader>yf", function()
  local relpath = vim.fn.expand("%:.")
  if relpath == "" then
    vim.notify("No file associated with this buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", relpath)
  vim.notify("Yanked relative path: " .. relpath)
end, { desc = "Yank relative file path to clipboard" })

-- ============================================================
-- WINDOWS
-- ============================================================

-- LazyVim puts the whole `<C-w>` vocabulary under `<leader>w`, but it does that
-- with a which-key *proxy* (`{ "<leader>w", proxy = "<c-w>" }`) rather than a
-- mapping -- which is why grepping LazyVim for `<leader>wv` finds nothing, and
-- why mini.clue has no equivalent (it has no proxy feature).
--
-- Aliasing the prefix reproduces it in one line: `<leader>w` *is* `<C-w>`, so
-- every native window command comes along for free and none of it is ours to
-- maintain -- `<leader>ws`/`wv` split, `wc` closes, `wo` onlys, `w=` equalises,
-- `w+`/`w-`/`w<`/`w>` resize, `wH`/`wJ` move the window, and so on. See `:h CTRL-W`.
vim.keymap.set("n", "<leader>w", "<C-w>", { remap = true, desc = "+Window (alias for <C-w>)" })

-- `<C-w>d` is "jump to definition in a split", *not* "delete window" -- so the
-- alias above doesn't cover LazyVim's `<leader>wd`, which is its own invention
-- mapped to `<C-w>c`. Kept as a real mapping rather than a retraining shim: it's
-- muscle memory worth keeping, and nagging on a key used this often would grate.
-- (The native spelling is `<leader>wc`, if you ever want to drift that way.)
--
-- Mapping this alongside the prefix alias makes `<leader>w` both a prefix and a
-- complete mapping, so a *bare* `<leader>w` waits `timeoutlen` before firing.
-- Typing `wd`/`ws`/`wv` is unaffected -- the second key disambiguates at once.
vim.keymap.set("n", "<leader>wd", "<cmd>wincmd c<CR>", { desc = "Delete Window" })

-- Ctrl+hjkl moves between vim splits *and* crosses into tmux panes,
-- unlike the plain `<C-w><C-h>`-style mappings.
vim.pack.add({ util.gh("christoomey/vim-tmux-navigator") })
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Move focus up" })

-- Shows pending keybinds in a popup after a short delay. mini.clue (part of
-- the already-loaded mini.nvim) is explicit where which-key was automatic: it
-- only pops up for the `triggers` prefixes registered below, and group labels
-- come from the `clues` list. The `gen_clues.*` generators add live popups of
-- marks/registers/window commands -- handy with yanky's ring on `"`.
local clue = require("mini.clue")
clue.setup({
  window = { delay = 200 },
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "gs" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "z" },
    { mode = "n", keys = '"' },
    { mode = "n", keys = "`" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "<C-w>" },
  },
  clues = {
    { mode = "n", keys = "<Leader>c", desc = "[C]ode (LazyVim compat)" },
    { mode = "n", keys = "<Leader><Tab>", desc = "[T]ab (LazyVim compat)" },
    { mode = "n", keys = "<Leader>s", desc = "[S]earch" },
    { mode = "n", keys = "<Leader>t", desc = "[T]oggle" },
    { mode = "n", keys = "<Leader>g", desc = "[G]it" },
    { mode = "n", keys = "<Leader>q", desc = "Session/Quit" },
    { mode = "n", keys = "<Leader>x", desc = "Diagnostics/Quickfix" },
    { mode = "n", keys = "<Leader>y", desc = "Yank" },
    { mode = "n", keys = "<Leader>b", desc = "Buffer" },
    { mode = "n", keys = "<Leader>o", desc = "[O]rg (markdown)" },
    { mode = "n", keys = "<Leader>of", desc = "Find" },
    { mode = "n", keys = "<Leader>or", desc = "Refile" },
    -- `<Leader>w` forwards to `<C-w>`, so the window commands themselves are
    -- documented by `gen_clues.windows()` below.
    { mode = "n", keys = "<Leader>w", desc = "[W]indow" },
    { mode = "n", keys = "gs", desc = "Surround" },
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
  },
})
