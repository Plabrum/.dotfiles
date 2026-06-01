-- Deltas on top of LazyVim's `lang.ocaml` extra (which provides ocamllsp + the
-- `ocaml` treesitter parser). The extra leaves these gaps:
return {
  -- opam env is not loaded in the shell rc, so run ocamllsp through `opam exec`
  -- to pick it up from the active switch. (Merges with the extra's server opts.)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {
          cmd = { "opam", "exec", "--", "ocamllsp" },
        },
      },
    },
  },

  -- The extra wires up no formatter; format with ocamlformat (also via opam).
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.ocaml = { "ocamlformat" }
      opts.formatters = opts.formatters or {}
      opts.formatters.ocamlformat = {
        command = "opam",
        prepend_args = { "exec", "--", "ocamlformat" },
      }
      return opts
    end,
  },

  -- The extra installs only the `ocaml` parser; add interfaces and lexers.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "ocaml_interface",
          "ocamllex",
        })
      end
    end,
  },
}
