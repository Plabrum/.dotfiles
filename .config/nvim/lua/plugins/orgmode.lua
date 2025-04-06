return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = "~/orgfiles/**/*",
        org_default_notes_file = "~/orgfiles/refile.org",
      })
    end,
  },
  -- {
  -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
  -- add ~org~ to ignore_install
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = {
  --     ensure_installed = "all",
  --     ignore_install = { "org" },
  --     sync_install = false,
  --     auto_install = true,
  --     highlight = {
  --       enable = true,
  --     },
  --   },
  -- },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          org = { "orgmode" },
        },
        providers = {
          orgmode = {
            name = "Orgmode",
            module = "orgmode.org.autocompletion.blink",
            fallbacks = { "buffer" },
          },
        },
      },
    },
  },
}
