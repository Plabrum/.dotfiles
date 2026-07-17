-- Python: basedpyright. See `lang/go.lua` for how this plugs into
-- `config.lsp`/`config.treesitter`.

local lsp = require("config.lsp")

require("nvim-treesitter").install({ "python" })

lsp.servers.basedpyright = {}
