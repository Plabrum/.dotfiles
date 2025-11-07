-- if true then
--   return {}
-- end
return {
  { "nvim-mini/mini.test", version = false },
  {
    dir = "~/repos/org-markdown",
    name = "org_markdown",
    dev = true,
    -- "Plabrum/org-markdown",
    opts = {
      window_method = "vertical",
      captures = {
        templates = {
          ["todo"] = {
            template = "# TODO %? \n %u",
            filename = "~/notes/todo.md",
            heading = "",
          },
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
