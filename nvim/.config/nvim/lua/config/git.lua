-- All git in one place: the sign column + hunk operators (mini.diff), the `:Git`
-- command and blame-at-cursor (mini.git), and a full-screen lazygit (hand-rolled
-- float). mini.diff and mini.git are both part of the already-loaded mini.nvim.

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
-- LAZYGIT (full-screen float)
-- ============================================================

vim.keymap.set("n", "<leader>gg", function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    style = "minimal",
    border = "none",
  })
  vim.fn.jobstart("lazygit", {
    term = true,
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd.startinsert()
end, { desc = "LazyGit (floating)" })
