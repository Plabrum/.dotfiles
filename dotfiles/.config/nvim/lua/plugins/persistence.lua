return {
  "folke/persistence.nvim",
  event = "VeryLazy", -- not "User VeryLazy"
  opts = {},
  config = function(_, opts)
    require("persistence").setup(opts)

    -- Only restore if Neovim was started without files
    if vim.fn.argc() ~= 0 then
      return
    end

    -- Optional: don't auto-restore when opening Lazy itself
    if vim.bo.filetype == "lazy" then
      return
    end

    -- Small safety: schedule to the next tick so all VeryLazy handlers finish
    vim.schedule(function()
      require("persistence").load() -- or { last = true }
    end)
  end,
}
