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

-- Extra schemes are installed purely so `<leader>uC` (config.nav) has more than
-- one option to preview/switch between via Snacks.picker.colorschemes().
vim.pack.add({
  util.gh("sainnhe/sonokai"),
  util.gh("rebelot/kanagawa.nvim"),
  util.gh("folke/tokyonight.nvim"),
  util.gh("ellisonleao/gruvbox.nvim"),
})
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
-- DASHBOARD (mini.starter, "cockpit" layout)
-- ============================================================
-- MiniMax's dashboard is the default mini.starter: a greeting, saved sessions,
-- and globally-recent files. This is a different bet entirely.
--
-- Every list-shaped dashboard assumes you want to *read* on startup. But you
-- already know what you were doing -- you closed the editor a minute ago. So
-- this one shows no data at all: just a state line, and a handful of one-key
-- actions whose *membership* changes with the repo. The discipline is that an
-- action renders only when it is currently valid, so the screen can never offer
-- a no-op and never has to say "0 of these" -- you cannot press a key for a
-- thing that isn't true. Nothing to scan; press a key before your eyes focus
-- and it's already gone.
--
-- Recent files, in particular, is gone for good: it listed files touched
-- anywhere on disk, so opening one left cwd pointing at an unrelated project
-- and quietly broke the pickers, grep and LSP root. `f` below does that job
-- properly.

---@class SlimRepo
---@field root string? repo root; nil outside a repo
---@field branch string? nil outside a repo or on a detached HEAD
---@field dirty integer changed files (working tree + index)
---@field conflicts integer unmerged paths
---@field ahead integer commits we have that the upstream doesn't
---@field behind integer commits the upstream has that we don't
---@field stashes integer stash entries
---@field stash_top string? subject of the most recent stash
---@field rebasing boolean
---@field merging boolean
---@field session boolean cwd has a saved persistence session

---`<root>/.git` is a directory in a normal clone but a `gitdir: <path>` pointer
---file inside a linked worktree -- follow it so the in-progress checks below
---look in the right place. Cheaper than a `git rev-parse --git-path` process.
---@param root string
---@return string?
local function resolve_gitdir(root)
  local dot = vim.fs.joinpath(root, ".git")
  local stat = vim.uv.fs_stat(dot)
  if not stat then
    return nil
  end
  if stat.type == "directory" then
    return dot
  end
  local pointer = (vim.fn.readfile(dot, "", 1)[1] or ""):match("^gitdir: (.+)$")
  if not pointer then
    return nil
  end
  -- The pointer is relative to the worktree in `git worktree` layouts.
  return vim.fs.normalize(pointer:sub(1, 1) == "/" and pointer or vim.fs.joinpath(root, pointer))
end

---@param path string
---@return boolean
local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

---Does cwd have a saved session? Reuses persistence's own filename scheme: the
---directory with `/` written as `%`, plus an optional `%%branch` suffix.
---@return boolean
local function has_session()
  local cwd = vim.uv.cwd()
  for _, path in ipairs(require("persistence").list()) do
    local encoded = vim.split(vim.fn.fnamemodify(path, ":t:r"), "%%", { plain = true })[1]
    if encoded:gsub("%%", "/") == cwd then
      return true
    end
  end
  return false
end

---mini.starter evaluates `header`/`items` when the buffer opens rather than at
---setup, and the keymaps below need the same answer -- so this runs once per
---dashboard, not once per caller.
---@type table<string, SlimRepo>
local state_cache = {}

