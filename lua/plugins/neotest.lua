return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "alfaix/neotest-gtest",
    },
    opts = function(_, opts)
      local wk = require("which-key")
      local lib = require("neotest.lib")

      -- check if current buffer is a cpp file
      -- if so, add keybindings for gtest
      if vim.bo.filetype == "cpp" then
        require("neotest-gtest.executables").set_summary_autocmd()
        wk.add({
          {
            "<leader>tx",
            "<cmd>ConfigureGtest<CR>",
            desc = "Change Executable",
            mode = "n",
          },
        })
      end

      opts.adapters["neotest-gtest"] = {
        -- fun(string) -> string: takes a file path as string and returns its project root
        -- directory
        -- neotest.lib.files.match_root_pattern() is a convenient factory for these functions:
        -- it returns a function that returns true if the directory contains any entries
        -- with matching names
        root = lib.files.match_root_pattern(
          "compile_commands.json",
          "compile_flags.txt",
          "WORKSPACE",
          ".clangd",
          "init.lua",
          "init.vim",
          "build",
          ".git"
        ),
        -- which debug adapter to use? dap.adapters.<this debug_adapter> must be defined.
        debug_adapter = "gdb",

        -- fun(string) -> bool: takes a file path as string and returns true if it contains
        -- tests
        is_test_file = function(file)
          local file_stem = file:match("([^/\\]+)%.%w+$") -- Extract file stem
          local file_ext = file:match("%.([^%.]+)$") -- Extract file extension

          return (file_stem:match("^test_") or file_stem:match("_test$") or file_stem:match(".test$"))
            and (file_ext == "cpp" or file_ext == "cppm" or file_ext == "cc" or file_ext == "cxx" or file_ext == "c++")
        end,
      }
      opts.adapters["neotest-golang"] = {
        go_test_args = {
          "-v",
          "-race",
          "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
        },
      }
    end,
  },
}
