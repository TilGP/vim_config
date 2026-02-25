-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

---@type table[]
require("which-key").add({
  {
    "<leader>i",
    function()
      require("lib").print_file_info()
    end,
    icon = "i",
    desc = "show information about the current cursor position",
  },
  {
    "<C-t>",
    function()
      local line = vim.api.nvim_get_current_line()
      local updated_line = line:gsub("true", "TEMP"):gsub("false", "true"):gsub("TEMP", "false")
      vim.api.nvim_set_current_line(updated_line)
    end,
    icon = "t",
    desc = "Toggle the first occurrence of true/false",
  },
  {
    "<leader>bu",
    function()
      local curbufnr = vim.api.nvim_get_current_buf()
      local buflist = vim.api.nvim_list_bufs()
      for _, bufnr in ipairs(buflist) do
        if vim.bo[bufnr].buflisted and bufnr ~= curbufnr and (vim.fn.getbufvar(bufnr, "bufpersist") ~= 1) then
          vim.cmd("bd " .. tostring(bufnr))
        end
      end
    end,
    desc = "close unused/untouched buffers",
    silent = true,
  },
  {
    "g<s-m>",
    function()
      Snacks.picker.marks()
    end,
    desc = "Open marks picker",
    silent = true,
  },
})
