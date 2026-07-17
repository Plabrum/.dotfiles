-- Completion (mini.completion + mini.keymap). Part of mini.nvim -- no extra plugin.
--
-- Async two-stage autocompletion: LSP candidates when a server is attached,
-- falling back to buffer-keyword completion otherwise. A popup appears after a
-- short delay; signature help pops up after trigger characters like `(`.
--
-- Accept/navigate keys are wired through mini.keymap's `map_multistep`, which is
-- what lets one key do the right thing by context: `<CR>` accepts the selected
-- item when the menu is open, otherwise falls through to mini.pairs' newline
-- handling (see `config.editing`); `<Tab>`/`<S-Tab>` walk the menu when it's open
-- and insert a literal tab otherwise. This replaces blink.cmp, whose "default"
-- preset accepted on `<C-y>` and left `<Tab>`/`<CR>` unmapped.

local util = require("config.util")

-- Hide noisy `Text` items and sort snippets last, like MiniMax.
local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
local function process_items(items, base)
  return MiniCompletion.default_process_items(items, base, process_items_opts)
end

require("mini.completion").setup({
  lsp_completion = {
    -- Drive LSP completion through `omnifunc` (set per-buffer on LspAttach below)
    -- rather than `completefunc`: cleaner (only active when an LSP is attached)
    -- and lets `<C-u>` work. `auto_setup = false` because we set omnifunc ourselves.
    source_func = "omnifunc",
    auto_setup = false,
    process_items = process_items,
  },
})

-- Point `omnifunc` at mini.completion's LSP source, per buffer, once a server
-- attaches. This is a second LspAttach handler -- `config.lsp` has its own for
-- the LSP mappings, and both fire.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("slim-completion-omnifunc", { clear = true }),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
  end,
})

-- Advertise (to every server) that Neovim now supports the richer completion and
-- signature features mini.completion implements, so servers send snippets,
-- resolve support, etc. Merges into each server's config from `config.lsp`.
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })

-- Context-aware insert-mode keys (see the header note). `map_multistep` tries
-- each step in order and falls back to the key's default when none apply.
require("mini.keymap").setup()
MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })

-- Snippets (mini.snippets). mini.snippets ships no snippets itself -- it loads
-- them from files. We pull in friendly-snippets (the big community collection,
-- organised per-language under its own `snippets/` dir) plus a personal
-- `snippets/global.json` in this config.
--
-- In insert mode: type a prefix and press <C-j> to expand (or <C-j> on a partial
-- prefix to pick from matches). During a session, <C-l>/<C-h> jump to the
-- next/prev tabstop and <C-c> ends it (these fall through to their defaults when
-- no session is active, so <C-h> still deletes as usual). LSP snippet items from
-- the completion menu expand through mini.snippets too.
vim.pack.add({ util.gh("rafamadriz/friendly-snippets") })
local snippets = require("mini.snippets")
snippets.setup({
  snippets = {
    -- Personal global snippets, available in every buffer.
    snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
    -- Per-language snippets from any `snippets/` dir on the runtimepath
    -- (friendly-snippets, mainly).
    snippets.gen_loader.from_lang(),
  },
})
