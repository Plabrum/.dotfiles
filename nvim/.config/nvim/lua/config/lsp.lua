-- Language servers: mason (installs them), lspconfig (configures them),
-- diagnostics display, and the LSP-dependent mappings.

local util = require("config.util")

-- ============================================================
-- DIAGNOSTICS
-- ============================================================

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })

-- `]d`/`[d` are Neovim natives (0.11+) and stop at *any* diagnostic -- errors,
-- warnings, hints and info alike. These add LazyVim's severity-filtered variants:
-- in a file with twenty warnings and one error, `]e` goes straight to the error.
-- Neovim ships only the unfiltered pair, so there's no native spelling for these.
---@param count integer 1 for next, -1 for previous
---@param severity string a `vim.diagnostic.severity` key
---@return function
local function diagnostic_jump(count, severity)
  return function()
    vim.diagnostic.jump({ count = count, severity = vim.diagnostic.severity[severity] })
  end
end
vim.keymap.set("n", "]e", diagnostic_jump(1, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_jump(-1, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_jump(1, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_jump(-1, "WARN"), { desc = "Prev Warning" })

-- ============================================================
-- DIAGNOSTIC / QUICKFIX LISTS (`<leader>x`)
-- ============================================================
-- Trouble is a persistent panel that groups diagnostics by file and lets you
-- navigate them -- a different tool from `<leader>sd` (snacks.picker.diagnostics),
-- which is a transient fuzzy list. Both earn their place.

vim.pack.add({ util.gh("folke/trouble.nvim") })
require("trouble").setup({})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer Diagnostics" })

-- Native location/quickfix lists. Toggles, like LazyVim's: open when closed,
-- close when open. `winid ~= 0` is how you ask "is this list already showing?".
vim.keymap.set("n", "<leader>xl", function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

-- ============================================================
-- PLUGINS
-- ============================================================

vim.pack.add({
  util.gh("neovim/nvim-lspconfig"),
  util.gh("mason-org/mason.nvim"),
  util.gh("mason-org/mason-lspconfig.nvim"),
  util.gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  util.gh("smjonas/inc-rename.nvim"),
})

require("mason").setup({})

-- Live-preview LSP rename (replaces the plain `grn` -> vim.lsp.buf.rename).
require("inc_rename").setup({})

-- ============================================================
-- MAPPINGS
-- ============================================================

-- Go to LSP definition in the other window (splits one if there's only one).
vim.keymap.set("n", "gw", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = row - 1, character = col },
  }
  vim.lsp.buf_request(bufnr, "textDocument/definition", params, function(_, result)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    if #vim.api.nvim_list_wins() == 1 then
      vim.cmd("vsplit")
    else
      vim.cmd("wincmd w")
    end
    local location = result[1]
    local uri = location.uri or location.targetUri
    local range = location.range or location.targetSelectionRange
    local target_bufnr = vim.uri_to_bufnr(uri)
    vim.api.nvim_win_set_buf(0, target_bufnr)
    if not vim.api.nvim_buf_is_loaded(target_bufnr) then
      vim.fn.bufload(target_bufnr)
    end
    vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
    vim.cmd("normal! zz")
  end)
end, { desc = "Go to definition in next window" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("slim-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    vim.keymap.set("n", "grn", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, { buffer = event.buf, expr = true, desc = "LSP: [R]e[n]ame" })
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    map("grr", vim.lsp.buf.references, "[G]oto [R]eferences")
    map("gri", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    map("grd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    map("grt", vim.lsp.buf.type_definition, "[G]oto [T]ype Definition")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/inlayHint", event.buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})

-- ============================================================
-- SERVERS
-- ============================================================

-- Base servers live here; per-language servers are registered by `lua/lang/*.lua`
-- modules onto `M.servers`, and `M.finalize()` (called once from `init.lua`,
-- after all `lang.*` modules have loaded) installs and enables everything.

local M = {}

---@type table<string, vim.lsp.Config>
M.servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { checkThirdParty = false },
        format = { enable = false },
      },
    },
  },
}

-- Extra mason packages to install that aren't LSP servers (linters, formatters
-- not covered by conform's own registry, etc). `lang.*` modules append here.
---@type string[]
M.mason_tools = {}

function M.finalize()
  require("mason-tool-installer").setup({
    ensure_installed = vim.list_extend(vim.tbl_keys(M.servers), M.mason_tools),
  })
  for name, server in pairs(M.servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

return M
