-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.cmd("packadd nvim.undotree")

---@type table[]
require("which-key").add({
  {
    "<X1Mouse>",
    "<C-o>",
    desc = "Jump back",
    silent = true,
  },
  {
    "<X2Mouse>",
    "<C-i>",
    desc = "Jump forward",
    silent = true,
  },
  {
    "<leader>uu",
    function()
      require("undotree").open()
    end,
    desc = "open undo tree",
  },
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
  {
    "<leader>yy",
    function()
      local filepath = vim.api.nvim_buf_get_name(0)
      if filepath == "" then
        vim.notify("No file name for current buffer", vim.log.levels.WARN)
        return
      end

      local modify = vim.fn.fnamemodify
      local line = vim.fn.line(".")
      local results = {
        filepath .. ":" .. line,
        modify(filepath, ":.") .. ":" .. line,
        modify(filepath, ":~") .. ":" .. line,
        modify(filepath, ":t") .. ":" .. line,
      }

      vim.ui.select({
        "1. Absolute path: " .. results[1],
        "2. Path relative to CWD: " .. results[2],
        "3. Path relative to HOME: " .. results[3],
        "4. Filename: " .. results[4],
      }, { prompt = "Choose to copy to clipboard:" }, function(choice)
        if not choice then
          return
        end
        local i = tonumber(choice:sub(1, 1))
        local result = results[i]
        vim.fn.setreg("+", result)
        vim.notify("Copied: " .. result)
      end)
    end,
    desc = "Yank file path:line",
    silent = true,
  },

  { "<leader><Tab>", group = "tabs" },

  unpack(vim.tbl_map(function(i)
    return {
      "<leader><Tab>" .. i,
      i .. "gt",
      desc = "Go to tab " .. i,
      silent = true,
    }
  end, vim.fn.range(1, 9))),
})
