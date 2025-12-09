return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
      },
    },
    build = function()
      -- Use Homebrew's signed tree-sitter CLI
      vim.fn.system({ "/opt/homebrew/bin/tree-sitter", "build-wasm" })
    end,
  },
}
