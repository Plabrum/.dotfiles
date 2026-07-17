-- Delta on top of LazyVim's `lang.go` extra.
-- The extra's gopls semantic-tokens workaround does
--   local semantic = client.config.capabilities.textDocument.semanticTokens
-- which throws when `textDocument` is nil (our capabilities come from blink.cmp).
-- Re-implement it nil-safely, falling back to Neovim's default capabilities.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        gopls = function(_, _opts)
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if not client.server_capabilities.semanticTokensProvider then
              local caps = client.config.capabilities or {}
              local semantic = (caps.textDocument and caps.textDocument.semanticTokens)
                or vim.lsp.protocol.make_client_capabilities().textDocument.semanticTokens
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end)
        end,
      },
    },
  },
}
