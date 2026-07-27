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

-- Scope the file/grep pickers to the enclosing git repo so they cover the whole
-- monorepo, not just `:pwd`. This is what the old LazyVim config's git-root
-- `<leader><space>`/`<leader>/` overrides did; here it rides on the keys this
-- config actually uses (`sf`/`sg`/`<leader><leader>`) rather than reviving those
-- keys -- `<leader>/` is being retired in `config.retrain`. `vim.fs.root` walks
-- up for a `.git` marker (no `git` subprocess per keypress); nil -> snacks'
-- default cwd when the buffer isn't inside a repo.
---@return string?
local function git_root()
  return vim.fs.root(0, ".git")
end

vim.keymap.set("n", "<leader>sf", function()
  Snacks.picker.files({ cwd = git_root() })
end, { desc = "[S]earch [F]iles (git root)" })
vim.keymap.set("n", "<leader>sg", function()
  Snacks.picker.grep({ cwd = git_root() })
end, { desc = "[S]earch by [G]rep (git root)" })
vim.keymap.set("n", "<leader>sh", function()
  Snacks.picker.help()
end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sd", function()
  Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.smart({ cwd = git_root() })
end, { desc = "Find files (smart, git root)" })
vim.keymap.set("n", "<leader>,", function()
  Snacks.picker.buffers()
end, { desc = "Switch buffer" })
vim.keymap.set("n", "<leader>su", function()
  Snacks.picker.undo()
end, { desc = "[S]earch [U]ndo History" })

-- The rest of the `<leader>s` set: these were LazyVim snacks-picker defaults
-- (from its `editor.snacks_picker` extra) that never got hand-copied here.
-- `ss`/`sS` need an attached LSP that serves `documentSymbol`/`workspaceSymbol`.
vim.keymap.set("n", "<leader>ss", function()
  Snacks.picker.lsp_symbols()
end, { desc = "[S]earch [S]ymbols (Document)" })
vim.keymap.set("n", "<leader>sS", function()
  Snacks.picker.lsp_workspace_symbols()
end, { desc = "[S]earch [S]ymbols (Workspace)" })
-- Visual mode too: greps the selection rather than the word under the cursor.
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
  Snacks.picker.grep_word()
end, { desc = "[S]earch [W]ord under cursor" })
vim.keymap.set("n", "<leader>sR", function()
  Snacks.picker.resume()
end, { desc = "[S]earch [R]esume last picker" })
vim.keymap.set("n", "<leader>sk", function()
  Snacks.picker.keymaps()
end, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sb", function()
  Snacks.picker.lines()
end, { desc = "[S]earch [B]uffer Lines" })
vim.keymap.set("n", "<leader>sm", function()
  Snacks.picker.marks()
end, { desc = "[S]earch [M]arks" })

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

-- `gx` inside a mini.files window: open the entry under the cursor with the
-- system handler (Preview/PDF viewer/browser). The global `gx` can't work here
-- -- it reads `<cfile>`, but mini.files rows are prefixed with an icon glyph, so
-- the parse collapses to just the extension (`.pdf`) and `vim.ui.open` fails on
-- a path that doesn't exist. `get_fs_entry().path` gives the real absolute path.
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "gx", function()
      local entry = require("mini.files").get_fs_entry()
      if entry then
        vim.ui.open(entry.path)
      end
    end, { buffer = args.data.buf_id, desc = "Open entry with system app" })
  end,
})

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
