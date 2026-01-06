return {
  { "nvim-mini/mini.test", version = false },
  {
    dir = "~/repos/org-markdown",
    name = "org_markdown",
    dev = true,
    -- "Plabrum/org-markdown",
    opts = {
      window_method = "float",
      -- captures = {
      --   templates = {
      --     ["Task"] = {
      --       template = "# TODO %? \n %u",
      --       filename = "~/org/refile.md",
      --       heading = "",
      --     },
      --     ["Linear Issue"] = {
      --       filename = "~/org/linear-staging.md",
      --       heading = "",
      --       template = "# TODO %? \n%u",
      --     },
      --     ["Idea"] = {
      --       template = "# %? \n %u",
      --       filename = "~/org/refile.md",
      --       heading = "",
      --     },
      --     ["Code Pointer"] = {
      --       template = "# Pointer: %a \n %? \n %u",
      --       filename = "~/org/refile.md",
      --       heading = "",
      --     },
      --   },
      -- },
      sync = {
        plugins = {
          -- sheets = {
          --   file_heading = "Arive Tracker",
          --   enabled = false,
          --   use_gcloud = true, -- Use OAuth with write permissions
          --   quota_project = "env:GOOGLE_QUOTA_PROJECT", -- Google Cloud project ID for billing/quota
          --   bidirectional = true, -- Enable write-back to sheet
          --   auto_push = true, -- Auto-push on file save
          --   spreadsheet_id = "env:SHEETS_SPREADSHEET_ID",
          --   sheet_name = "Sheet1",
          --
          --   -- Column mapping for your sheet
          --   columns = {
          --     title = "Feature",
          --     status = "Status",
          --     priority = "Priority",
          --     tags = { "Bug Feature" },
          --     body = { "Owner", "Notes", "Bug Feature" },
          --   },
          --
          --   -- These are the defaults, customize as needed
          --   conversions = {
          --     status_map = {
          --       ["todo"] = "TODO",
          --       ["in progress"] = "IN_PROGRESS",
          --       ["done"] = "DONE",
          --     },
          --     priority_ranges = {
          --       { min = 1, max = 3, letter = "A" },
          --       { min = 4, max = 6, letter = "B" },
          --       { min = 7, max = 10, letter = "C" },
          --     },
          --     sanitize_tags = true,
          --   },
          -- },
          calendar = {
            enabled = true, -- optional, defaults to true anyway
            auto_sync = true,
            sync_file = "~/org/calendar.md", -- optional, this is the default
            file_heading = "Calendar",
            days_ahead = 30,
            calendars = {}, -- all calendars
            -- other options...
          },
          -- linear = {
          --   enabled = true,
          --   sync_file = "~/org/linear.md",
          --   file_heading = "Arive", -- Optional: YAML frontmatter heading (e.g., "Linear Issues")
          --   api_key = "env:LINEAR_API_KEY", -- Required: Linear API key (get from https://linear.app/settings/api)
          --   include_assigned = true,
          --   include_cycles = false,
          --   team_ids = { "ARI" }, -- Empty = all teams
          --   heading_level = 2,
          --   auto_sync = true,
          --   auto_sync_interval = 3600, -- 1 hour
          --   push = {
          --     enabled = true,
          --     staging_file = "~/org/linear-staging.md", -- Capture here
          --     default_team_key = "ARI",
          --     auto_push = false,
          --   },
          -- },
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = {
        enabled = true,
      },
      html_comment = {
        enabled = true,
        conceal = false, -- Display comments by default
      },
      heading = {
        sign = true,
        enabled = true,
        -- Override background/foreground groups so H1 isn’t DiffText (blue)
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- Custom highlights (run after plugin setup)
      local red = "#ff5370"
      local dim = "#2a1c1c"

      -- H1 text
      vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = red, bold = true })
      -- H1 background band (disable blue DiffText link)
      vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = dim })
      -- If you want no background band at all:
      -- vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "NONE" })

      -- Treesitter groups, to keep consistency
      vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = red, bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.1.marker.markdown", { fg = red, bold = true })
    end,
  },
}
