--- Shared neotest-cpp executable resolution with caching.
--- Used by the plugin's resolve() and by NeotestCppBuildCache command.
local M = {}

local PATTERNS = { "cmake-build-debug/docker-wrappers/tst-*" }
local USER_EXECUTE = tonumber("00100", 8)

function M.get_cache_dir()
  local root = vim.fn.getcwd()
  return root .. "/.cache/neotest-cpp"
end

--- @param file_path string absolute path to the test file
--- @return string sha256 hash used as cache key (and cache filename without .txt)
function M.get_cache_key(file_path)
  return vim.fn.sha256(file_path)
end

function M.get_cache_file_path(file_path)
  local cache_dir = M.get_cache_dir()
  vim.fn.mkdir(cache_dir, "p")
  local cache_key = vim.fn.sha256(file_path)
  return cache_dir .. "/" .. cache_key .. ".txt"
end

--- @param cache_file string
--- @return string|nil cached exe path if valid, nil otherwise
function M.read_cache(cache_file)
  if vim.fn.filereadable(cache_file) ~= 1 then
    return nil
  end
  local lines = vim.fn.readfile(cache_file)
  if not lines or not lines[1] then
    return nil
  end
  local cached_exe = lines[1]
  local stat = vim.uv.fs_stat(cached_exe)
  if not stat or stat.type ~= "file" then
    return nil
  end
  if bit.band(stat.mode, USER_EXECUTE) ~= USER_EXECUTE then
    return nil
  end
  return cached_exe
end

function M.write_cache(cache_file, exe_path)
  vim.fn.writefile({ exe_path }, cache_file)
end

--- @return string[] list of executable paths
function M.get_executables()
  return vim
    .iter(PATTERNS)
    :map(function(glob_pattern)
      return vim.fn.glob(glob_pattern, false, true)
    end)
    :flatten()
    :filter(function(match)
      local stat = vim.uv.fs_stat(match)
      if stat and stat.type == "file" then
        return bit.band(stat.mode, USER_EXECUTE) == USER_EXECUTE
      end
      return false
    end)
    :totable()
end

--- Parse gtest JSON output file and check if file_path is in the test list.
--- @param test_list_file string path to JSON file
--- @param file_path string normalized path to match
--- @return string|nil exe_path if file_path found in output (caller must pass it in), nil otherwise
local function parse_gtest_output_for_file(test_list_file, file_path)
  if vim.fn.filereadable(test_list_file) ~= 1 then
    return nil
  end
  local json_content = vim.fn.readfile(test_list_file)
  local ok, data = pcall(vim.json.decode, table.concat(json_content, "\n"))
  vim.fn.delete(test_list_file)
  if not ok or not data.testsuites then
    return nil
  end
  for _, testsuite in ipairs(data.testsuites) do
    for _, test in ipairs(testsuite.testsuite or {}) do
      local test_file = test.file
      if test_file then
        test_file = vim.fn.fnamemodify(test_file, ":p")
        if test_file == file_path then
          return true -- match found; caller has exe_path
        end
      end
    end
  end
  return nil
end

--- Run gtest for one executable (sync). Returns exe_path if it contains file_path, nil otherwise.
--- @param exe_path string
--- @param file_path string
--- @return string|nil
function M.check_exe_contains_file_sync(exe_path, file_path)
  local test_list_file = vim.fn.tempname()
  local cmd = string.format(
    "SKIP_BUILDING=1 %s --gtest_list_tests --gtest_output=json:%s 2>/dev/null",
    exe_path,
    test_list_file
  )
  vim.fn.system(cmd)
  if parse_gtest_output_for_file(test_list_file, file_path) then
    return exe_path
  end
  return nil
end

--- Run gtest for one executable (async via job). Calls callback(exe_path or nil).
--- @param exe_path string
--- @param file_path string
--- @param callback fun(exe_path: string|nil)
function M.check_exe_contains_file_async(exe_path, file_path, callback)
  local job = require("job")
  local test_list_file = vim.fn.tempname()
  local cmd = { exe_path, "--gtest_list_tests", "--gtest_output=json:" .. test_list_file }

  job.start(cmd, {
    env = { SKIP_BUILDING = "1" },
    on_exit = function(_, code, _)
      vim.schedule(function()
        if code ~= 0 then
          callback(nil)
          return
        end
        if parse_gtest_output_for_file(test_list_file, file_path) then
          callback(exe_path)
        else
          callback(nil)
        end
      end)
    end,
  })
end

--- Full resolve: cache read + executable discovery. Synchronous (blocks on gtest).
--- @param file_path string
--- @return string|nil
function M.resolve_sync(file_path)
  local cache_file = M.get_cache_file_path(file_path)
  local cached = M.read_cache(cache_file)
  if cached then
    vim.notify("Cache hit for " .. file_path .. " -> " .. cached, vim.log.levels.DEBUG)
    return cached
  end

  local executables = M.get_executables()
  for _, exe_path in ipairs(executables) do
    if M.check_exe_contains_file_sync(exe_path, file_path) then
      M.write_cache(cache_file, exe_path)
      vim.notify("Cache miss for " .. file_path .. " -> " .. exe_path, vim.log.levels.INFO)
      return exe_path
    end
  end

  vim.notify("No executable found for " .. file_path, vim.log.levels.WARN)
  return nil
end

--- Full resolve (async). Calls callback(exe_path or nil) when done.
--- @param file_path string
--- @param callback fun(exe_path: string|nil)
function M.resolve_async(file_path, callback)
  local cache_file = M.get_cache_file_path(file_path)
  local cached = M.read_cache(cache_file)
  if cached then
    vim.schedule(function()
      callback(cached)
    end)
    return
  end

  local executables = M.get_executables()
  local exe_index = 1

  local function try_next()
    if exe_index > #executables then
      vim.schedule(function()
        callback(nil)
      end)
      return
    end

    local exe_path = executables[exe_index]
    exe_index = exe_index + 1

    M.check_exe_contains_file_async(exe_path, file_path, function(match)
      if match then
        M.write_cache(cache_file, match)
        vim.schedule(function()
          callback(match)
        end)
      else
        try_next()
      end
    end)
  end

  try_next()
end

return M
