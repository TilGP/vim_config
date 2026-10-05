local M = {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jbyuki/one-small-step-for-vimkind",
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-dap.nvim",
    "mfussenegger/nvim-dap-python",
    "julianolf/nvim-dap-lldb",
    "docker/nvim-dap-docker",
  },
  ft = { "cpp", "go", "lua", "python" },
  -- version = '*',
}

---@type { config?: table }|nil
local last_run = nil

M.config = function()
  local dap = require("dap")
  local keymap = vim.keymap.set
  local ESC = string.char(27)
  ---@param s string
  ---@return string
  local function strip_ansi(s)
    return s:gsub(ESC .. "%[[0-9;]*[mK]", "")
  end

  -- Filter für stdout und stderr
  for _, ev in ipairs({ "event_stdout", "event_stderr", "event_output" }) do
    dap.listeners.before[ev]["dapui_strip_ansi"] = function(_, body)
      if body and body.output then
        body.output = strip_ansi(body.output)
      end
    end
  end

  -- Store the config for 'dap.last_run()'
  dap.listeners.after.event_initialized["store_config"] = function(session)
    if session.config then
      last_run = {
        config = session.config,
      }
    end
  end

  -- Reimplement last_run to store the config
  -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
  local function dap_run_last()
    if last_run and last_run.config then
      dap.run(last_run.config)
    else
      dap.continue()
    end
  end

  require("nvim-dap-virtual-text").setup({
    -- Use eol instead of inline
    virt_text_pos = "eol",
  })

  local dapui = require("dapui")

  keymap({ "n", "v" }, "<leader>du", function()
    dapui.toggle({})
  end, { silent = true, desc = "Toggle DAP-UI" })
  keymap({ "n", "v" }, "<F3>", function()
    dapui.toggle()
  end, { silent = true, desc = "DAP toggle UI" })
  keymap({ "n", "v" }, "<F4>", function()
    dap.pause()
  end, { silent = true, desc = "DAP pause (thread)" })
  keymap({ "n", "v" }, "<F5>", function()
    dap.continue()
  end, { silent = true, desc = "DAP launch or continue" })
  keymap({ "n", "v" }, "<F7>", function()
    dap.step_into()
  end, { silent = true, desc = "DAP step into" })
  keymap({ "n", "v" }, "<F8>", function()
    dap.step_over()
  end, { silent = true, desc = "DAP step over" })
  keymap({ "n", "v" }, "<F9>", function()
    dap.step_out()
  end, { silent = true, desc = "DAP step out" })
  keymap({ "n", "v" }, "<F6>", function()
    dap.step_back()
  end, { silent = true, desc = "DAP step back" })
  keymap({ "n", "v" }, "<F10>", function()
    dap_run_last()
  end, { silent = true, desc = "DAP run last" })
  -- F11 is used by KDE for fullscreen
  keymap({ "n", "v" }, "<F12>", function()
    dap.terminate()
  end, { silent = true, desc = "DAP terminate" })
  keymap({ "n", "v" }, "<leader>dd", function()
    dap.disconnect({ terminateDebuggee = false })
  end, { silent = true, desc = "DAP disconnect" })
  keymap({ "n", "v" }, "<leader>dt", function()
    dap.disconnect({ terminateDebuggee = true })
  end, { silent = true, desc = "DAP disconnect and terminate" })
  keymap({ "n", "v" }, "<leader>db", function()
    dap.toggle_breakpoint()
  end, { silent = true, desc = "DAP toggle breakpoint" })
  keymap({ "n", "v" }, "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { silent = true, desc = "DAP set breakpoint with condition" })
  keymap({ "n", "v" }, "<leader>dp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("log point message: "))
  end, { silent = true, desc = "dap set breakpoint with log point message" })

  keymap({ "n", "v" }, "<leader>dC", function()
    dap.run_to_cursor()
  end, { silent = true, desc = "dap run to cursor" })

  --[[
    -- Only needed if we don't use dap-ui
    keymap({ "n", "v" }, "<leader>dr", function()
      dap.repl.toggle()
    end, { silent = true, desc = "DAP toggle debugger REPL" })
]]

  local telescope_dap = require("telescope").extensions.dap

  keymap({ "n", "v" }, "<leader>d?", function()
    telescope_dap.commands({})
  end, { silent = true, desc = "DAP builtin commands" })

  keymap({ "n", "v" }, "<leader>dl", function()
    telescope_dap.list_breakpoints({})
  end, { silent = true, desc = "DAP breakpoint list" })

  keymap({ "n", "v" }, "<leader>df", function()
    telescope_dap.frames()
  end, { silent = true, desc = "DAP frames" })

  keymap({ "n", "v" }, "<leader>dv", function()
    telescope_dap.variables()
  end, { silent = true, desc = "DAP variables" })

  keymap({ "n", "v" }, "<leader>dc", function()
    telescope_dap.configurations()
  end, { silent = true, desc = "DAP debugger configurations" })

  require("telescope").load_extension("dap")

  -- configure dap-ui and language adapaters
  require("plugins.dap.ui")
  require("plugins.dap.cpp")
  require("plugins.dap.python")
  require("dap-docker").setup({
    delve = {
      path = "docker",
    },
  })
end

return M
