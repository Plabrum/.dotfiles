return {
  "gbprod/substitute.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {

    {
      "r",
      mode = { "n" },
      function()
        require("substitute").operator()
      end,
      desc = "substitute",
    },
    {
      "rr",
      mode = { "n" },
      function()
        require("substitute").line()
      end,
      desc = "substitute line",
    },
    {
      "R",
      mode = { "n" },
      function()
        require("substitute").eol()
      end,
      desc = "substitute eol",
    },
    {
      "r",
      mode = { "x" },
      function()
        require("substitute").visual()
      end,
      desc = "substitute visual",
    },
  },
}
