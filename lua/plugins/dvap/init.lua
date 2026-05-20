return {
  {
    "https://github.com/Isletier/nvim-DVAP-ui",
    dependencies = { "https://github.com/Isletier/nvim-DVAP" },
    config = function()
      require("nvim-dvap-ui").setup({
        -- Default host suggested for the connect command
        default_host = "127.0.0.1",

        -- Default port suggested for the connect command prompt
        default_port = 56789,

        -- Default reconnection interval in milliseconds (0 disables auto-reconnect)
        -- for the connect command prompt
        reconnect_interval = 500,

        -- Start the session in follow mode (automatically jumps to selected thread)
        follow_mode = true,

        -- Render thread id/tid as end-of-line virtual text
        virt_text_thread_info = true,

        -- temporary set vim.o.number = true, vim.o.relativenumber = false
        -- while client is connected to debug session, then restore your previous options
        switch_to_absolute_number = true,

        -- Whether to set default keymaps
        set_default_keymaps = true,
        -- Default mappings:
        -- vim.keymap.set("n", "<leader>dc",  "<cmd>DVAPConnect<CR>")
        -- vim.keymap.set("n", "<leader>dd",  "<cmd>DVAPDisconnect<CR>")
        -- vim.keymap.set("n", "<leader>dt",  "<cmd>DVAPToggleFollow<CR>")
        -- vim.keymap.set("n", "<leader>df",  "<cmd>DVAPFocus<CR>")
        -- vim.keymap.set("n", "<leader>dp",  "<cmd>DVAPGetPathLine<CR>")
        -- vim.keymap.set("n", "<leader>dqb", "<cmd>DVAPBreakpointList<CR>")
        -- vim.keymap.set("n", "<leader>dqt", "<cmd>DVAPThreadList<CR>")
      })
      -- Cursor line in `non-follow` mode
      vim.api.nvim_set_hl(0, "dvap_CursorLine", { bg = "#1c455a", default = true })

      -- Cursor line in `follow` mode
      vim.api.nvim_set_hl(0, "dvap_FollowCursorLine", { bg = "#163546", default = true })

      -- Line highlight for selected thread
      vim.api.nvim_set_hl(0, "dvap_SelectedThread", { bg = "#474728", default = true })

      -- Line highlight for not selected threads
      vim.api.nvim_set_hl(0, "dvap_ThreadLine", { bg = "#4e3112", default = true })

      -- Line highlight for
      vim.api.nvim_set_hl(0, "dvap_LostThread", { bg = "#313d4d", fg = "#888888", default = true })

      -- Breakpoint symbols
      vim.fn.sign_define("DVAP_breakpoint_unconditional", { text = "B", texthl = "Character" })
      vim.fn.sign_define("DVAP_breakpoint_conditional", { text = "C", texthl = "Character" })
    end,
  },
}
