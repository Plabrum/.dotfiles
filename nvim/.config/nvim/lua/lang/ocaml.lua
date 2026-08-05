-- OCaml: ocamllsp from the active opam switch, ocamlformat, ocaml parsers.
-- See `lang/go.lua` for how this plugs into `config.lsp`/`config.format`/
-- `config.treesitter`.
--
-- Ported from LazyVim's `lang.ocaml` extra. That extra overrode ocamllsp's
-- `filetypes` and `root_markers`; nvim-lspconfig has since grown a much better
-- `lsp/ocamllsp.lua` of its own, so those overrides are deliberately dropped --
-- see the note on the server below.

local lsp = require("config.lsp")
local format = require("config.format")

-- `ocaml_interface` and `ocamllex` are installed but not reached by the
-- FileType autocmd in `config.treesitter`: stock Neovim maps `.ml`, `.mli`,
-- `.mll` and `.mly` all to the single `ocaml` filetype, and that's what the
-- autocmd keys off. The `ocaml` parser handles interface files well enough in
-- practice; the other two are here so they're ready if a filetype plugin that
-- distinguishes them ever gets added.
require("nvim-treesitter").install({ "ocaml", "ocaml_interface", "ocamllex" })

-- Everything except `cmd` comes from nvim-lspconfig's `lsp/ocamllsp.lua`, which
-- is strictly better than what LazyVim's extra hardcoded: prioritised root
-- markers (dune-project/dune-workspace, then *.opam/esy.json/package.json, then
-- .git), a `get_language_id` that maps `.mli`/`.mll`/`.mly` to the right LSP
-- language id despite them all sharing the `ocaml` filetype, and a
-- `:LspOcamllspSwitchImplIntf` command for jumping between `.ml` and `.mli`.
-- The extra's `filetypes` list named LSP language ids (`ocaml.interface`)
-- rather than real Neovim filetypes, so adopting it would have *lost* coverage.
--
-- `cmd` is the one genuine local override: opam's env isn't sourced in the shell
-- rc, so `ocamllsp` isn't on `$PATH` -- `opam exec` resolves it from the active
-- switch. This also sidesteps mason's copy, which mason.nvim prepends to `$PATH`
-- and which is built against whichever compiler mason happened to use.
lsp.servers.ocamllsp = {
  cmd = { "opam", "exec", "--", "ocamllsp" },
}
lsp.mason_ignore.ocamllsp = true

-- The extra wires up no formatter. ocamlformat needs a `.ocamlformat` file at
-- the project root to do anything; without one it errors, which conform
-- swallows (`notify_on_error = false`) and falls back to ocamllsp's own
-- formatting.
format.formatters_by_ft.ocaml = { "ocamlformat" }
format.formatters.ocamlformat = {
  command = "opam",
  prepend_args = { "exec", "--", "ocamlformat" },
}
