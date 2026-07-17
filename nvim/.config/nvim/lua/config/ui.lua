-- Everything visible at startup: icons, colorscheme, tabline, winbar, the
-- dashboard, and message/notification handling.
--
-- This is the module that most needs to load `now` -- anything here that
-- arrives late shows up as a visible flicker.

local util = require("config.util")

-- ============================================================
-- ICONS
-- ============================================================

-- Icon provider used by mini.files for per-filetype glyphs (needs a Nerd Font
-- in the terminal). Without this it falls back to plain markers.
-- `mock_nvim_web_devicons` lets non-mini plugins that expect nvim-web-devicons
-- (e.g. snacks.picker, set up in `config.nav`) use these icons too -- so this
-- module must load before that one.
require("mini.icons").setup({})
MiniIcons.mock_nvim_web_devicons()

-- ============================================================
-- COLORSCHEME
-- ============================================================

vim.pack.add({ util.gh("sainnhe/sonokai") })
vim.g.sonokai_enable_italic = false
vim.cmd.colorscheme("sonokai")

-- ============================================================
-- BUFFERLINE (top bar showing open buffers -- instead of a bottom statusline)
-- ============================================================

vim.pack.add({ util.gh("akinsho/bufferline.nvim") })
require("bufferline").setup({
  options = {
    mode = "tabs",
    always_show_bufferline = false, -- hide until there's more than one buffer/tab, like LazyVim
    show_buffer_icons = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
  },
})

-- ============================================================
-- BREADCRUMBS (winbar: relative path per window/buffer)
-- ============================================================
-- LazyVim's breadcrumbs.lua uses `LazyVim.lualine.pretty_path()`, which only
-- exists inside LazyVim -- this is a small hand-rolled equivalent: last 5
-- path segments of the current file, relative to cwd.

---@return string
local function pretty_path()
  local path = vim.fn.expand("%:~:.")
  if path == "" then
    return "[No Name]"
  end
  local parts = vim.split(path, "/", { plain = true })
  if #parts > 5 then
    parts = vim.list_slice(parts, #parts - 4, #parts)
  end
  local icon, hl = MiniIcons.get("file", vim.fn.expand("%:t"))
  return ("   %%#%s#%s%%*   %s"):format(hl, icon, table.concat(parts, "/"))
end

-- No plugin needed for this -- `winbar` is a native Neovim option that takes
-- a statusline-style expression string, so we just point it at our function.
_G._nvim_slim_winbar = pretty_path
local winbar_expr = "%{%v:lua._nvim_slim_winbar()%}"

-- Hide it on special buffers and on empty/unsaved new buffers (nothing useful
-- to show in either case). Any `buftype ~= ""` buffer is special -- mini.files,
-- the snacks picker, terminals, help, etc. -- and several of those have synthetic
-- names (e.g. mini.files' "minifiles://4//real/path") that pretty_path would mangle.
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("slim-winbar", { clear = true }),
  callback = function()
    local is_special = vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == ""
    vim.wo.winbar = is_special and "" or winbar_expr
  end,
})

-- ============================================================
-- DASHBOARD (mini.starter)
-- ============================================================
-- MiniMax's dashboard is just the default mini.starter. We keep that exact look
-- and section order, but swap its Sessions section (which expects mini.sessions)
-- for one backed by persistence.nvim, which is what nvim-slim actually uses --
-- see `config.session`.

---@param n integer maximum number of sessions to list
---@return fun(): table[] a mini.starter items generator
local function persistence_sessions(n)
  return function()
    local items, seen = {}, {}
    for _, path in ipairs(require("persistence").list()) do
      -- Session filenames encode the directory (with `/` written as `%`) and
      -- an optional git branch as `dir%%branch` -- the same scheme decoded by
      -- persistence's own `select()` picker.
      local dir, branch = unpack(vim.split(vim.fn.fnamemodify(path, ":t:r"), "%%", { plain = true }))
      dir = dir:gsub("%%", "/")
      if not seen[dir] then
        seen[dir] = true
        local name = vim.fn.fnamemodify(dir, ":~")
        if branch then
          name = ("%s (%s)"):format(name, branch)
        end
        items[#items + 1] = {
          name = name,
          section = "Sessions",
          action = function()
            vim.fn.chdir(dir)
            require("persistence").load()
          end,
        }
        if #items >= n then
          break
        end
      end
    end
    if #items == 0 then
      return { { name = "There are no saved sessions", action = "", section = "Sessions" } }
    end
    return items
  end
end

local starter = require("mini.starter")
starter.setup({
  items = {
    persistence_sessions(5),
    starter.sections.recent_files(5, false, false),
    starter.sections.builtin_actions(),
  },
})

-- One-key `s` restores the cwd session (mini.starter is otherwise type-to-filter).
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniStarterOpened",
  callback = function(args)
    vim.keymap.set("n", "s", function()
      require("persistence").load()
    end, { buffer = args.buf, desc = "Restore Session" })
  end,
})

-- ============================================================
-- CMDLINE / INPUT / NOTIFICATIONS
-- ============================================================

-- Nicer `vim.ui.input` (floating prompt) -- used by inc-rename, etc.
require("mini.input").setup({})

-- Notifications: mini.notify replaces the old noice + nvim-notify stack. Toasts
-- appear top-right and auto-fade. setup() also points `vim.notify` at mini.notify
-- automatically, so every `vim.notify(...)` call in this config routes here. It does
-- NOT capture raw Neovim messages -- those are quieted via `shortmess` in
-- `config.options`.
require("mini.notify").setup({})
vim.keymap.set("n", "<leader>sn", function()
  MiniNotify.show_history()
end, { desc = "[S]earch [N]otifications" })

-- Command-line UX: autocompletion, `:W`->`:w`-style autocorrection, and a live
-- range peek. Unlike noice, mini.cmdline does NOT couple the cmdline to message
-- handling -- so we get cmdline polish without routing messages through it, and
-- the cmdline stays classic/bottom on its own.
require("mini.cmdline").setup({})
