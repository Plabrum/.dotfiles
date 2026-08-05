-- Org-mode: outlines, agenda, TODOs and capture for `.org` files.
--
-- Self-contained like the other `config.*` modules: adds its own plugin,
-- configures it, and owns its treesitter setup. Loaded lazily on the first
-- `org` filetype (see `init.lua`) since none of it matters until an `.org`
-- file is open.
--
-- nvim-orgmode ships and installs its *own* `org` tree-sitter grammar via
-- `setup()` below -- it must not be the copy from nvim-treesitter, which is a
-- different grammar and conflicts. `config.treesitter`'s generic FileType
-- installer is told to skip `org` for exactly this reason; highlighting for
-- org buffers is handled by orgmode itself.

local util = require("config.util")

vim.pack.add({ util.gh("nvim-orgmode/orgmode") })

require("orgmode").setup({
  -- Where your `.org` files live. `org_agenda_files` is what the agenda view
  -- (`<leader>oa`) scans; `org_default_notes_file` is the capture (`<leader>oc`)
  -- refile target. Point these at your own notes directory.
  org_agenda_files = "~/orgfiles/**/*",
  org_default_notes_file = "~/orgfiles/refile.org",
})

-- orgmode ships a small LSP (completion/omnifunc for links, tags, TODO
-- keywords). Enabling it is the upstream-recommended setup; it attaches only
-- to `org` buffers.
vim.lsp.enable("org")
