-- Temporary LazyVim muscle-memory shims.
--
-- Each of these still does the old LazyVim thing, but nags you toward the
-- nvim-slim keymap. This whole file is meant to be deleted once the new
-- bindings stick -- so nothing permanent belongs here. If you find yourself
-- wanting to add a mapping with no nvim-slim equivalent to nudge toward, it
-- goes in the module that owns the feature instead.

---@param old string the LazyVim key you're used to
---@param new string what to use instead -- a key (`gt`) or a command (`:tabclose`)
---@param action function
---@param desc string
local function retrain(old, new, action, desc)
  vim.keymap.set("n", old, function()
    vim.notify(("Use %s instead of %s"):format(new, old), vim.log.levels.WARN, { title = "nvim-slim retraining" })
    action()
  end, { desc = desc .. " (compat: prefer " .. new .. ")" })
end

---Shim a LazyVim key whose native equivalent is a `:command` rather than a key,
---so the nag names the command. `cmd` is given without the leading colon.
---@param old string
---@param cmd string
---@param desc string
local function retrain_cmd(old, cmd, desc)
  retrain(old, ":" .. cmd, function()
    vim.cmd(cmd)
  end, desc)
end

retrain("<leader>/", "<leader>sg", function()
  Snacks.picker.grep()
end, "[LazyVim compat] Grep search")

retrain("<leader>fm", "<leader>e", require("config.nav").open_files, "[LazyVim compat] File manager")

retrain("<leader>ca", "gra", vim.lsp.buf.code_action, "[LazyVim compat] Code action")

-- LazyVim's `<leader>ghp` was gitsigns' "Preview Hunk Inline". This config uses
-- mini.diff, whose inline preview is the whole-buffer overlay on `<leader>go`
-- (see `config.git`) -- close enough that the overlay is the thing to retrain to,
-- the only difference being all hunks at once vs. just the one under the cursor.
retrain("<leader>ghp", "<leader>go", function()
  MiniDiff.toggle_overlay()
end, "[LazyVim compat] Preview Hunk (inline overlay)")

-- Native `gd` is a buffer-local keyword search for the declaration -- no LSP,
-- and no jump across files. LazyVim rebinds it to `vim.lsp.buf.definition`;
-- `config.lsp` puts that on `grd` instead, alongside the other native `gr*`
-- mappings.
retrain("gd", "grd", function()
  Snacks.picker.lsp_definitions()
end, "[LazyVim compat] Goto Definition")

-- Native `gr` is the virtual-replace operator (`gr{char}`). LazyVim rebinds it
-- to references; `config.lsp` puts that on `grr` instead, alongside the other
-- native `gr*` mappings. Both go through snacks.picker, matching `config.lsp`.
retrain("gr", "grr", function()
  Snacks.picker.lsp_references()
end, "[LazyVim compat] Goto References")

-- Puts `:IncRename <cword>` on the command line without executing it, so the
-- live preview updates as you type the new name -- same as the `grn` mapping in
-- `config.lsp`, and the same trick LazyVim's inc-rename extra uses.
retrain("<leader>cr", "grn", function()
  vim.api.nvim_feedkeys(":IncRename " .. vim.fn.expand("<cword>"), "n", false)
end, "[LazyVim compat] Rename")

-- Alternate buffer. `<C-^>` is native, one keystroke, and always there.
-- LazyVim spells both of these `<cmd>e #<cr>`, which is the same jump.
-- Jump to the alternate buffer if one is set; otherwise fall back to the
-- most-recently-used *other* listed buffer. LazyVim/`<C-^>` rely on `#`, which
-- stays empty until you switch away from a buffer within the window -- so with
-- files opened via `nvim a b` or a picker, `edit #` raises E194 even with
-- several buffers listed. This makes the jump work regardless.
for _, key in ipairs({ "<leader>bb", "<leader>`" }) do
  retrain(key, "<C-^>", function()
    if vim.fn.expand("#") ~= "" then
      vim.cmd("edit #")
      return
    end
    local cur = vim.api.nvim_get_current_buf()
    local alt = nil
    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if b.bufnr ~= cur and (alt == nil or b.lastused > alt.lastused) then
        alt = b
      end
    end
    if alt == nil then
      vim.notify("No other buffer", vim.log.levels.INFO, { title = "nvim-slim retraining" })
      return
    end
    vim.api.nvim_set_current_buf(alt.bufnr)
  end, "[LazyVim compat] Switch to Other Buffer")
end

-- ============================================================
-- TABS
-- ============================================================
-- These matter more here than in LazyVim: bufferline runs in `mode = "tabs"`
-- (see `config.ui`), so the bar across the top *is* the tab list.
--
-- LazyVim's whole `<leader><tab>` group is thin wrappers over Neovim's native
-- `:tab*` commands, so for most of them the destination is the command itself
-- rather than a key -- next/prev are the exception, having real native mappings.
-- That makes them honest members of this file: delete it and you're already on
-- the native commands, with nothing lost.

retrain_cmd("<leader><tab><tab>", "tabnew", "[LazyVim compat] New Tab")
retrain_cmd("<leader><tab>d", "tabclose", "[LazyVim compat] Close Tab")
retrain_cmd("<leader><tab>o", "tabonly", "[LazyVim compat] Close Other Tabs")
retrain_cmd("<leader><tab>f", "tabfirst", "[LazyVim compat] First Tab")
retrain_cmd("<leader><tab>l", "tablast", "[LazyVim compat] Last Tab")

retrain("<leader><tab>]", "gt", function()
  vim.cmd("tabnext")
end, "[LazyVim compat] Next Tab")
retrain("<leader><tab>[", "gT", function()
  vim.cmd("tabprevious")
end, "[LazyVim compat] Previous Tab")
