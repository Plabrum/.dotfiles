-- All git in one place: the sign column + hunk operators (mini.diff), the `:Git`
-- command and blame-at-cursor (mini.git), a full-screen lazygit (snacks), and
-- the two snacks GitHub features -- gitbrowse (open on GitHub) and gh (issues/PRs
-- via the `gh` CLI). mini.diff and mini.git are both part of the already-loaded
-- mini.nvim; the snacks bits ride on the picker set up in `config.nav`.

-- ============================================================
-- MINI.DIFF (sign column + hunk operators)
-- ============================================================
-- Shows added/changed/deleted lines against git HEAD, and adds hunk
-- operators/motions out of the box: `gh` apply, `gH` reset (both take a motion
-- or the `gh` textobject, e.g. `ghip` = apply hunks in paragraph), `[h`/`]h` jump
-- to prev/next hunk (`[H`/`]H` for first/last). `<leader>go` toggles an inline
-- overlay of the unstaged changes.
--
-- Pure defaults, like MiniMax: because `number` is on, mini.diff uses its
-- *number* view -- colouring the line number itself by change type rather than
-- showing a glyph in the sign column.
require("mini.diff").setup()
vim.keymap.set("n", "<leader>go", function()
  MiniDiff.toggle_overlay()
end, { desc = "[G]it [O]verlay (inline diff)" })

-- ============================================================
-- MINI.GIT (`:Git` command, info at cursor)
-- ============================================================
-- Complements gitsigns: a faster blame than snacks' was.

require("mini.git").setup({})

-- Blame lives on `<leader>gb` to match LazyVim, where `<leader>gb` is "Git Blame
-- Line". It used to be on `<leader>gs` here, which was a trap: LazyVim binds
-- `<leader>gs` to Git Status, so that key did something quite different from
-- what a LazyVim user's fingers expect. `<leader>gs` is given back to status below.
--
-- Not a retraining shim: there is no native blame to nudge toward -- mini.git is
-- the destination, so nagging would only point at slim's own invention.
vim.keymap.set({ "n", "x" }, "<leader>gb", function()
  require("mini.git").show_at_cursor()
end, { desc = "[G]it [B]lame line (info at cursor)" })

-- Git status picker, matching LazyVim's `<leader>gs`. snacks.picker is set up in
-- `config.nav`, which loads before this module.
vim.keymap.set("n", "<leader>gs", function()
  Snacks.picker.git_status()
end, { desc = "[G]it [S]tatus" })
vim.keymap.set("n", "<leader>gd", "<cmd>Git diff<CR>", { desc = "[G]it [D]iff" })
vim.keymap.set("n", "<leader>gL", "<cmd>Git log --oneline<CR>", { desc = "[G]it [L]og" })

-- ============================================================
-- GITBROWSE (open on GitHub)
-- ============================================================
-- `Snacks.gitbrowse` turns the current file/line into its remote URL and opens
-- it in the browser (GitHub, GitLab, Bitbucket, Azure -- all handled by snacks'
-- remote/url patterns). Like lazygit and the tt terminal, it's a standalone
-- snacks function: it needs no `enabled` flag in the `setup()` over in
-- `config.nav`, just the `require("snacks")` that already ran there.
--
-- Keys match LazyVim: `<leader>gB` opens, `<leader>gY` copies the URL to the
-- system clipboard instead. Both work from a visual selection too, in which case
-- snacks picks up the highlighted line range for the `#L..-L..` anchor.
vim.keymap.set({ "n", "x" }, "<leader>gB", function()
  Snacks.gitbrowse()
end, { desc = "[G]it [B]rowse (open on GitHub)" })
vim.keymap.set({ "n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  })
end, { desc = "[G]it browse: [Y]ank URL" })

-- ============================================================
-- GH (GitHub issues & PRs via the `gh` CLI)
-- ============================================================
-- `Snacks.gh` browses GitHub issues and pull requests through the snacks picker,
-- backed by the `gh` CLI (must be installed and `gh auth`'d -- it is). Like
-- gitbrowse it needs no `enabled` flag: the picker sources (`gh_issue`/`gh_pr`)
-- register alongside the picker set up in `config.nav`, and snacks wires the
-- `gh://` buffers (the rendered issue/PR view) on its own.
--
-- `<cr>` on a result opens the action menu (comment, close/reopen, review, merge,
-- checkout, open in browser, yank URL, ...). Capitalised key = include closed
-- items. Mnemonics follow the module's own docs and this file's `[G]it [X]` set.
vim.keymap.set("n", "<leader>gi", function()
  Snacks.picker.gh_issue()
end, { desc = "[G]it [I]ssues (open)" })
vim.keymap.set("n", "<leader>gI", function()
  Snacks.picker.gh_issue({ state = "all" })
end, { desc = "[G]it [I]ssues (all)" })
vim.keymap.set("n", "<leader>gp", function()
  Snacks.picker.gh_pr()
end, { desc = "[G]it [P]Rs (open)" })
vim.keymap.set("n", "<leader>gP", function()
  Snacks.picker.gh_pr({ state = "all" })
end, { desc = "[G]it [P]Rs (all)" })

-- ============================================================
-- LAZYGIT (full-screen float)
-- ============================================================

---`tmux select-pane` in one direction, for use inside the lazygit terminal.
---
---Without these, `<C-hjkl>` is dead in lazygit: tmux sees nvim on the pane's tty
---so it forwards the key instead of switching panes itself, and the mappings in
---`config.keymaps` are normal-mode only.
---@param dir string One of `L`/`D`/`U`/`R`.
---@return fun(): nil
local function tmux_pane(dir)
  return function()
    vim.fn.system({ "tmux", "select-pane", "-" .. dir })
  end
end

---Toggle lazygit filling the whole editor.
---
---snacks caches the terminal per cwd, so `q` only hides the window: pressing
---`<leader>gg` again returns to the same lazygit process, cursor and staged
---state intact, instead of respawning it.
---
---`configure = false` keeps snacks out of `$LG_CONFIG_FILE` -- it would
---otherwise generate a theme matching the colorscheme and point lazygit at it.
---
---Exported because the `config.ui` dashboard offers it as a one-key action too.
---That module loads *before* this one, but it only `require`s us when the key is
---actually pressed -- by which time we're loaded and cached.
---@return nil
local function lazygit()
  Snacks.lazygit({
    configure = false,
    win = {
      position = "float",
      width = 0,
      height = 0,
      backdrop = false,
      border = "none",
      keys = {
        nav_h = { "<C-h>", tmux_pane("L"), mode = { "n", "t" }, desc = "tmux pane left" },
        nav_j = { "<C-j>", tmux_pane("D"), mode = { "n", "t" }, desc = "tmux pane down" },
        nav_k = { "<C-k>", tmux_pane("U"), mode = { "n", "t" }, desc = "tmux pane up" },
        nav_l = { "<C-l>", tmux_pane("R"), mode = { "n", "t" }, desc = "tmux pane right" },
      },
    },
  })
end

vim.keymap.set("n", "<leader>gg", lazygit, { desc = "LazyGit (floating)" })

return { lazygit = lazygit }
