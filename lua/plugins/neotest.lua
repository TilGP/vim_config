-- Create the editor command (async via shared cache module)
vim.api.nvim_create_user_command("NeotestCppBuildCache", function()
  local cache = require("lib.neotest_cpp_cache")

  local test_files = vim.fn.glob("**/*.test.cpp", false, true)
  local total = #test_files
  local processed, cached = 0, 0
  vim.notify(string.format("Building cache for %d test files...", total), vim.log.levels.INFO)

  local function try_next_file()
    processed = processed + 1
    local file = test_files[processed]
    if not file then
      vim.notify(string.format("Cache build complete: %d/%d files cached", cached, total), vim.log.levels.INFO)
      return
    end

    local abs_path = vim.fn.fnamemodify(file, ":p")

    cache.resolve_async(abs_path, function(exe)
      if exe then
        cached = cached + 1
      end
      vim.notify(string.format("Progress: %d/%d processed, %d cached", processed, total, cached), vim.log.levels.INFO)
      vim.schedule(try_next_file)
    end)
  end

  vim.schedule(try_next_file)
end, {
  desc = "Build neotest-cpp cache asynchronously (non-blocking)",
})

-- Show cache key and associated executable for current test file (to find which cache file to delete)
vim.api.nvim_create_user_command("NeotestCppCacheInfo", function(opts)
  local cache = require("lib.neotest_cpp_cache")
  local file_path = opts.args ~= "" and vim.fn.fnamemodify(opts.args, ":p") or vim.fn.expand("%:p")
  if file_path == "" then
    vim.notify("No file: open a buffer or pass a path as argument", vim.log.levels.ERROR)
    return
  end

  local cache_key = cache.get_cache_key(file_path)
  local cache_file = cache.get_cache_dir() .. "/" .. cache_key .. ".txt"
  local exe = cache.read_cache(cache_file)

  local label_w = 10
  local pad = function(s)
    return s .. string.rep(" ", label_w - #s)
  end
  local lines = {
    pad("file:") .. file_path,
    pad("hash key:") .. cache_key,
    pad("cache:") .. cache_file,
    pad("exe:") .. (exe or "(not cached)"),
  }

  local max_len = 0
  for _, line in ipairs(lines) do
    max_len = math.max(max_len, #line)
  end
  local w = math.min(math.max(max_len + 2, 50), vim.o.columns - 4)

  require("snacks.win")({
    text = lines,
    title = " NeotestCppCacheInfo ",
    border = "rounded",
    width = w,
    height = #lines + 2,
    bo = { filetype = "text", bufhidden = "wipe", modifiable = false },
  })
end, {
  desc = "Print neotest-cpp cache key and associated executable for current/given test file",
  nargs = "?",
})

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "folke/snacks.nvim",
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
              return { SKIP_BUILDING = "0" }
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
