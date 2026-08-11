-- The `tt` task tracker as a full-screen floating TUI, mirroring the lazygit
-- float in `config.git`: same snacks terminal, same tmux-aware `<C-hjkl>`, same
-- per-cwd caching so the key resumes the running app rather than respawning it.
-- `tt` is the uv-tool binary on $PATH (see the task-tracker repo); bare `tt`
-- with no subcommand is the TUI, and it opens on the cwd's project.

---`tmux select-pane` in one direction, for use inside the tt terminal.
---
---Same reason as `config.git`: tmux sees nvim on the pane's tty and forwards
---`<C-hjkl>` instead of switching panes, and the `config.keymaps` navigation
---mappings are normal-mode only -- so the terminal-mode maps below reclaim them.
---@param dir string One of `L`/`D`/`U`/`R`.
---@return fun(): nil
local function tmux_pane(dir)
  return function()
    vim.fn.system({ "tmux", "select-pane", "-" .. dir })
  end
end

---Toggle the tt TUI filling the whole editor.
---
---snacks caches the terminal per (cmd, cwd), so pressing `<leader>tt` again
---returns to the same running tt process -- its selection and screen intact --
---instead of launching a second one. Because tt opens on the cwd's project, the
---float tracks whichever repo you're editing, the way the lazygit float does.
---@return nil
local function tt()
  Snacks.terminal.toggle("tt", {
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

vim.keymap.set("n", "<leader>tt", tt, { desc = "tt task tracker (floating)" })

return { tt = tt }
