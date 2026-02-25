-- Create the editor command (async via shared cache module)
vim.api.nvim_create_user_command("NeotestCppBuildCache", function()
  local cache = require("lib.neotest_cpp_cache")

  local test_files = vim.fn.glob("**/*.test.cpp", false, true)
  local total = #test_files
  local processed, cached = 0, 0
  vim.notify(string.format("Building cache for %d test files...", total))

  local function try_next_file()
    processed = processed + 1
    local file = test_files[processed]
    if not file then
      vim.notify(string.format("Cache build complete: %d/%d files cached", cached, total))
      return
    end

    local abs_path = vim.fn.fnamemodify(file, ":p")

    cache.resolve_async(abs_path, function(exe)
      if exe then
        cached = cached + 1
      end
      if processed % 10 == 0 then
        vim.notify(string.format("Progress: %d/%d processed, %d cached", processed, total, cached))
      end
      vim.schedule(try_next_file)
    end)
  end

  vim.schedule(try_next_file)
end, {
  desc = "Build neotest-cpp cache asynchronously (non-blocking)",
})

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-plenary",
      "fredrikaverpil/neotest-golang",
      {
        "ryanpholt/neotest-cpp",
        opts = {
          executables = {
            -- Shared caching logic in lua/lib/neotest_cpp_cache.lua (sync for plugin use)
            resolve = function(file_path)
              return require("lib.neotest_cpp_cache").resolve_sync(file_path)
            end,
            env = function(_)
              return { SKIP_BUILDING = "1" }
            end,
          },
        },
      },
    },
    opts = function(_, opts)
      if vim.bo.filetype == "cpp" then
        table.insert(opts.adapters, "neotest-cpp")
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
