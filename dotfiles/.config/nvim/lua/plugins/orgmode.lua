return {
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-orgmode/telescope-orgmode.nvim",
      "nvim-orgmode/org-bullets.nvim",
      "Saghen/blink.cmp",
      "danilshvalov/org-modern.nvim",
    },
    event = "VeryLazy",
    config = function()
      local Menu = require("org-modern.menu")
      require("orgmode").setup({
        org_agenda_files = "~/orgfiles/**/*",
        org_default_notes_file = "~/orgfiles/refile.org",
        org_capture_templates = {
          r = {
            description = "Resource",
            template = "* [[%x][%(return string.match('%x', '([^/]+)$'))]]%?",
            target = "~/orgfiles/resrouces.org",
          },
        },
        ui = {
          menu = {
            handler = function(data)
              Menu:new():open(data)
            end,
          },
        },
      })
      require("org-bullets").setup()
      --Setup headlines.nvim
      require("blink.cmp").setup({
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
      })
    end,
  },
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },
  {
    "chipsenkbeil/org-roam.nvim",
    tag = "0.1.1",
    dependencies = {
      {
        "nvim-orgmode/orgmode",
        tag = "0.3.7",
      },
    },
    config = function()
      require("org-roam").setup({
        directory = "~/org_roam_files",
        -- optional
        org_files = {
          "~/another_org_dir",
          "~/some/folder/*.org",
          "~/a/single/org_file.org",
        },
      })
    end,
  },
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("orgmode")

      vim.keymap.set("n", "<leader>r", require("telescope").extensions.orgmode.refile_heading)
      vim.keymap.set("n", "<leader>fh", require("telescope").extensions.orgmode.search_headings)
      vim.keymap.set("n", "<leader>li", require("telescope").extensions.orgmode.insert_link)
    end,
  },
  {
    "michaelb/sniprun",
    branch = "master",

    build = "sh install.sh",
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65

    config = function()
      require("sniprun").setup({
        -- your options
      })
    end,
  },
}
