-- TypeScript/JavaScript: ts_ls. See `lang/go.lua` for how this plugs into
-- `config.lsp`/`config.treesitter`.

local lsp = require("config.lsp")

require("nvim-treesitter").install({ "typescript", "tsx", "javascript" })

lsp.servers.ts_ls = {}
