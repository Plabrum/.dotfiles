-- Text manipulation: textobjects, surround, comments, pairs, yank/paste,
-- increment/decrement, and buffer removal.

local util = require("config.util")

-- ============================================================
-- MINI TEXT EDITING
-- ============================================================

require("mini.ai").setup({ n_lines = 500 })

-- `gs`-prefixed so `s`/`S` stay free for flash (see `config.nav`).
require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})

require("mini.comment").setup({}) -- gcc / gc / gb, same as LazyVim's mini-comment extra

-- Autopairs. `modes.command` also pairs in the `:` command line. The insert-mode
-- <CR>/<BS> pair handling is driven from `config.completion` (mini.keymap's
-- map_multistep) so it coexists with completion: <CR> accepts a completion when
-- the menu is open and expands the pair otherwise.
require("mini.pairs").setup({ modes = { insert = true, command = true, terminal = false } })

-- Animated indent-scope guide + `[i`/`]i` motions and `ii`/`ai` textobjects.
require("mini.indentscope").setup({})

-- Move text with Alt+hjkl: the current line in Normal mode, the selection in
-- Visual mode, re-indenting as it goes. Defaults are already `<M-hjkl>`, which
-- is what LazyVim's mini-move extra uses too (it passes `opts = {}`), so this
-- matches the behaviour you already have there.
--
-- On macOS this only reaches Neovim if the terminal sends Option as Alt --
-- ghostty's `macos-option-as-alt` (currently `left`, so left Option only).
require("mini.move").setup({})

-- Delete a buffer without closing its window/split (plain `:bdelete` collapses
-- the layout).
require("mini.bufremove").setup({})
vim.keymap.set("n", "<leader>bd", function()
  require("mini.bufremove").delete()
end, { desc = "Delete buffer (keep window)" })

-- ============================================================
-- YANKY (better yank/paste: history ring, put-after-selection, clipboard sync)
-- ============================================================

vim.pack.add({ util.gh("gbprod/yanky.nvim") })
require("yanky").setup({
  system_clipboard = { sync_with_ring = not vim.env.SSH_CONNECTION },
  highlight = { timer = 150 },
})

vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)", { desc = "Yank Text" })
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put Text After Cursor" })
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put Text Before Cursor" })
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Put Text After Selection" })
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Put Text Before Selection" })
vim.keymap.set("n", "[y", "<Plug>(YankyCycleForward)", { desc = "Cycle Forward Through Yank History" })
vim.keymap.set("n", "]y", "<Plug>(YankyCycleBackward)", { desc = "Cycle Backward Through Yank History" })
vim.keymap.set({ "n", "x" }, "<leader>p", "<cmd>YankyRingHistory<CR>", { desc = "Open Yank History" })

-- ============================================================
-- ILLUMINATE (highlight other references to the word under the cursor)
-- ============================================================

vim.pack.add({ util.gh("RRethy/vim-illuminate") })
require("illuminate").configure({})

-- ============================================================
-- DIAL (smarter increment/decrement: dates, booleans, semver, etc.)
-- ============================================================

vim.pack.add({ util.gh("monaqa/dial.nvim") })
local augend = require("dial.augend")
require("dial.config").augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.alias["%Y/%m/%d"],
    augend.constant.alias.bool,
    augend.semver.alias.semver,
    augend.constant.new({ elements = { "and", "or" } }),
  },
})
vim.keymap.set("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end, { desc = "Increment" })
vim.keymap.set("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end, { desc = "Decrement" })
vim.keymap.set("v", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end, { desc = "Increment" })
vim.keymap.set("v", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end, { desc = "Decrement" })
