-- Tree-sitter: parsers and the autocmd that attaches them.
--
-- Uses the `main` branch of nvim-treesitter, which dropped the old module
-- system -- so highlighting/indent is wired up by hand below, and incremental
-- selection is delegated to flash (see `config.nav`).

local util = require("config.util")

-- Register the build hook *before* the plugin is added, so a first-run install
-- in this session still triggers `:TSUpdate`.
util.on_packchanged("nvim-treesitter", { "install", "update" }, function()
  vim.cmd("TSUpdate")
end, "Update tree-sitter parsers")

vim.pack.add({ { src = util.gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

-- Base parsers only; `lang.*` modules install their own on top of this via
-- `require("nvim-treesitter").install({...})`, which is safe to call
-- incrementally at any point after this module has loaded.
local parsers = {
  "bash",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "vim",
  "vimdoc",
  "diff",
  "query",
}
require("nvim-treesitter").install(parsers)

---@param buf integer
---@param language string
local function try_attach(buf, language)
  if not vim.treesitter.language.add(language) then
    return
  end
  vim.treesitter.start(buf, language)
  if vim.treesitter.query.get(language, "indents") then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("slim-treesitter", { clear = true }),
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then
      return
    end
    if vim.tbl_contains(require("nvim-treesitter").get_installed("parsers"), language) then
      try_attach(args.buf, language)
    elseif vim.tbl_contains(require("nvim-treesitter").get_available(), language) then
      require("nvim-treesitter").install(language):await(function()
        try_attach(args.buf, language)
      end)
    end
  end,
})
