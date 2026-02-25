-- Create the editor command (async via job.nvim so UI never blocks)
vim.api.nvim_create_user_command("NeotestCppBuildCache", function()
  local job = require("job")
  local config = require("neotest-cpp.config").get()
  local root = vim.fn.getcwd()
  local cache_dir = root .. "/.cache/neotest-cpp"
  vim.fn.mkdir(cache_dir, "p")

  local test_files = vim.fn.glob("**/*.test.cpp", false, true)
  local total = #test_files
  local processed, cached = 0, 0
  vim.notify(string.format("Building cache for %d test files...", total))

  local patterns = { "cmake-build-debug/docker-wrappers/tst-*" }
  local executables = vim
    .iter(patterns)
    :map(function(glob_pattern)
      return vim.fn.glob(glob_pattern, false, true)
    end)
    :flatten()
    :filter(function(match)
      local stat = vim.uv.fs_stat(match)
      if stat and stat.type == "file" then
        local user_execute = tonumber("00100", 8)
        return bit.band(stat.mode, user_execute) == user_execute
      end
      return false
    end)
    :totable()

  local function try_next_file()
    processed = processed + 1
    local file = test_files[processed]
    if not file then
      vim.notify(string.format("Cache build complete: %d/%d files cached", cached, total))
      return
    end

    local abs_path = vim.fn.fnamemodify(file, ":p")
    local cache_key = vim.fn.sha256(abs_path)
    local cache_file = cache_dir .. "/" .. cache_key .. ".txt"

    -- Check cache (sync, fast)
    if vim.fn.filereadable(cache_file) == 1 then
      local cached_exe = vim.fn.readfile(cache_file)[1]
      local stat = vim.uv.fs_stat(cached_exe)
      if stat and stat.type == "file" then
        local user_execute = tonumber("00100", 8)
        if bit.band(stat.mode, user_execute) == user_execute then
          cached = cached + 1
        end
      end
      if processed % 10 == 0 then
        vim.notify(string.format("Progress: %d/%d processed, %d cached", processed, total, cached))
      end
      vim.schedule(try_next_file)
      return
    end

    -- Cache miss: try each executable via job (async)
    local exe_index = 1
    local function try_next_exe()
      if exe_index > #executables then
        if processed % 10 == 0 then
          vim.notify(string.format("Progress: %d/%d processed, %d cached", processed, total, cached))
        end
        vim.schedule(try_next_file)
        return
      end

      local exe_path = executables[exe_index]
      exe_index = exe_index + 1
      local test_list_file = vim.fn.tempname()
      local cmd = { exe_path, "--gtest_list_tests", "--gtest_output=json:" .. test_list_file }

      job.start(cmd, {
        on_exit = function(_, code, _)
          vim.schedule(function()
            if code ~= 0 then
              try_next_exe()
              return
            end
            if vim.fn.filereadable(test_list_file) ~= 1 then
              try_next_exe()
              return
            end
            local json_content = vim.fn.readfile(test_list_file)
            local ok, data = pcall(vim.json.decode, table.concat(json_content, "\n"))
            vim.fn.delete(test_list_file)
            if not ok or not data.testsuites then
              try_next_exe()
              return
            end
            for _, testsuite in ipairs(data.testsuites) do
              for _, test in ipairs(testsuite.testsuite or {}) do
                local test_file = test.file
                if test_file then
                  test_file = vim.fn.fnamemodify(test_file, ":p")
                  if test_file == abs_path then
                    vim.fn.writefile({ exe_path }, cache_file)
                    cached = cached + 1
                    if processed % 10 == 0 then
                      vim.notify(string.format("Progress: %d/%d processed, %d cached", processed, total, cached))
                    end
                    try_next_file()
                    return
                  end
                end
              end
            end
            try_next_exe()
          end)
        end,
      })
    end

    try_next_exe()
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
            -- my own AI-Slob reslove function with caching
            -- will be used until the plugin implements proper caching for the glob pattern search
            resolve = function(file_path)
              -- 1. Setup cache
              local root = vim.fn.getcwd()
              local cache_dir = root .. "/.cache/neotest-cpp"
              vim.fn.mkdir(cache_dir, "p")

              local cache_key = vim.fn.sha256(file_path)
              local cache_file = cache_dir .. "/" .. cache_key .. ".txt"

              -- 2. Check cache
              if vim.fn.filereadable(cache_file) == 1 then
                local cached_exe = vim.fn.readfile(cache_file)[1]
                local stat = vim.uv.fs_stat(cached_exe)
                if stat and stat.type == "file" then
                  local user_execute = tonumber("00100", 8)
                  if bit.band(stat.mode, user_execute) == user_execute then
                    vim.notify("Cache hit for " .. file_path .. " -> " .. cached_exe, vim.log.levels.DEBUG)
                    return cached_exe
                  end
                end
              end

              -- 3. Cache miss - use pattern-based discovery (same as plugin)
              local patterns = { "cmake-build-debug/docker-wrappers/tst-*" }
              local executables = vim
                .iter(patterns)
                :map(function(glob_pattern)
                  return vim.fn.glob(glob_pattern, false, true)
                end)
                :flatten()
                :filter(function(match)
                  -- Check if file is executable (same logic as plugin)
                  local stat = vim.uv.fs_stat(match)
                  if stat and stat.type == "file" then
                    local user_execute = tonumber("00100", 8)
                    return bit.band(stat.mode, user_execute) == user_execute
                  end
                  return false
                end)
                :totable()

              -- 4. Find which executable contains tests from this file
              -- This requires querying each executable with --gtest_list_tests
              for _, exe_path in ipairs(executables) do
                local test_list_file = vim.fn.tempname()
                local cmd =
                  string.format("%s --gtest_list_tests --gtest_output=json:%s 2>/dev/null", exe_path, test_list_file)
                vim.fn.system(cmd)

                if vim.fn.filereadable(test_list_file) == 1 then
                  local json_content = vim.fn.readfile(test_list_file)
                  local ok, data = pcall(vim.json.decode, table.concat(json_content, "\n"))

                  if ok and data.testsuites then
                    for _, testsuite in ipairs(data.testsuites) do
                      for _, test in ipairs(testsuite.testsuite or {}) do
                        -- Normalize the file path from gtest output
                        local test_file = test.file
                        if test_file then
                          test_file = vim.fn.fnamemodify(test_file, ":p")
                          if test_file == file_path then
                            -- Found the executable for this test file
                            vim.fn.writefile({ exe_path }, cache_file)
                            vim.fn.delete(test_list_file)
                            vim.notify("Cache miss for " .. file_path .. " -> " .. exe_path, vim.log.levels.DEBUG)
                            return exe_path
                          end
                        end
                      end
                    end
                  end
                  vim.fn.delete(test_list_file)
                end
              end

              -- 5. No executable found
              vim.notify("No executable found for " .. file_path, vim.log.levels.DEBUG)
              return nil
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
