---Neotest-cpp adapter config and user commands.
---When required: registers NeotestCppBuildCache and NeotestCppCacheInfo; returns neotest-cpp opts.

local function show_info_win(title, rows)
  local label_w = 0
  for _, row in ipairs(rows) do
    label_w = math.max(label_w, #row[1])
  end
  local pad = function(s)
    return s .. string.rep(" ", label_w - #s + 1)
  end
  local lines = {}
  for _, row in ipairs(rows) do
    table.insert(lines, pad(row[1]) .. row[2])
  end

  local max_len = 0
  for _, line in ipairs(lines) do
    max_len = math.max(max_len, #line)
  end
  local w = math.min(math.max(max_len + 2, 50), vim.o.columns - 4)

  require("snacks.win")({
    text = lines,
    title = title,
    border = "rounded",
    width = w,
    height = #lines + 2,
    bo = { filetype = "text", bufhidden = "wipe", modifiable = false },
  })
end

local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

---Transient progress window in the bottom right corner, like LSP progress reports.
---@param title string
---@param width integer
local function open_progress(title, width)
  local self = { text = "", frame = 1 }

  self.win = require("snacks.win")({
    relative = "editor",
    row = -2,
    col = -2,
    width = width,
    height = 1,
    border = "rounded",
    title = title,
    focusable = false,
    enter = false,
    backdrop = false,
    zindex = 60,
    bo = { filetype = "text", bufhidden = "wipe" },
  })

  local function render()
    if not self.win:valid() then
      return
    end
    self.frame = self.frame % #SPINNER + 1
    vim.api.nvim_buf_set_lines(self.win.buf, 0, -1, false, { " " .. SPINNER[self.frame] .. " " .. self.text })
  end

  self.timer = vim.uv.new_timer()
  self.timer:start(80, 80, vim.schedule_wrap(render))

  ---@param text string
  function self:set(text)
    self.text = text
  end

  function self:close()
    if self.timer then
      self.timer:stop()
      self.timer:close()
      self.timer = nil
    end
    self.win:close()
  end

  return self
end

vim.api.nvim_create_user_command("NeotestCppBuildCache", function()
  local cache = require("lib.neotest_cpp_cache")

  local test_files = vim.fn.glob("**/*.test.cpp", false, true)
  local total = #test_files
  local processed, hits, written, missing = 0, 0, 0, 0
  local started = vim.uv.hrtime()

  local progress = open_progress(" neotest-cpp cache ", 40)
  progress:set(string.format("0/%d processed", total))

  local function try_next_file()
    processed = processed + 1
    local file = test_files[processed]
    if not file then
      local elapsed = (vim.uv.hrtime() - started) / 1e9
      progress:close()
      show_info_win(" NeotestCppBuildCache ", {
        { "files:", string.format("%d", total) },
        { "hits:", string.format("%d", hits) },
        { "written:", string.format("%d", written) },
        { "missing:", string.format("%d", missing) },
        { "elapsed:", string.format("%.2fs", elapsed) },
      })
      return
    end

    local abs_path = vim.fn.fnamemodify(file, ":p")
    local already = cache.read_cache(cache.get_cache_file_path(abs_path))

    cache.resolve_async(abs_path, function(exe)
      if exe then
        if already then
          hits = hits + 1
        else
          written = written + 1
        end
      else
        missing = missing + 1
      end
      progress:set(string.format("%d/%d processed, %d cached", processed, total, hits + written))
      vim.schedule(try_next_file)
    end)
  end

  vim.schedule(try_next_file)
end, {
  desc = "Build neotest-cpp cache asynchronously (non-blocking)",
})

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

  show_info_win(" NeotestCppCacheInfo ", {
    { "file:", file_path },
    { "hash key:", cache_key },
    { "cache:", cache_file },
    { "exe:", exe or "(not cached)" },
  })
end, {
  desc = "Print neotest-cpp cache key and associated executable for current/given test file",
  nargs = "?",
})

---Local clone carrying the treesitter query fix; upstream's query discovers no
---tests on tree-sitter 0.25 (Neovim 0.12).
return {
  dir = vim.fn.expand("~/projects/neotest-cpp"),
  opts = {
    ---Only `*.test.cpp` are tests here; matching every .cpp makes neotest walk
    ---generated sources under cmake-build-debug/.
    is_test_file = function(file_path)
      return vim.endswith(file_path, ".test.cpp")
    end,
    executables = {
      resolve = function(file_path)
        return require("lib.neotest_cpp_cache").resolve_sync(file_path)
      end,
      debug = {
        dap_template = function(executable)
          -- Debug the real binary, not the docker wrapper. `-` is a Lua pattern
          -- metacharacter, so the search string has to be escaped.
          executable = executable:gsub(vim.pesc("/docker-wrappers/"), "/bin/", 1)

          local adapters = vim.tbl_keys(require("dap").adapters)

          -- Check whether the user has configured any of the following adapters.
          local mac_adapters = { "lldb", "codelldb", "cppdbg" }
          local linux_adapters = vim.list_extend(mac_adapters, { "gdb" })
          local windows_adapters = { "cppdbg" }

          local get_adapter = function(platform_adapters)
            return vim.iter(platform_adapters):find(function(platform_adapter)
              return vim.iter(adapters):find(platform_adapter)
            end)
          end

          local adapter = nil
          local sys = vim.uv.os_uname().sysname
          if sys == "Darwin" then
            adapter = get_adapter(mac_adapters)
          elseif sys == "Linux" then
            adapter = get_adapter(linux_adapters)
          elseif sys == "Windows_NT" then
            adapter = get_adapter(windows_adapters)
          end

          if adapter then
            return {
              name = "Debug with neotest-cpp",
              type = adapter,
              request = "launch",
              program = executable,
              args = "${arguments}",
              cwd = "${cwd}",
              env = "${env}",
            }
          end
          return nil
        end,
      },
    },
  },
}
