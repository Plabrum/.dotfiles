return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local found = vim.fs.find({ "deno.json", "deno.jsonc" }, {
              upward = true,
              path = vim.fs.dirname(fname),
            })[1]
            if found then
              on_dir(vim.fs.dirname(found))
            end
          end,
          single_file_support = false,
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          opts.on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end
        end,
      },
    },
  },
}
