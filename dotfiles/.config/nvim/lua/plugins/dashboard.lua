local custom_header = [[
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard.preset.header = custom_header
    opts.dashboard.sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      {
        pane = 1,
        icon = " ",
        title = "Recent Projects",
        section = "projects",
        indent = 2,
        padding = 1,
      },
      -- {
      --   pane = 1,
      --   section = "terminal",
      --   enabled = function()
      --     return Snacks.git.get_root() ~= nil
      --   end,
      --   padding = 1,
      --   ttl = 5 * 60,
      --   indent = 3,
      --   icon = " ",
      --   title = "Open PRs",
      --   cmd = "gh pr list --author @me --state open",
      --   key = "P",
      --   action = function()
      --     vim.fn.jobstart("gh pr list --web", { detach = true })
      --   end,
      --   height = 2,
      -- },
      -- {
      --   pane = 1,
      --   icon = " ",
      --   title = "Git Status",
      --   section = "terminal",
      --   enabled = function()
      --     return Snacks.git.get_root() ~= nil
      --   end,
      --   cmd = "git status --short --branch --renames",
      --   height = 2,
      --   padding = 1,
      --   ttl = 5 * 60,
      --   indent = 3,
      -- },
      { section = "startup" },
    }
    return opts
  end,
}
