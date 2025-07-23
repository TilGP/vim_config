local clangd_command = os.getenv("CLANGD_COMMAND") or "clangd"

local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "p00f/clangd_extensions.nvim",
  },
  ---@class PluginLspOpts
  opts = {
    servers = {
      -- Ensure mason installs the server
      clangd = {
        keys = {
          { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.hpp.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja"
          )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            fname
          ) or vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
        end,
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
    },
    setup = {
      clangd = function(_, opts)
        local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
        opts.filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }
        require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
        return false
      end,
      -- disable clangd on proto files as we need bufls to handle protobuf files
      groovyls = function(_, opts)
        opts.filetypes = { "groovy", "jenkinsfile" }
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

return M
