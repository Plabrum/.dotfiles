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
        local org_directory = "~/org"
        return ("%s/%s"):format(org_directory, path)
      end
      require("orgmode").setup({
        org_agenda_files = org_path("**/*"),
        org_default_notes_file = org_path("refile.org"),

        win_split_mode = "auto",
        -- win_split_mode = "vertical",
        win_border = "rounded",
        org_agenda_span = "week",

        -- org_agenda_skip_scheduled_if_done = true,
        -- org_agenda_skip_deadline_if_done = true,
        org_agenda_skip_if_done = true,
        org_hide_emphasis_markers = true,
        org_agenda_text_search_extra_files = { "agenda-archives" },
        org_agenda_start_on_weekday = false,
        org_startup_folded = "content",
        org_return_uses_meta_return = true,
        org_startup_indented = true,
        org_highlight_latex_and_related = "native",
        org_log_into_drawer = "LOGBOOK",
        org_todo_keywords = { "TODO(t)", "IN_PROGRESS(p)", "IN_REVIEW(r)", "|", "DONE(d)", "CANCELED(c)" },
        org_todo_keyword_faces = {
          TODO = ":foreground orange :weight bold",
          IN_PROGRESS = ":foreground yellow :weight bold",
          IN_REVIEW = ":foreground black :background green :weight bold",
          DONE = ":foreground green :weight bold",
          CANCELED = ":foreground grey :weight bold",
        },
        -- Notifications
        notifications = {
          enabled = true,
          repeater_reminder_time = 10,
          deadline_warning_reminder_time = 0,
          reminder_time = { 10, 5 },
          deadline_reminder = true,
          scheduled_reminder = true,
        },
        mappings = {
          org_return_uses_meta_return = false,
          org = {
            org_toggle_checkbox = { "<Leader>ov", desc = "Toggle checkbox" },
          },
        },
        org_custom_exports = {
          f = {
            label = "Export to Plain Text format",
            action = function(exporter)
              local current_file = vim.api.nvim_buf_get_name(0)
              local target = vim.fn.fnamemodify(current_file, ":p:r") .. ".txt"
              local command = { "pandoc", current_file, "-o", target }
              local on_success = function(output)
                print("Success!")
                vim.api.nvim_echo({ { table.concat(output, "\n") } }, true, {})
              end
              local on_error = function(err)
                print("Error!")
                vim.api.nvim_echo({ { table.concat(err, "\n"), "ErrorMsg" } }, true, {})
              end
              return exporter(command, target, on_success, on_error)
            end,
          },
        },
        org_agenda_custom_commands = {
          m = {
            description = "Moab Agenda",
            types = {
              {
                type = "tags_todo",
                match = "moab",
                org_agenda_overriding_header = "Moab tasks",
                org_agenda_sorting_strategy = { "time-up", "priority-down", "category-keep" },
                org_agenda_remove_tags = true, -- Do not show tags only for this view
                -- org_agenda_skip_if_done = true,
              },
              {
                type = "agenda",
                match = "moab",
                org_agenda_overriding_header = "My daily agenda",
                org_agenda_span = "day", -- can be any value as org_agenda_spanorganize
                org_agenda_todo_ignore_scheduled = "all",
                org_agenda_remove_tags = true, -- Do not show tags only for this view
              },
              {
                type = "tags_todo",
                org_agenda_overriding_header = "Other tasks",
                org_agenda_tag_filter_preset = "-personal -moab",
              },
            },
          },
          p = {
            description = "Personal Agenda",
            types = {
              {
                type = "tags_todo",
                org_agenda_overriding_header = "Personal tasks",
                org_agenda_tag_filter_preset = "personal",
                org_agenda_remove_tags = true, -- Do not show tags only for this view
              },
              {
                type = "agenda",
                org_agenda_tag_filter_preset = " -moab",
                org_agenda_overriding_header = "My daily agenda",
                org_agenda_span = "day", -- can be any value as org_agenda_spanorganize
                org_agenda_todo_ignore_scheduled = "all",
                org_agenda_remove_tags = true, -- Do not show tags only for this view
              },
            },
          },
        },
        org_capture_templates = {
          r = {
            description = "Resource",
            template = "* [[%x][%?] \n%U",
          },
          t = {
            description = "Todo",
            template = "* TODO %?\n%U",
          },
          n = {
            description = "Note",
            template = "* %^{Title}\n%U\n%?",
          },
          c = {
            description = "Code Question",
            template = "* %^{Question}\n%U\n%a\n- %?",
            target = org_path("moab/code_questions.org"),
            headline = "Questions",
          },
          m = {
            description = "Moab todo",
            template = "* TODO %?\n%U",
            target = org_path("moab/todo.org"),
            headline = "Moab Todo's",
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
  -- {
  --   "nvim-orgmode/org-bullets.nvim",
  --   opts = {
  --     concealcursor = true,
  --     symbols = {
  --       checkboxes = {
  --         half = { "", "@org.checkbox.halfchecked" },
  --         done = { "✓", "@org.checkbox.checked" },
  --         todo = { " ", "@org.checkbox" },
  --       },
  --     },
  --   },
  -- },
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
    opts = {
      extensions = {
        max_depth = 2,
      },
    },
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
      "n",
      {
        "<Leader>or",
        mode = { "n" },
        function()
          require("telescope").extension.orgmode.search_headings({ mode = "orgfiles" })
        end,
        desc = "Find org files",
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
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.dashboard.preset.keys, 4, {
        icon = "\u{e633}",
        key = "o",
        desc = "Orgmode",
        action = function()
          vim.cmd("edit ~/org/refile.org")
        end,
      })
    end,
  },
  --  {
  -- 'folke/snacks.nvim',
  --    opts = function(_, opts)
  --      opts.dashboard.sections
  --  }
}
