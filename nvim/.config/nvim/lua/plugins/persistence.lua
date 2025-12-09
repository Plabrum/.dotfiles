return {
  "folke/persistence.nvim",
  event = "VeryLazy", -- not "User VeryLazy"
  opts = {},
  config = function(_, opts)
    require("persistence").setup(opts)

    -- Check if auto_open_session is enabled in neoconf
    local neoconf_ok, neoconf = pcall(require, "neoconf")
    local auto_open = neoconf_ok and neoconf.get("auto_open_session") or false

    if not auto_open then
      return
    end

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
