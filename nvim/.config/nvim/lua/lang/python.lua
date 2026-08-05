-- Python: basedpyright. See `lang/go.lua` for how this plugs into
-- `config.lsp`/`config.treesitter`.

local lsp = require("config.lsp")

require("nvim-treesitter").install({ "python" })

-- basedpyright re-analyzes on nearly every change and reports it as work-done
-- progress, which mini.notify's `lsp_progress` turns into a stream of
-- `basedpyright: (100%)` toasts (see `config.ui`). Advertising that this client
-- doesn't handle work-done progress makes the server stop emitting `$/progress`
-- at the source -- so basedpyright goes quiet while every other server keeps its
-- progress notifications. Merges over Neovim's default client capabilities.
lsp.servers.basedpyright = {
  capabilities = {
    window = { workDoneProgress = false },
  },
}
