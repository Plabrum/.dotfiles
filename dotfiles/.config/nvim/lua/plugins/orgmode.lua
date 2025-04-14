return {
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      "danilshvalov/org-modern.nvim",
    },
    event = "VeryLazy",
    config = function()
      local Menu = require("org-modern.menu")
      local org_path = function(path)
        local org_directory = "~/orgfiles"
        return ("%s/%s"):format(org_directory, path)
      end
      require("orgmode").setup({
        org_agenda_files = org_path("**/*"),
        org_default_notes_file = org_path("refile.org"),

        win_split_mode = "vertical",
        org_agenda_span = "week",

        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,
        org_agenda_skip_if_done = true,
        org_hide_emphasis_markers = true,
        org_agenda_text_search_extra_files = { "agenda-archives" },
        org_agenda_start_on_weekday = false,
        org_startup_indented = true,
        org_highlight_latex_and_related = true,
        org_log_into_drawer = "LOGBOOK",
        org_todo_keywords = { "TODO(t)", "PROGRESS(p)", "|", "DONE(d)", "REJECTED(r)" },
        mappings = {
          org_return_uses_meta_return = false,
          org = {
            org_toggle_checkbox = { "<Leader>ov", desc = "Toggle checkbox" },
          },
        },
        org_agenda_custom_commands = {
          a = {
            description = "Agenda",
            types = {
              {
                type = "tags",
                match = "REVISIT",
                org_agenda_overriding_header = "Tasks to revisit",
              },
              {
                type = "agenda",
                org_agenda_tag_filter_preset = "-REVISIT",
              },
            },
          },
        },
        org_capture_templates = {
          r = {
            description = "Resource",
            template = "* [[%x][%?] \n%U",
            target = org_path("resources.org"),
          },
          i = {
            description = "Idea",
            template = "* %^{Title} %^g\n%?\n%U",
            target = org_path("ideas.org"),
          },
          q = {
            description = "Quick Note",
            template = "* %^{Title} \n%?\n%U",
          },
          T = {
            description = "Todo",
            template = "* TODO %^{Title} \n%?\nDEADLINE: %^{Deadline}t\n%U",
            -- target = org_path("todos.org"),
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
    end,
    keys = {
      {
        "<leader>oa",
        function()
          return Org.agenda()
        end,
      },
      {
        "<leader>oc",
        function()
          return Org.capture()
        end,
      },
    },
  },
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
  {
    "nvim-orgmode/org-bullets.nvim",
    opts = {
      concealcursor = true,
      symbols = {
        checkboxes = {
          half = { "", "@org.checkbox.halfchecked" },
          done = { "✓", "@org.checkbox.checked" },
          todo = { " ", "@org.checkbox" },
        },
      },
    },
  },
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {},
  },
  {
    "chipsenkbeil/org-roam.nvim",
    dependencies = {
      { "nvim-orgmode/orgmode" },
    },
    opts = {
      directory = "~/org_roam_files",
      -- optional
      -- org_files = {
      --   "~/another_org_dir",
      --   "~/some/folder/*.org",
      --   "~/a/single/org_file.org",
      -- },
    },
  },
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
    keys = {
      {
        "<leader>osr",
        mode = { "n" },
        function()
          require("telescope").extensions.orgmode.refile_heading()
        end,
        desc = "Refile heading",
      },
      {
        "<leader>osl",
        mode = { "n" },
        function()
          require("telescope").extensions.orgmode.insert_link()
        end,
        desc = "Insert link",
      },
      {
        "<leader>osh",
        mode = { "n" },
        function()
          require("telescope").extensions.orgmode.search_headings()
        end,
        desc = "Search headings",
      },
    },
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