---@return SlimRepo
local function repo_state()
  local cwd = vim.uv.cwd() or ""
  if state_cache[cwd] then
    return state_cache[cwd]
  end

  ---@type SlimRepo
  local s = {
    root = vim.fs.root(cwd, ".git"),
    dirty = 0,
    conflicts = 0,
    ahead = 0,
    behind = 0,
    stashes = 0,
    rebasing = false,
    merging = false,
    session = has_session(),
  }

  if s.root then
    -- One process for branch, divergence and file counts. `-b` prepends a
    -- `## branch...upstream [ahead 1, behind 2]` line; `--no-renames` keeps
    -- every other line a plain `XY path` with no ` -> ` form to special-case.
    local out = vim.fn.systemlist({ "git", "status", "--porcelain=v1", "-b", "--no-renames" })
    if vim.v.shell_error == 0 then
      local head = out[1] or ""
      s.branch = head:match("^## ([^%.%s]+)")
      -- A detached HEAD reports `## HEAD (no branch)`; there's no branch to name.
      s.branch = s.branch ~= "HEAD" and s.branch or nil
      s.ahead = tonumber(head:match("ahead (%d+)")) or 0
      s.behind = tonumber(head:match("behind (%d+)")) or 0
      for _, line in ipairs(vim.list_slice(out, 2)) do
        -- Unmerged paths are the codes with a `U` on either side, plus the
        -- both-added / both-deleted pairs. Everything else is an ordinary change.
        local xy = line:sub(1, 2)
        local unmerged = xy:find("U", 1, true) or xy == "AA" or xy == "DD"
        if unmerged then
          s.conflicts = s.conflicts + 1
        else
          s.dirty = s.dirty + 1
        end
      end
    end

    local gitdir = resolve_gitdir(s.root)
    if gitdir then
      -- The stash reflog is one line per entry, so it answers both "how many"
      -- and "what was the last one" without spawning `git stash list`.
      local reflog = vim.fs.joinpath(gitdir, "logs/refs/stash")
      local entries = exists(reflog) and vim.fn.readfile(reflog) or {}
      s.stashes = #entries
      -- An auto-stash logs `WIP on main: <sha> <subject>`, an explicit one
      -- `On main: <message>`. Try the sha-bearing form first so the subject
      -- isn't prefixed with a hash nobody can read at a glance.
      local top = entries[#entries] or ""
      s.stash_top = top:match("\t.-: %x+ (.*)$") or top:match("\t.-: (.*)$")
      s.rebasing = exists(gitdir .. "/rebase-merge") or exists(gitdir .. "/rebase-apply")
      s.merging = exists(gitdir .. "/MERGE_HEAD")
    end
  end

  state_cache[cwd] = s
  return s
end

---@param n integer
---@param singular string
---@return string
local function plural(n, singular)
  return ("%d %s%s"):format(n, singular, n == 1 and "" or "s")
end

---@class SlimAction
---@field key string the single key that runs it
---@field label string|fun(s: SlimRepo): string
---@field run fun(s: SlimRepo)
---@field when (fun(s: SlimRepo): boolean)? omitted means always available

-- Order is screen order. Interrupted operations lead (they block everything
-- else), then whatever this repo currently affords, then the three that are
-- always true -- so the constant block keeps a stable position at the bottom
-- however much the contextual block above it grows or shrinks.
---@type SlimAction[]
local ACTIONS = {
  {
    key = "r",
    when = function(s)
      return s.conflicts > 0
    end,
    label = function(s)
      return "resolve " .. plural(s.conflicts, "conflict")
    end,
    run = function()
      Snacks.picker.git_status()
    end,
  },
  {
    key = "c",
    when = function(s)
      return s.rebasing or s.merging
    end,
    label = function(s)
      return s.rebasing and "continue rebase" or "continue merge"
    end,
    run = function(s)
      vim.cmd.Git(s.rebasing and "rebase --continue" or "merge --continue")
    end,
  },
  {
    key = "A",
    when = function(s)
      return s.rebasing or s.merging
    end,
    label = function(s)
      return s.rebasing and "abort rebase" or "abort merge"
    end,
    -- Capitalised: aborting throws away work, so it shouldn't sit under a key
    -- you might hit while reaching for something else.
    run = function(s)
      vim.cmd.Git(s.rebasing and "rebase --abort" or "merge --abort")
    end,
  },
  {
    key = "s",
    when = function(s)
      return s.session
    end,
    label = "resume session here",
    run = function()
      require("persistence").load()
    end,
  },
  {
    key = "S",
    label = "session in another project",
    run = function()
      require("persistence").select()
    end,
  },
  {
    key = "d",
    when = function(s)
      return s.dirty > 0
    end,
    label = function(s)
      return "review " .. plural(s.dirty, "change")
    end,
    run = function()
      Snacks.picker.git_status()
    end,
  },
  {
    key = "p",
    when = function(s)
      return s.ahead > 0
    end,
    label = function(s)
      return "push " .. plural(s.ahead, "commit")
    end,
    run = function()
      vim.cmd.Git("push")
    end,
  },
  {
    key = "u",
    when = function(s)
      return s.behind > 0
    end,
    label = function(s)
      return "pull " .. plural(s.behind, "commit")
    end,
    run = function()
      vim.cmd.Git("pull")
    end,
  },
  {
    key = "x",
    when = function(s)
      return s.stashes > 0
    end,
    -- Naming the stash makes popping it a decision rather than a gamble.
    label = function(s)
      return s.stash_top and ("pop stash: " .. s.stash_top) or ("pop " .. plural(s.stashes, "stash"))
    end,
    run = function()
      vim.cmd.Git("stash pop")
    end,
  },
  {
    key = "f",
    label = "find file",
    run = function()
      Snacks.picker.smart()
    end,
  },
  {
    key = "/",
    label = "grep",
    run = function()
      Snacks.picker.grep()
    end,
  },
  {
    key = "g",
    label = "lazygit",
    run = function()
      require("config.git").lazygit()
    end,
  },
}

---@param s SlimRepo
---@return SlimAction[]
local function available(s)
  return vim.tbl_filter(function(action)
    return action.when == nil or action.when(s)
  end, ACTIONS)
end

---Where am I -- the one line of information the cockpit keeps, in place of
---mini.starter's time-of-day greeting (which told us what a clock already does).
---@return string
local function header()
  local s = repo_state()
  if not s.root then
    return vim.fn.fnamemodify(vim.uv.cwd() or "", ":~")
  end
  local parts = { vim.fs.basename(s.root), s.branch or "detached" }
  if s.ahead > 0 then
    parts[#parts + 1] = "󰜷 " .. s.ahead
  end
  if s.behind > 0 then
    parts[#parts + 1] = "󰜮 " .. s.behind
  end
  if s.conflicts > 0 then
    parts[#parts + 1] = "󰀦 " .. plural(s.conflicts, "conflict")
  end
  -- "clean" only when there is genuinely nothing outstanding: conflicts are
  -- counted apart from `dirty`, so a purely conflicted tree has dirty == 0.
  if s.dirty > 0 then
    parts[#parts + 1] = plural(s.dirty, "change")
  elseif s.conflicts == 0 then
    parts[#parts + 1] = "clean"
  end
  return table.concat(parts, "  ")
end

---The section is unnamed, so mini.starter emits a blank line where the section
---header would have gone -- collapse runs of blanks so the key grid sits
---directly under the state line instead of drifting down the screen.
---@param content table[][] mini.starter content: lines of units
---@return table[][]
local function collapse_blanks(content)
  local out, prev_blank = {}, false
  for _, line in ipairs(content) do
    local text = table.concat(vim.tbl_map(function(unit)
      return unit.string
    end, line))
    local blank = text:match("^%s*$") ~= nil
    if not (blank and prev_blank) then
      out[#out + 1] = line
    end
    prev_blank = blank
  end
  return out
end

local starter = require("mini.starter")
starter.setup({
  header = header,
  -- A table of generators, not a bare function -- mini.starter type-checks it.
  items = {
    function()
      local s = repo_state()
      return vim.tbl_map(function(action)
        return {
          name = ("%s   %s"):format(action.key, type(action.label) == "function" and action.label(s) or action.label),
          -- A single unnamed section: the actions are already grouped by the
          -- order they're declared in, and headers would only add lines to scan.
          section = "",
          action = function()
            action.run(s)
          end,
        }
      end, available(s))
    end,
  },
  footer = "⏎  run      q  quit",
  -- No bullets: this is a key grid, not a list. `aligning` is otherwise the
  -- default hook pair, minus `adding_bullet`.
  content_hooks = { collapse_blanks, starter.gen_hook.aligning("center", "center") },
  -- Type-to-filter is what the default dashboard uses to reach an item, but
  -- here every item already *is* a key -- leaving it on would mean a keypress
  -- both ran an action and started a query.
  query_updaters = "",
})

-- The single-key bindings, from the same table that drew the screen -- so a key
-- can never be live while its action is invisible, or vice versa. Keys whose
-- action isn't currently valid are simply unmapped and do nothing.
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniStarterOpened",
  callback = function(args)
    local s = repo_state()
    for _, action in ipairs(available(s)) do
      vim.keymap.set("n", action.key, function()
        action.run(s)
      end, {
        buffer = args.buf,
        desc = type(action.label) == "function" and action.label(s) or action.label,
      })
    end
    vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = args.buf, desc = "Quit" })
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
