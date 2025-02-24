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
  },
  ft = { "c", "go", "lua", "python" },
  -- version = '*',
}

local last_run = nil

M.config = function()
  local dap = require("dap")
  local keymap = vim.keymap.set

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

  keymap(
    { "n", "v" },
    "<leader>du",
    "<cmd>lua require('dapui').toggle({ })<cr>",
    { silent = true, desc = "Toggle DAP-UI" }
  )
  keymap({ "n", "v" }, "<F3>", "<cmd>lua require('dapui').toggle()<CR>", { silent = true, desc = "DAP toggle UI" })
  keymap({ "n", "v" }, "<F4>", "<cmd>lua require('dap').pause()<CR>", { silent = true, desc = "DAP pause (thread)" })
  keymap(
    { "n", "v" },
    "<F5>",
    "<cmd>lua require('dap').continue()<CR>",
    { silent = true, desc = "DAP launch or continue" }
  )
  keymap({ "n", "v" }, "<F6>", "<cmd>lua require('dap').step_into()<CR>", { silent = true, desc = "DAP step into" })
  keymap({ "n", "v" }, "<F7>", "<cmd>lua require('dap').step_over()<CR>", { silent = true, desc = "DAP step over" })
  keymap({ "n", "v" }, "<F8>", "<cmd>lua require('dap').step_out()<CR>", { silent = true, desc = "DAP step out" })
  keymap({ "n", "v" }, "<F9>", "<cmd>lua require('dap').step_back()<CR>", { silent = true, desc = "DAP step back" })
  keymap({ "n", "v" }, "<F10>", function()
    dap_run_last()
  end, { silent = true, desc = "DAP run last" })
  -- F11 is used by KDE for fullscreen
  keymap({ "n", "v" }, "<F12>", "<cmd>lua require('dap').terminate()<CR>", { silent = true, desc = "DAP terminate" })
  keymap(
    { "n", "v" },
    "<leader>dd",
    "<cmd>lua require('dap').disconnect({ terminateDebuggee = false })<CR>",
    { silent = true, desc = "DAP disconnect" }
  )
  keymap(
    { "n", "v" },
    "<leader>dt",
    "<cmd>lua require('dap').disconnect({ terminateDebuggee = true })<CR>",
    { silent = true, desc = "DAP disconnect and terminate" }
  )
  keymap(
    { "n", "v" },
    "<leader>db",
    "<cmd>lua require('dap').toggle_breakpoint()<CR>",
    { silent = true, desc = "DAP toggle breakpoint" }
  )
  keymap(
    { "n", "v" },
    "<leader>dB",
    "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    { silent = true, desc = "DAP set breakpoint with condition" }
  )
  keymap(
    { "n", "v" },
    "<leader>dp",
    "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('log point message: '))<cr>",
    { silent = true, desc = "dap set breakpoint with log point message" }
  )
  --[[
    -- Only needed if we don't use dap-ui
    keymap(
        { 'n', 'v' },
        '<leader>dr',
        "<cmd>lua require('dap').repl.toggle()<CR>",
        { silent = true, desc = 'DAP toggle debugger REPL' }
    )
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
  require("plugins.dap.c")
end

return M
