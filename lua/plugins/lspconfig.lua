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

-- local og_virt_text
-- local og_virt_line
-- vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged" }, {
--   group = vim.api.nvim_create_augroup("diagnostic_only_virtlines", {}),
--   callback = function()
--     if og_virt_line == nil then
--       og_virt_line = vim.diagnostic.config().virtual_lines
--     end
--
--     -- ignore if virtual_lines.current_line is disabled
--     if not (og_virt_line and og_virt_line.current_line) then
--       if og_virt_text then
--         vim.diagnostic.config({ virtual_text = og_virt_text })
--         og_virt_text = nil
--       end
--       return
--     end
--
--     if og_virt_text == nil then
--       og_virt_text = vim.diagnostic.config().virtual_text
--     end
--
--     local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
--
--     if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
--       vim.diagnostic.config({ virtual_text = og_virt_text })
--     else
--       vim.diagnostic.config({ virtual_text = false })
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("ModeChanged", {
--   group = vim.api.nvim_create_augroup("diagnostic_redraw", {}),
--   callback = function()
--     pcall(vim.diagnostic.show)
--   end,
-- })
return M
