-- Getting around: file picker, file explorer, quick-marks, and labeled jumps.
--
-- Loads after `config.ui`, which sets up mini.icons and its nvim-web-devicons
-- mock -- snacks.picker and mini.files both draw their glyphs from it.

local util = require("config.util")

-- ============================================================
-- PICKER (snacks.picker)
-- ============================================================
-- Only the picker module of snacks.nvim is enabled -- everything else in the
-- suite stays dormant. Chosen over mini.pick for its always-on side preview and
-- in-picker toggles: while a picker is open, `<a-h>` toggles hidden files and
-- `<a-i>` toggles gitignored files -- the two things mini.pick couldn't do.

vim.pack.add({ util.gh("folke/snacks.nvim") })
require("snacks").setup({ picker = { enabled = true } })

vim.keymap.set("n", "<leader>sf", function()
  Snacks.picker.files()
end, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", function()
  Snacks.picker.grep()
end, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sh", function()
  Snacks.picker.help()
end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sd", function()
  Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.smart()
end, { desc = "Find files (smart)" })
vim.keymap.set("n", "<leader>,", function()
  Snacks.picker.buffers()
end, { desc = "Switch buffer" })
vim.keymap.set("n", "<leader>su", function()
  Snacks.picker.undo()
end, { desc = "[S]earch [U]ndo History" })

-- ============================================================
-- EXPLORER (mini.files)
-- ============================================================

-- `preview = true` adds the live third column showing the file/dir under the
-- cursor -- the same look MiniMax ships.
require("mini.files").setup({ windows = { preview = true } })

---Open mini.files at the current buffer's file, falling back to cwd.
---
---Exported because `config.retrain` maps the old LazyVim `<leader>fm` to it too.
---@return nil
local function open_files()
  -- Fall back to cwd (nil) when the buffer isn't backed by a real path -- e.g.
  -- the mini.starter dashboard buffer is named "ministarter:/1/welcome", which
  -- isn't on disk, so mini.files errors on it. Only pass the name through when
  -- `fs_stat` confirms it actually exists; nil triggers mini.files' cwd fallback.
  local name = vim.api.nvim_buf_get_name(0)
  local path = (name ~= "" and vim.uv.fs_stat(name)) and name or nil
  require("mini.files").open(path, true)
end
vim.keymap.set("n", "<leader>e", open_files, { desc = "[E]xplorer (mini.files)" })

-- ============================================================
-- HARPOON (quick-mark files and jump between them)
-- ============================================================

vim.pack.add({ util.gh("nvim-lua/plenary.nvim"), { src = util.gh("ThePrimeagen/harpoon"), version = "harpoon2" } })
local harpoon = require("harpoon")
harpoon:setup({
  -- Same opts LazyVim's harpoon2 extra passes: a near-full-width menu, and
  -- persist the list when the quick menu is toggled shut.
  menu = { width = vim.api.nvim_win_get_width(0) - 4 },
  settings = { save_on_toggle = true },
})

-- LazyVim's harpoon scheme: <leader>h opens the quick menu, <leader>H adds the
-- current file, <leader>1..9 jump to a marked file. `<leader>h` is a leaf action
-- (not a prefix) so it opens instantly -- hence add lives on `<leader>H` and the
-- selects at top-level `<leader>1..9`.
vim.keymap.set("n", "<leader>h", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Quick Menu" })
vim.keymap.set("n", "<leader>H", function()
  harpoon:list():add()
end, { desc = "Harpoon File" })
for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    harpoon:list():select(i)
  end, { desc = "Harpoon to File " .. i })
end

-- ============================================================
-- FLASH (labeled jumps + treesitter incremental selection)
-- ============================================================
-- The treesitter mode is configured with empty labels so it behaves like
-- native incremental selection: `S` selects the node under the cursor, then
-- `<c-space>` grows to the parent node and `<BS>` shrinks back.

vim.pack.add({ util.gh("folke/flash.nvim") })
local flash = require("flash")
flash.setup({
  modes = {
    treesitter = {
      actions = {
        ["<c-space>"] = "next",
        ["<BS>"] = "prev",
      },
      labels = "",
      label = { after = false, before = false },
    },
  },
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
  flash.jump()
end, { desc = "Flash" })

-- `<c-space>` to trigger incremental selection, like LazyVim. In LazyVim this
-- is nvim-treesitter's `incremental_selection` module, but the treesitter
-- `main` branch (used in `config.treesitter`) dropped that module -- so we route
-- `<c-space>` to flash's treesitter mode, which the config above turns into
-- incremental selection: press to start + select the node, `<c-space>` grows to
-- the parent, `<BS>` shrinks back.
vim.keymap.set({ "n", "x", "o" }, "<c-space>", function()
  flash.treesitter()
end, { desc = "Treesitter Incremental Selection" })
vim.keymap.set("o", "r", function()
  flash.remote()
end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function()
  flash.treesitter_search()
end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function()
  flash.toggle()
end, { desc = "Toggle Flash Search" })

return { open_files = open_files }
