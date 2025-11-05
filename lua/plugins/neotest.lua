return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "alfaix/neotest-gtest",
      "nvim-neotest/neotest-plenary",
      "fredrikaverpil/neotest-golang",
    },
    opts = function(_, opts)
      local wk = require("which-key")
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
        table.insert(opts.adapters, "neotest-gtest")
        opts.adapters["neotest-gtest"] = {
          debug_adapter = "gdb",
          is_test_file = function(file)
            -- the file must end with _test.cpp, .test.cpp
            return file:match("_test%.cpp$") or file:match("%.test%.cpp$")
          end,
        }
      end

      if vim.bo.filetype == "go" then
        opts.adapters["neotest-golang"] = {
          go_test_args = {
            "-v",
            "-race",
            "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
          },
        }
      end
    end,
  },
}
