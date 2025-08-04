-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Lua

local function goto_definition_in_new_window()
  -- Get the current buffer and cursor position
  local bufnr = vim.api.nvim_get_current_buf()
  local position = vim.api.nvim_win_get_cursor(0)
  local row, col = position[1] - 1, position[2]

  -- Create the position parameters manually
  local definition_params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = row, character = col },
  }

  -- Save the current window id
  local current_win = vim.api.nvim_get_current_win()

  -- Request definition
  vim.lsp.buf_request(bufnr, "textDocument/definition", definition_params, function(_, result)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end

    -- Get all windows
    local windows = vim.api.nvim_list_wins()

    -- If there's only one window, create a vertical split
    if #windows == 1 then
      vim.cmd("vsplit")
    else
      -- Otherwise, move to the next window
      vim.cmd("wincmd w")
    end

    -- Get the first result
    local location = result[1]
    if location then
      -- Handle location or locationLink
      local uri = location.uri or location.targetUri
      local range = location.range or location.targetSelectionRange

      -- Open the file in the current window (now the next window)
      local target_bufnr = vim.uri_to_bufnr(uri)
      vim.api.nvim_win_set_buf(0, target_bufnr)

      -- Ensure the buffer is loaded
      if not vim.api.nvim_buf_is_loaded(target_bufnr) then
        vim.fn.bufload(target_bufnr)
      end

      -- Set the cursor to the definition position
      vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })

      -- Center the cursor line
      vim.cmd("normal! zz")
    end
  end)
end

local function safe_map(lhs, rhs, opts)
  opts = opts or {}
  opts.expr = true
  opts.desc = opts.desc or ""
  vim.keymap.set("n", lhs, function()
    if vim.bo.filetype ~= "snacks_picker" and vim.bo.buftype == "" then
      return rhs
    else
      return lhs
    end
  end, opts)
end

safe_map("H", "^", { desc = "Move to beginning of line unless in picker" })
safe_map("L", "$", { desc = "Move to end of line unless in picker" })

local map = vim.keymap.set
-- map("n", "H", "^", { desc = "Move to beginning of line" })
-- map("n", "L", "$", { desc = "Move to end of line" })
map("n", "gw", goto_definition_in_new_window, { desc = "Go to definition in next window" })
map("n", "q", "<Nop>", { noremap = true, silent = true })
map("i", "jj", "<Esc>", { noremap = false })
map("i", "jk", "<Esc>", { noremap = false })
-- map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
-- Paste system clipboard in Insert mode using <C-v>
map("i", "<C-v>", "<C-r>+", { noremap = true, silent = true, desc = "Paste from system clipboard" })
map("n", "<leader>yy", function()
  local save_cursor = vim.fn.getpos(".")
  vim.cmd('keepjumps normal! gg"+yG')
  vim.fn.setpos(".", save_cursor)
end, { desc = "Yank entire buffer to clipboard" })
