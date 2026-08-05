-- Rust: rustaceanvim (rust-analyzer) + crates.nvim for Cargo.toml.
-- See `lang/go.lua` for how `lang.*` modules plug into the `config.*` ones.
--
-- Ported from LazyVim's `lang.rust` extra. Note this module does *not* touch
-- `config.lsp`'s `M.servers`, unlike every other `lang.*` module: rustaceanvim
-- owns the rust-analyzer client itself rather than going through lspconfig, and
-- the extra correspondingly sets `rust_analyzer = { enabled = false }` on
-- lspconfig. Here that's simply a matter of not registering it -- the server
-- table is opt-in, so there's nothing to disable.
--
-- Two pieces of the extra are dropped because the plugins they extend don't
-- exist in this config: the codelldb DAP adapter (no nvim-dap) and the
-- `rustaceanvim.neotest` adapter (no neotest). Add them back alongside those
-- plugins if you ever want them.

local util = require("config.util")

require("nvim-treesitter").install({ "rust", "ron" })

-- rust-analyzer comes from rustup (`~/.cargo/bin`), not mason -- it has to match
-- the toolchain that built the project's metadata. rustaceanvim finds it on
-- `$PATH` and warns if it's missing, so there's nothing to register with
-- mason-tool-installer.
vim.pack.add({ util.gh("mrcjkb/rustaceanvim") })

-- rustaceanvim is configured through this global rather than a `setup()` call;
-- it reads it when it attaches to the first rust buffer. Set before the
-- FileType autocmd can fire, which is why it's assigned at module load.
vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, {
  server = {
    ---@param bufnr integer
    on_attach = function(_, bufnr)
      -- rust-analyzer groups its code actions, and plain `vim.lsp.buf.code_action`
      -- (on `gra`, from `config.lsp`) can't expand a group -- `RustLsp codeAction`
      -- is the one that can. LazyVim puts this on `<leader>cR`; it goes next to
      -- the other LSP verbs here instead, capitalised like `grD` is against `grd`.
      vim.keymap.set("n", "grA", function()
        vim.cmd.RustLsp("codeAction")
      end, { buffer = bufnr, desc = "LSP: [G]oto Grouped Code [A]ction (Rust)" })
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        checkOnSave = true,
        diagnostics = { enable = true },
        procMacro = { enable = true },
        files = {
          exclude = {
            ".direnv",
            ".git",
            ".jj",
            ".github",
            ".gitlab",
            "bin",
            "node_modules",
            "target",
            "venv",
            ".venv",
          },
          -- Avoids "Roots Scanned" hanging.
          -- See https://github.com/rust-lang/rust-analyzer/issues/12613
          watcher = "client",
        },
      },
    },
  },
})

-- Cargo.toml gets its own in-process language server: version completion for
-- crates, hover with the crate's docs, and code actions to bump dependencies.
vim.pack.add({ util.gh("Saecki/crates.nvim") })
require("crates").setup({
  completion = {
    crates = { enabled = true },
  },
  lsp = {
    enabled = true,
    actions = true,
    completion = true,
    hover = true,
  },
})
