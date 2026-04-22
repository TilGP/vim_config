local ok, dap = pcall(require, "dap")
if not ok then
  return
end

---@type string
local gdb_command = os.getenv("GDB_COMMAND") or "gdb"
---@type string
local lldb_command = os.getenv("LLDB_COMMAND") or "lldb"
---@type string
local bin_dir = vim.fn.getcwd() .. "/cmake-build-debug/bin/"
if os.getenv("BUILD_DIR") then
  bin_dir = os.getenv("BUILD_DIR") .. "/bin/"
end
-- See
-- https://sourceware.org/gdb/current/onlinedocs/gdb.html/Interpreters.html
-- https://sourceware.org/gdb/current/onlinedocs/gdb.html/Debugger-Adapter-Protocol.html
dap.adapters.gdb = {
  id = "gdb",
  type = "executable",
  command = gdb_command,
  args = { "--quiet", "--interpreter=dap" },
}

dap.adapters.lldb = {
  type = "executable",
  command = lldb_command,
  name = "lldb",
}

---Expand ${VAR} then $VAR in a string using the process environment.
---Unset variables stay literal so typos are visible.
---@param s string
---@return string
local function expand_env_vars(s)
  local out = s:gsub("%${([%w_]+)}", function(name)
    local v = os.getenv(name)
    return v ~= nil and v or ("${" .. name .. "}")
  end)
  out = out:gsub("%$([%w_]+)", function(name)
    local v = os.getenv(name)
    return v ~= nil and v or ("$" .. name)
  end)
  return out
end

---@param args_str string
---@return string[]
local function input_args_from_prompt(args_str)
  if args_str == nil or args_str == "" then
    return {}
  end
  local parts = vim.split(args_str, " +")
  return vim.tbl_map(expand_env_vars, parts)
end

dap.configurations.cpp = {
  {
    name = "Run executable (GDB)",
    type = "gdb",
    request = "launch",
    -- This requires special handling of 'run_last', see
    -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
    program = function()
      local path = vim.fn.input({
        prompt = "Path to executable: ",
        default = bin_dir,
        completion = "file",
      })

      return (path and path ~= "") and path or dap.ABORT
    end,
  },
  {
    name = "Run executable with arguments (GDB)",
    type = "gdb",
    request = "launch",
    -- This requires special handling of 'run_last', see
    -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
    program = function()
      local path = vim.fn.input({
        prompt = "Path to executable: ",
        default = bin_dir,
        completion = "file",
      })

      return (path and path ~= "") and path or dap.ABORT
    end,
    args = function()
      local args_str = vim.fn.input({
        prompt = "Arguments: ",
      })
      return input_args_from_prompt(args_str)
    end,
  },
  {
    name = "Attach to process (GDB)",
    type = "gdb",
    request = "attach",
    processId = require("dap.utils").pick_process,
  },
  {
    name = "Run executable with arguments (LLDB)",
    type = "lldb",
    request = "launch",
    program = function()
      local path = vim.fn.input({
        prompt = "Path to executable: ",
        default = bin_dir,
        completion = "file",
      })

      return (path and path ~= "") and path or dap.ABORT
    end,
    args = function()
      local args_str = vim.fn.input({
        prompt = "Arguments: ",
      })
      return input_args_from_prompt(args_str)
    end,
  },
  {
    name = "Run executable (LLDB)",
    type = "lldb",
    request = "launch",
    program = function()
      local path = vim.fn.input({
        prompt = "Path to executable: ",
        default = bin_dir,
        completion = "file",
      })

      return (path and path ~= "") and path or dap.ABORT
    end,
  },
}
