local clangd_command = os.getenv("CLANGD_COMMAND") or "clangd"

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "thejezzi/lsplocal.nvim",
  },
  ---@class PluginLspOpts
  opts = {
    servers = {
      -- Ensure mason installs the server
      clangd = {
        keys = {
          { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac", -- AutoTools
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja",
          ".git",
        },
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        cmd = {
          clangd_command,
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },
      groovyls = {
        cmd = {
          "java",
          "-jar",
          "groovy-langauge-server-all.jar",
        },
      },
      gopls = {
        keys = {
          -- Workaround for the lack of a DAP strategy in neotest-go: https://github.com/nvim-neotest/neotest-go/issues/12
          { "<leader>td", "<cmd>lua require('dap-go').debug_test()<CR>", desc = "Debug Nearest (Go)" },
        },
        settings = {
          gopls = {
            -- buildFlags = { "-tags=dev" },
            gofumpt = true,
            codelenses = {
              gc_details = true,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
      },
    },
    setup = {
      clangd = function(_, opts)
        opts.filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }
      end,
      -- disable clangd on proto files as we need bufls to handle protobuf files
      groovyls = function(_, opts)
        opts.filetypes = { "groovy", "jenkinsfile" }
      end,

      gopls = function(_, opts)
        -- workaround for gopls not supporting semanticTokensProvider
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        require("lazyvim.util").lsp.on_attach(function(client, _)
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
        -- end workaround
      end,
    },
    diagnostics = {
      virtual_text = true,
      virtual_lines = false,
      underline = true,
      update_in_insert = false,
    },
  },
}
