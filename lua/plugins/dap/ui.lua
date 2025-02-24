local ok, dapui = pcall(require, "dapui")
if not ok then
  return
end

dapui.setup({
  icons = {
    collapsed = "",
    current_frame = "",
    expanded = "",
  },
  mappings = {
    edit = "e",
    expand = { "<CR>", "<2-LeftMouse>" },
    repl = "r",
  },
  element_mappings = {},
  expand_lines = true,
  force_buffers = true,
  floating = { border = "", mappings = {} },
  render = { indent = 1 },
  layouts = {
    {
      elements = {
        {
          id = "scopes",
          size = 0.25,
        },
        {
          id = "breakpoints",
          size = 0.25,
        },
        {
          id = "stacks",
          size = 0.25,
        },
        {
          id = "watches",
          size = 0.25,
        },
      },
      position = "right",
      size = 60,
    },
    {
      elements = {
        {
          id = "repl",
          size = 0.7,
        },
        {
          id = "console",
          size = 0.3,
        },
      },
      position = "bottom",
      size = 15,
    },
  },
  controls = {
    enabled = true,
    element = "repl",
    icons = {
      pause = "",
      play = " (F5)",
      step_into = " (F6)",
      step_over = " (F7)",
      step_out = " (F8)",
      step_back = " (F9)",
      run_last = " (F10)",
      terminate = " (F12)",
      disconnect = " ([l]d)",
    },
  },
})

local dap = require("dap")

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
-- dap.listeners.before.event_terminated["dapui_config"] = function(e)
--   require("utils").info(string.format("program '%s' was terminated.", vim.fn.fnamemodify(e.config.program, ":t")))
--   dapui.close()
-- end
--[[
dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
end
]]
