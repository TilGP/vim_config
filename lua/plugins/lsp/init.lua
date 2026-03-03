---nvim-lspconfig with per-server config in lua/plugins/lsp/*.lua.
local clangd = require("plugins.lsp.clangd")
local gopls = require("plugins.lsp.gopls")
local groovyls = require("plugins.lsp.groovyls")
local jsonls = require("plugins.lsp.jsonls")

return {
  require("plugins.lsp.symbol-usage"),
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "thejezzi/lsplocal.nvim",
      {
        "b0o/SchemaStore.nvim",
        lazy = true,
        version = false,
      },
    },
    opts = {
      servers = {
        clangd = clangd.get(),
        groovyls = groovyls.get(),
        gopls = gopls.get(),
        jsonls = jsonls.get(),
      },
      ---@type table<string, fun(server: string, opts: table): boolean?>
      setup = {
        clangd = function(_, opts)
          opts.filetypes = { "c", "cpp", "hpp", "objc", "objcpp", "cuda" }
        end,
        groovyls = function(_, opts)
          opts.filetypes = { "groovy", "jenkinsfile" }
        end,
        gopls = function(_, opts)
          require("snacks.util").lsp.on(function(_, client)
            if client.name == "gopls" then
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end
          end)
        end,
      },
      diagnostics = {
        virtual_text = true,
        virtual_lines = false,
        underline = true,
        update_in_insert = false,
      },
    },
  },
}
