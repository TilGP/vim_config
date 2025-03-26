local ok, dapui = pcall(require, "dapui")
if not ok then
  return
end

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapUIStop", linehl = "", numhl = "DapUIStop" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapUIStop", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapUIStop", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "󰜴", texthl = "DapUIStop", linehl = "CursorLine", numhl = "" })

dapui.setup({
  icons = {
    collapsed = "",
    current_frame = "",
    expanded = "",
  },
  mappings = {
    edit = "e",
    expand = { "<CR>", "<2-LeftMouse>", ";" },
    repl = "r",
  },
  element_mappings = {},
  expand_lines = true,
  force_buffers = true,
  floating = { border = "rounded", mappings = {} },
  render = { indent = 3 },
  layouts = {
    {
      elements = {
        {
          id = "scopes",
          size = 0.75,
        },
        {
          id = "watches",
          size = 0.25,
        },
      },
      position = "left",
      size = 60,
    },
    {
      elements = {
        {
          id = "breakpoints",
          size = 0.25,
        },
        {
          id = "stacks",
          size = 0.75,
        },
      },
      position = "right",
      size = 50,
    },
    {
      elements = {
        {
          id = "repl",
          size = 1,
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
      step_into = " (F7)",
      step_over = " (F8)",
      step_out = " (F9)",
      step_back = " (F6)",
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
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
