-- org-markdown: my own Markdown-based org system -- capture, agenda, find and
-- refile over `.md` files, plus calendar sync. This replaces nvim-orgmode;
-- there are no `.org` files in this setup.
--
-- Self-contained like the other `config.*` modules: adds its own plugin and
-- configures it. The plugin registers its own keymaps from the `keymaps` table
-- in its config -- `<leader>oc` capture, `<leader>oa` agenda, `<leader>off` /
-- `<leader>ofh` find file / heading, `<leader>or*` refile, `<leader>oS` sync.
--
-- Loaded eagerly (not filetype-scoped) so the global pickers work from the
-- dashboard, not just once a markdown buffer is open. Startup cost is small:
-- the initial calendar pull is async and deferred inside `setup()`.

local util = require("config.util")

vim.pack.add({ util.gh("Plabrum/org-markdown") })

require("org_markdown").setup({
  window_method = "float",
  sync = {
    plugins = {
      calendar = {
        enabled = true,
        auto_sync = true,
        sync_file = "~/org/calendar.md",
        file_heading = "Calendar",
        days_ahead = 30,
        calendars = {}, -- all calendars
      },
    },
  },
})
