return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
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

      table.insert(
        opts.adapters,
        require("neotest-gtest").setup({
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
            -- local file_stem = file:match("([^/\\]+)%.%w+$") -- Extract file stem
            -- local file_ext = file:match("%.([^%.]+)$") -- Extract file extension
            --
            -- local match_string = function()
            --   if
            --     file_stem:match("^test_")
            --     and (
            --       file_ext == "cpp"
            --       or file_ext == "cppm"
            --       or file_ext == "cc"
            --       or file_ext == "cxx"
            --       or file_ext == "c++"
            --     )
            --   then
            --     return "test_"
            --   end
            --   if
            --     file_stem:match("_test$")
            --     and (
            --       file_ext == "cpp"
            --       or file_ext == "cppm"
            --       or file_ext == "cc"
            --       or file_ext == "cxx"
            --       or file_ext == "c++"
            --     )
            --   then
            --     return "_test"
            --   end
            --   if
            --     file_stem:match(".test$")
            --     and (
            --       file_ext == "cpp"
            --       or file_ext == "cppm"
            --       or file_ext == "cc"
            --       or file_ext == "cxx"
            --       or file_ext == "c++"
            --     )
            --   then
            --     return ".test"
            --   end
            -- end
            --
            -- vim.notify(
            --   "File: " .. file .. "\nstem: " .. file_stem .. "\next: " .. file_ext .. "\nmatch: " .. match_string()
            -- )
            --
            -- return (file_stem:match("^test_") or file_stem:match("_test$") or file_stem:match(".test$"))
            --   and (
            --     file_ext == "cpp"
            --     or file_ext == "cppm"
            --     or file_ext == "cc"
            --     or file_ext == "cxx"
            --     or file_ext == "c++"
            --   )
          end,
          -- How many old test results to keep on disk (stored in stdpath('data')/neotest-gtest/runs)
          history_size = 3,
          -- To prevent large projects from freezing your computer, there's some throttling
          -- for -- parsing test files. Decrease if your parsing is slow and you have a
          -- monster PC.
          parsing_throttle_ms = 10,
          -- set configure to a normal mode key which will run :ConfigureGtest (suggested:
          -- "C", nil by default)
          mappings = { configure = nil },
          summary_view = {
            -- How long should the header be in tests short summary?
            -- ________TestNamespace.TestName___________ <- this is the header
            header_length = 80,
            -- Your shell's colors, if the default ones don't work.
            shell_palette = {
              passed = "\27[32m",
              skipped = "\27[33m",
              failed = "\27[31m",
              stop = "\27[0m",
              bold = "\27[1m",
            },
          },
          -- What extra args should ALWAYS be sent to google test?
          -- if you want to send them for one given invocation only,
          -- send them to `neotest.run({extra_args = ...})`
          -- see :h neotest.RunArgs for details
          extra_args = {},
          -- see :h neotest.Config.discovery. Best to keep this as-is and set
          -- per-project settings in neotest instead.
          filter_dir = function(name, rel_path, root)
            -- see :h neotest.Config.discovery for defaults
          end,
        })
      )

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
