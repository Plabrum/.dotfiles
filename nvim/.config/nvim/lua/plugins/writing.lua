return {
  "preservim/vim-pencil",
  ft = { "markdown", "text", "tex", "mail", "org" },
  config = function()
    vim.g["pencil#wrapModeDefault"] = "soft" -- default is 'hard'

    -- Org file specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "org", "markdown", "text" },
      desc = "Enable wrap, spell check for org files",
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en_us" }
      end,
    })

    -- Spelling key mappings for text files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "org", "markdown", "text" },
      desc = "Set up spelling keymaps for text files",
      callback = function()
        -- Quick fix for the word under cursor (uses first suggestion)
        vim.keymap.set("n", "<leader>zf", "1z=", { buffer = true, desc = "Fix spelling" })
        -- Show suggestions
        vim.keymap.set("n", "<leader>zs", "z=", { buffer = true, desc = "Spelling suggestions" })
        -- Add word to dictionary
        vim.keymap.set("n", "<leader>za", "zg", { buffer = true, desc = "Add word to dictionary" })
      end,
    })

    -- Enable Pencil for text file types
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text", "tex", "mail", "org" },
      desc = "Enable Pencil for text files",
      callback = function()
        vim.cmd("PencilSoft") -- Or PencilSoft if you prefer soft wrapping
      end,
    })
  end,
}
